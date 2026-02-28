import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:onnxruntime/onnxruntime.dart';
import '../utils/unicode_processor.dart';

/// Messages sent from Main Isolate to Worker Isolate
class TtsWorkerRequest {
  final int id;
  final String type;
  final Map<String, dynamic> payload;
  final SendPort replyPort;

  TtsWorkerRequest(this.id, this.type, this.payload, this.replyPort);
}

/// Messages sent from Worker Isolate to Main Isolate
class TtsWorkerResponse {
  final int id;
  final dynamic result;
  final String? error;

  TtsWorkerResponse(this.id, {this.result, this.error});
}

/// The state class to hold decoded style tensors inside the worker
class WorkerStyle {
  final OrtValueTensor ttl, dp;
  final List<int> ttlShape, dpShape;
  WorkerStyle(this.ttl, this.dp, this.ttlShape, this.dpShape);
}

/// A long-running Worker Isolate that hosts the ENTIRE ONNX Runtime
/// and pre-processing pipeline for TTS, completely unblocking the Main Flutter thread.
class TtsWorkerIsolate {
  late SendPort _workerSendPort;
  late ReceivePort _mainReceivePort;
  late Isolate _isolate;
  bool _isInitialized = false;

  int _messageCount = 0;
  final Map<int, Completer<dynamic>> _completers = {};
  Future<void>? _initFuture;

  Future<void> init(RootIsolateToken rootIsolateToken) async {
    if (_isInitialized) return;
    if (_initFuture != null) return _initFuture;

    _initFuture = _doInit(rootIsolateToken);
    try {
      await _initFuture;
      _isInitialized = true;
    } finally {
      _initFuture = null;
    }
  }

  Future<void> _doInit(RootIsolateToken rootIsolateToken) async {
    _mainReceivePort = ReceivePort();
    _isolate = await Isolate.spawn(_workerEntrypoint, {
      'sendPort': _mainReceivePort.sendPort,
      'rootToken': rootIsolateToken,
    });

    final sendPortCompleter = Completer<SendPort>();

    // Single-subscription stream: we must set up listen ONCE.
    _mainReceivePort.listen((message) {
      if (message is SendPort) {
        if (!sendPortCompleter.isCompleted) {
          sendPortCompleter.complete(message);
        }
      } else if (message is TtsWorkerResponse) {
        final completer = _completers.remove(message.id);
        if (completer != null && !completer.isCompleted) {
          if (message.error != null) {
            completer.completeError(Exception(message.error));
          } else {
            completer.complete(message.result);
          }
        }
      }
    });

    // Wait securely until the worker has transmitted its SendPort
    _workerSendPort = await sendPortCompleter.future;
  }

  void dispose() {
    if (!_isInitialized) return;
    _workerSendPort.send(
      TtsWorkerRequest(-1, 'dispose', {}, _mainReceivePort.sendPort),
    );
    _mainReceivePort.close();
    _isolate.kill();
    for (final completer in _completers.values) {
      if (!completer.isCompleted) {
        completer.completeError(Exception('Worker Isolate disposed'));
      }
    }
    _completers.clear();
    _isInitialized = false;
  }

  Future<dynamic> sendRequest(String type, Map<String, dynamic> payload) {
    if (!_isInitialized) throw Exception('Worker not initialized');

    final id = _messageCount++;
    final completer = Completer<dynamic>();
    _completers[id] = completer;

    final tempPort = ReceivePort();
    _workerSendPort.send(
      TtsWorkerRequest(id, type, payload, tempPort.sendPort),
    );

    tempPort.listen((message) {
      if (message is TtsWorkerResponse) {
        _completers.remove(id);
        if (!completer.isCompleted) {
          if (message.error != null) {
            completer.completeError(Exception(message.error));
          } else {
            completer.complete(message.result);
          }
        }
      }
      tempPort.close();
    });

    return completer.future;
  }
}

/// The actual entrypoint for the spawned isolate.
/// Now manages the entire flutter_onnxruntime stack!
Future<void> _workerEntrypoint(Map<String, dynamic> args) async {
  final mainSendPort = args['sendPort'] as SendPort;
  final rootToken = args['rootToken'] as RootIsolateToken;

  // Initialize platform channels so we can use them strictly if needed
  BackgroundIsolateBinaryMessenger.ensureInitialized(rootToken);

  final workerReceivePort = ReceivePort();

  // Send our SendPort to the main isolate
  mainSendPort.send(workerReceivePort.sendPort);

  // State maintained entirely inside the Isolate
  UnicodeProcessor? processor;
  OrtSession? dpSession;
  OrtSession? textEncSession;
  OrtSession? vectorEstSession;
  OrtSession? vocoderSession;
  final Map<String, WorkerStyle> styles = {};

  int sampleRate = 24000;
  int baseChunkSize = 16;
  int chunkCompressFactor = 1;
  int latencyDim = 64;

  // Active Job ID for Cancellation
  int currentJobId = -1;

  // Helper inside Isolate
  List<T> flattenList<T>(dynamic list) {
    if (list is List) return list.expand((e) => flattenList<T>(e)).toList();
    if (T == double && list is num) return [list.toDouble()] as List<T>;
    return [list as T];
  }

  List<T> safeCast<T>(dynamic raw) {
    if (raw is num) {
      if (T == double) return [raw.toDouble()] as List<T>;
      if (T == int) return [raw.toInt()] as List<T>;
      return [raw as T];
    }
    if (raw is List<T>) return raw;
    if (raw is List) {
      if (raw.isNotEmpty && raw.first is List) {
        return flattenList<T>(raw);
      }
      if (T == double) {
        return raw
                .map(
                  (e) => e is num ? e.toDouble() : double.parse(e.toString()),
                )
                .toList()
            as List<T>;
      }
      return raw.cast<T>();
    }
    throw Exception('Cannot convert $raw (${raw.runtimeType}) to List<$T>');
  }

  List<double> flattenToDouble(dynamic list) {
    if (list is List) return list.expand((e) => flattenToDouble(e)).toList();
    return [list is num ? list.toDouble() : double.parse(list.toString())];
  }

  OrtValueTensor toTensor(dynamic array, List<int> dims) {
    final flat = flattenList<double>(array);
    return OrtValueTensor.createTensorWithDataList(
      Float32List.fromList(flat),
      dims,
    );
  }

  OrtValueTensor scalarToTensor(List<double> array, List<int> dims) {
    return OrtValueTensor.createTensorWithDataList(
      Float32List.fromList(array),
      dims,
    );
  }

  OrtValueTensor intToTensor(List<List<int>> array, List<int> dims) {
    final flat = array.expand((row) => row).toList();
    return OrtValueTensor.createTensorWithDataList(
      Int64List.fromList(flat),
      dims,
    );
  }

  Future<WorkerStyle> loadVoiceStyle(List<String> paths) async {
    final bsz = paths.length; // usually 1
    final firstJsonStr = await File(paths[0]).readAsString();
    final firstJson = jsonDecode(firstJsonStr);

    final ttlDims = List<int>.from(firstJson['style_ttl']['dims']);
    final dpDims = List<int>.from(firstJson['style_dp']['dims']);

    final ttlFlat = Float32List(bsz * ttlDims[1] * ttlDims[2]);
    final dpFlat = Float32List(bsz * dpDims[1] * dpDims[2]);

    for (var i = 0; i < bsz; i++) {
      final jsonStr = await File(paths[i]).readAsString();
      final json = jsonDecode(jsonStr);

      final ttlData = flattenToDouble(json['style_ttl']['data']);
      final dpData = flattenToDouble(json['style_dp']['data']);

      ttlFlat.setRange(
        i * ttlDims[1] * ttlDims[2],
        (i + 1) * ttlDims[1] * ttlDims[2],
        ttlData,
      );
      dpFlat.setRange(
        i * dpDims[1] * dpDims[2],
        (i + 1) * dpDims[1] * dpDims[2],
        dpData,
      );
    }

    final ttlShape = [bsz, ttlDims[1], ttlDims[2]];
    final dpShape = [bsz, dpDims[1], dpDims[2]];

    return WorkerStyle(
      OrtValueTensor.createTensorWithDataList(ttlFlat, ttlShape),
      OrtValueTensor.createTensorWithDataList(dpFlat, dpShape),
      ttlShape,
      dpShape,
    );
  }

  // 2. Listen for requests from the main isolate
  workerReceivePort.listen((message) async {
    if (message is TtsWorkerRequest) {
      try {
        if (message.type == 'cancel_job') {
          currentJobId = -1; // Immediately flags the ongoing loop to halt
          message.replyPort.send(TtsWorkerResponse(message.id, result: true));
          return;
        }

        if (message.type == 'init_onnx_pipeline') {
          // Initialize Processor
          final indexerJsonStr = message.payload['indexerJsonStr'] as String;
          processor = UnicodeProcessor.fromJsonString(indexerJsonStr);

          // Initialize Configuration
          sampleRate = message.payload['sampleRate'] as int;
          baseChunkSize = message.payload['baseChunkSize'] as int;
          chunkCompressFactor = message.payload['chunkCompressFactor'] as int;
          latencyDim = message.payload['latencyDim'] as int;

          // Initialize ONNX Sessions locally in Isolate
          OrtEnv.instance.init();

          final sessionOptions = OrtSessionOptions()
            ..setIntraOpNumThreads(1)
            ..setInterOpNumThreads(1);

          // CoreML (Neural Engine) is strictly forbidden by iOS when the app runs in the background.
          // Since this TTS engine must run on the lock screen, we MUST use the CPU fallback.
          // if (Platform.isIOS || Platform.isMacOS) {
          //   sessionOptions.appendCoreMLProvider(CoreMLFlags.useNone);
          // }

          dpSession = OrtSession.fromFile(
            File(message.payload['dpPath'] as String),
            sessionOptions,
          );
          textEncSession = OrtSession.fromFile(
            File(message.payload['textEncPath'] as String),
            sessionOptions,
          );
          vectorEstSession = OrtSession.fromFile(
            File(message.payload['vectorEstPath'] as String),
            sessionOptions,
          );
          vocoderSession = OrtSession.fromFile(
            File(message.payload['vocoderPath'] as String),
            sessionOptions,
          );

          sessionOptions.release();

          // Initialize Styles locally
          if (File(message.payload['maleStylePath']).existsSync()) {
            styles['male'] = await loadVoiceStyle([
              message.payload['maleStylePath'],
            ]);
          }
          if (File(message.payload['femaleStylePath']).existsSync()) {
            styles['female'] = await loadVoiceStyle([
              message.payload['femaleStylePath'],
            ]);
          }

          message.replyPort.send(TtsWorkerResponse(message.id, result: true));
        } else if (message.type == 'infer') {
          final jobId = message.payload['jobId'] as int;
          currentJobId = jobId; // Mark as active

          final textList = message.payload['textList'] as List<String>;
          final langList = message.payload['langList'] as List<String>;
          final speaker = message.payload['speaker'] as String;
          final speed = message.payload['speed'] as double;
          final totalStep = message.payload['totalStep'] as int;

          final style = styles[speaker] ?? styles.values.firstOrNull;
          if (processor == null || style == null) {
            throw Exception('Worker not properly initialized');
          }

          final bsz = textList.length;
          final procResult = processor!.process(textList, langList);

          final textIdsRaw = procResult['textIds'];
          final textIds = (textIdsRaw as List)
              .map((row) => (row as List).cast<int>())
              .toList();
          final textMaskRaw = procResult['textMask'];
          final textMask = (textMaskRaw as List)
              .map(
                (batch) => (batch as List)
                    .map((row) => (row as List).cast<double>())
                    .toList(),
              )
              .toList();

          final textIdsShape = [bsz, textIds[0].length];
          final textMaskShape = [bsz, 1, textMask[0][0].length];

          OrtValueTensor? textIdsTensor;
          OrtValueTensor? textMaskTensor;
          OrtRunOptions? runOptions;
          OrtValueTensor? textEmbTensor;
          OrtValueTensor? latentMaskTensor;
          OrtValueTensor? totalStepTensor;
          OrtValueTensor? vocoderIn;

          try {
            textIdsTensor = intToTensor(textIds, textIdsShape);
            textMaskTensor = toTensor(textMask, textMaskShape);
            runOptions = OrtRunOptions();

            if (currentJobId != jobId) throw Exception('Job Cancelled');
            final dpResult = dpSession!.run(runOptions, {
              'text_ids': textIdsTensor,
              'style_dp': style.dp,
              'text_mask': textMaskTensor,
            });

            final durOnnxRaw = dpResult[0]?.value;
            if (durOnnxRaw == null) throw Exception('DP Output is null');
            dpResult[0]?.release(); // Release tensor to prevent leak

            final durOnnx = safeCast<double>(durOnnxRaw);
            final scaledDur = durOnnx.map((d) => d / speed).toList();

            // 2. Text Encoder
            if (currentJobId != jobId) throw Exception('Job Cancelled');
            final textEncResult = textEncSession!.run(runOptions, {
              'text_ids': textIdsTensor,
              'style_ttl': style.ttl,
              'text_mask': textMaskTensor,
            });
            textEmbTensor =
                textEncResult[0]
                    as OrtValueTensor?; // Retain for diffusion loop

            // 3. Latent Sampling
            final wavLenMax = scaledDur.reduce(math.max) * sampleRate;
            final wavLengths = scaledDur
                .map((d) => (d * sampleRate).floor())
                .toList();
            final chunkSize = baseChunkSize * chunkCompressFactor;
            final latentLen = ((wavLenMax + chunkSize - 1) / chunkSize).floor();
            final latentDim = latencyDim * chunkCompressFactor;

            final random = math.Random();
            final noisyLatent = List.generate(
              scaledDur.length,
              (_) => List.generate(
                latentDim,
                (_) => List.generate(latentLen, (_) {
                  final u1 = math.max(1e-10, random.nextDouble());
                  final u2 = random.nextDouble();
                  return math.sqrt(-2.0 * math.log(u1)) *
                      math.cos(2.0 * math.pi * u2);
                }),
              ),
            );

            final latentSize = baseChunkSize * chunkCompressFactor;
            final latentLengths = wavLengths
                .map((len) => ((len + latentSize - 1) / latentSize).floor())
                .toList();
            final maxLen = latentLengths.reduce(math.max);
            final latentMask = latentLengths
                .map(
                  (len) => [List.generate(maxLen, (i) => i < len ? 1.0 : 0.0)],
                )
                .toList();

            for (var b = 0; b < noisyLatent.length; b++) {
              for (var d = 0; d < noisyLatent[b].length; d++) {
                for (var t = 0; t < noisyLatent[b][d].length; t++) {
                  noisyLatent[b][d][t] *= latentMask[b][0][t];
                }
              }
            }

            final latentShape = [
              bsz,
              noisyLatent[0].length,
              noisyLatent[0][0].length,
            ];
            final latentMaskShape = [bsz, 1, latentMask[0][0].length];
            latentMaskTensor = toTensor(latentMask, latentMaskShape);

            totalStepTensor = scalarToTensor(
              List.filled(bsz, totalStep.toDouble()),
              [bsz],
            );

            // 4. Diffusion Loop
            for (var step = 0; step < totalStep; step++) {
              if (currentJobId != jobId) throw Exception('Job Cancelled');

              final currentNoisyTensor = toTensor(noisyLatent, latentShape);
              final currentStepTensor = scalarToTensor(
                List.filled(bsz, step.toDouble()),
                [bsz],
              );

              final modelOut = vectorEstSession!.run(runOptions, {
                'noisy_latent': currentNoisyTensor,
                'text_emb': textEmbTensor!,
                'style_ttl': style.ttl,
                'text_mask': textMaskTensor,
                'latent_mask': latentMaskTensor,
                'total_step': totalStepTensor,
                'current_step': currentStepTensor,
              });

              final denoisedRaw = modelOut[0]?.value;

              // 🚨 Strict memory release in the loop to prevent OOM
              currentNoisyTensor.release();
              currentStepTensor.release();
              modelOut[0]?.release();

              if (denoisedRaw == null) {
                throw Exception('Diffusion output is null');
              }
              final denoised = safeCast<double>(denoisedRaw);

              var idx = 0;
              for (var b = 0; b < noisyLatent.length; b++) {
                for (var d = 0; d < noisyLatent[b].length; d++) {
                  for (var t = 0; t < noisyLatent[b][d].length; t++) {
                    noisyLatent[b][d][t] = denoised[idx++];
                  }
                }
              }
            }
            // 5. Vocoder
            if (currentJobId != jobId) throw Exception('Job Cancelled');

            vocoderIn = toTensor(noisyLatent, latentShape);

            final vocoderInputName = vocoderSession!.inputNames[0];

            final vocoderOut = vocoderSession!.run(runOptions, {
              vocoderInputName: vocoderIn,
            });

            final pcmRaw = vocoderOut[0]?.value;

            // 🚨 Strict memory release in the loop to prevent OOM
            vocoderOut[0]?.release();
            if (pcmRaw == null) throw Exception('Vocoder output is null');
            final pcm = safeCast<double>(pcmRaw);
            final int16Pcm = Int16List(pcm.length);

            // 6. Audio float32 to ZERO-COPY Uint8List Converter
            for (var i = 0; i < pcm.length; i++) {
              var val = pcm[i];
              if (val > 1.0) val = 1.0;
              if (val < -1.0) val = -1.0;
              int16Pcm[i] = (val * 32767).round();
            }

            final uint8Wav = Uint8List.view(int16Pcm.buffer);

            if (currentJobId == jobId) {
              message.replyPort.send(
                TtsWorkerResponse(
                  message.id,
                  result: {'wavBytes': uint8Wav, 'duration': scaledDur},
                ),
              );
            }
          } finally {
            textIdsTensor?.release();
            textMaskTensor?.release();
            latentMaskTensor?.release();
            textEmbTensor?.release();
            totalStepTensor?.release();
            vocoderIn?.release();
            runOptions?.release();
          }
        } else if (message.type == 'dispose') {
          for (final style in styles.values) {
            style.ttl.release();
            style.dp.release();
          }
          dpSession?.release();
          textEncSession?.release();
          vectorEstSession?.release();
          vocoderSession?.release();
          OrtEnv.instance.release();
          message.replyPort.send(TtsWorkerResponse(message.id, result: true));
        } else {
          message.replyPort.send(
            TtsWorkerResponse(
              message.id,
              error: 'Unknown request type: ${message.type}',
            ),
          );
        }
      } catch (e, st) {
        if (e.toString() == 'Exception: Job Cancelled') {
          // We intentionally do not error stack for a cancelled job
          message.replyPort.send(
            TtsWorkerResponse(message.id, error: 'Cancelled'),
          );
        } else {
          message.replyPort.send(
            TtsWorkerResponse(message.id, error: '$e\n$st'),
          );
        }
      }
    }
  });
}
