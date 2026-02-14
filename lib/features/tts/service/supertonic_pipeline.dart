import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:logger/logger.dart';
import 'dart:convert';
import '../utils/unicode_processor.dart';

class Style {
  final OrtValue ttl, dp;
  final List<int> ttlShape, dpShape;
  Style(this.ttl, this.dp, this.ttlShape, this.dpShape);
}

class SupertonicPipeline {
  final Logger _logger = Logger();
  late OnnxRuntime _ort;

  // Sessions
  OrtSession? _dpSession;
  OrtSession? _textEncSession;
  OrtSession? _vectorEstSession;
  OrtSession? _vocoderSession;

  // Helpers
  UnicodeProcessor? _processor;
  Map<String, dynamic>? _config; // tts.json

  // Styles
  final Map<String, Style> _styles = {};

  // Config values
  int _sampleRate = 24000;
  int _baseChunkSize = 16;
  int _chunkCompressFactor = 1;
  int _latencyDim = 64;

  int get sampleRate => _sampleRate;

  bool _isInitialized = false;

  SupertonicPipeline() {
    _ort = OnnxRuntime();
  }

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final dir = await getApplicationSupportDirectory();

      // Define files to copy
      final filesToCopy = [
        'duration_predictor.onnx',
        'text_encoder.onnx',
        'vector_estimator.onnx',
        'vocoder.onnx',
        'tts.json',
        'unicode_indexer.json',
        'M1.json',
        'F1.json',
      ];

      for (var fileName in filesToCopy) {
        final filePath = p.join(dir.path, fileName);
        if (!File(filePath).existsSync()) {
          try {
            _logger.d('Copying $fileName to $filePath');
            await _copyAssetToFile('assets/tts/$fileName', filePath);
          } catch (e) {
            // M1/F1 might be optional if user only added one, but models are required
            _logger.w(
              'Failed to copy $fileName (might be missing in assets)',
              error: e,
            );
          }
        }
      }

      // Define paths
      final dpPath = p.join(dir.path, 'duration_predictor.onnx');
      final textEncPath = p.join(dir.path, 'text_encoder.onnx');
      final vectorEstPath = p.join(dir.path, 'vector_estimator.onnx');
      final vocoderPath = p.join(dir.path, 'vocoder.onnx');

      final indexerPath = p.join(dir.path, 'unicode_indexer.json');
      final configPath = p.join(dir.path, 'tts.json');
      final maleStylePath = p.join(dir.path, 'M1.json');
      final femaleStylePath = p.join(dir.path, 'F1.json');

      if (!File(dpPath).existsSync()) {
        _logger.w('Models not found. Skipping init until downloaded.');
        // Don't throw here, just leave uninitialized so we fallback to beep until valid.
        return;
      }

      // Load Configs
      if (File(configPath).existsSync()) {
        final cfgStr = await File(configPath).readAsString();
        _config = json.decode(cfgStr);
        _sampleRate = _config?['ae']?['sample_rate'] ?? 24000;
        _baseChunkSize = _config?['ae']?['base_chunk_size'] ?? 16;
        _chunkCompressFactor = _config?['ttl']?['chunk_compress_factor'] ?? 1;
        _latencyDim = _config?['ttl']?['latent_dim'] ?? 64;
      }

      // Load Processor
      _processor = await UnicodeProcessor.fromFile(indexerPath);

      // Load Sessions
      final sessionOptions = OrtSessionOptions(
        intraOpNumThreads: 1,
        interOpNumThreads: 1,
        providers: [OrtProvider.CPU],
      );

      _dpSession = await _ort.createSession(dpPath, options: sessionOptions);
      _textEncSession = await _ort.createSession(
        textEncPath,
        options: sessionOptions,
      );
      _vectorEstSession = await _ort.createSession(
        vectorEstPath,
        options: sessionOptions,
      );
      _vocoderSession = await _ort.createSession(
        vocoderPath,
        options: sessionOptions,
      );

      // Load Styles
      if (File(maleStylePath).existsSync()) {
        _styles['male'] = await _loadVoiceStyle([maleStylePath]);
      }
      if (File(femaleStylePath).existsSync()) {
        _styles['female'] = await _loadVoiceStyle([femaleStylePath]);
      }

      if (_styles.isEmpty) {
        _logger.w(
          'No voice styles (M1.json/F1.json) found. Inference will fail.',
        );
      }

      _isInitialized = true;
      _logger.i('SupertonicPipeline Initialized');
    } catch (e) {
      _logger.e('Failed to initialize SupertonicPipeline', error: e);
      _disposeSessions();
      rethrow;
    }
  }

  Future<List<int>> infer(
    String text, {
    String lang = 'en',
    double speed = 1.05,
    String speaker = 'male',
  }) async {
    if (!_isInitialized) await init();

    final style = _styles[speaker] ?? _styles.values.firstOrNull;

    if (!_isInitialized || _processor == null || style == null) {
      throw Exception(
        'Pipeline not ready (Missing models or style for $speaker)',
      );
    }

    final maxLen = lang == 'ko' ? 120 : 300;
    final chunks = _chunkText(text, maxLen: maxLen);
    final langList = List.filled(chunks.length, lang);
    final silenceDuration = 0.3;

    // We accumulate Float32 audio samples
    List<double> wavCat = [];

    for (var i = 0; i < chunks.length; i++) {
      final result = await _inferInternal(
        [chunks[i]],
        [langList[i]],
        style,
        5,
        speed: speed,
      ); // 5 steps default

      // result['wav'] is List<double>
      final wav = result['wav'] as List<double>;

      if (wavCat.isEmpty) {
        wavCat = wav;
      } else {
        // Append silence
        final silenceSamples = (silenceDuration * _sampleRate).floor();
        wavCat.addAll(List.filled(silenceSamples, 0.0));
        wavCat.addAll(wav);
      }
    }

    // Convert float samples to PCM Int16
    return _float32ToInt16(wavCat);
  }

  Future<Map<String, dynamic>> _inferInternal(
    List<String> textList,
    List<String> langList,
    Style style,
    int totalStep, {
    double speed = 1.05,
  }) async {
    final bsz = textList.length;
    // UnicodeProcessor.process returns map with 'textIds' and 'textMask'
    final result = _processor!.process(textList, langList);

    final textIdsRaw = result['textIds'];
    // Ensure List<List<int>>
    final textIds = (textIdsRaw as List)
        .map((row) => (row as List).cast<int>())
        .toList();

    final textMaskRaw = result['textMask'];
    // Ensure List<List<List<double>>>
    final textMask = (textMaskRaw as List)
        .map(
          (batch) => (batch as List)
              .map((row) => (row as List).cast<double>())
              .toList(),
        )
        .toList();

    final textIdsShape = [bsz, textIds[0].length];
    final textMaskShape = [bsz, 1, textMask[0][0].length];

    final textIdsTensor = await _intToTensor(textIds, textIdsShape);
    final textMaskTensor = await _toTensor(textMask, textMaskShape);

    // 1. Durataion Predictor
    final dpResult = await _dpSession!.run({
      'text_ids': textIdsTensor,
      'style_dp': style.dp, // Already tensor
      'text_mask': textMaskTensor,
    });
    // Cleanup input tensors that we created?
    // style.dp is reused, don't dispose. textIdsTensor/textMaskTensor we created this run.

    final durOnnxRaw = await dpResult.values.first.asList(); // flatten?
    final durOnnx = _safeCast<double>(durOnnxRaw); // List<double>
    final scaledDur = durOnnx.map((d) => d / speed).toList();

    // 2. Text Encoder
    final textEncResult = await _textEncSession!.run({
      'text_ids': textIdsTensor, // Re-use
      'style_ttl': style.ttl,
      'text_mask': textMaskTensor, // Re-use
    });
    final textEmbTensor =
        textEncResult.values.first; // Keep this tensor for loop

    // 3. Latent Sampling
    final latentData = _sampleNoisyLatent(scaledDur);
    final noisyLatent = latentData['noisyLatent'] as List<List<List<double>>>;
    final latentMask = latentData['latentMask'] as List<List<List<double>>>;

    final latentShape = [bsz, noisyLatent[0].length, noisyLatent[0][0].length];
    final latentMaskShape = [bsz, 1, latentMask[0][0].length];
    final latentMaskTensor = await _toTensor(latentMask, latentMaskShape);

    // 4. Diffusion Loop
    final totalStepTensor = await _scalarToTensor(
      List.filled(bsz, totalStep.toDouble()),
      [bsz],
    );

    // We need to loop. updating noisyLatent.
    // However, recreating tensor every step is slow.
    // The provided code updates the List<double> in place and blindly calls run.
    // BUT run() takes Map<String, OrtValue>.
    // The provided code: 'noisy_latent': await _toTensor(noisyLatent, latentShape)
    // So it DOES recreate the tensor every step from the updated double list.

    for (var step = 0; step < totalStep; step++) {
      // Create tensor from current state of noisyLatent list
      final currentNoisyTensor = await _toTensor(noisyLatent, latentShape);
      final currentStepTensor = await _scalarToTensor(
        List.filled(bsz, step.toDouble()),
        [bsz],
      );

      final modelOut = await _vectorEstSession!.run({
        'noisy_latent': currentNoisyTensor,
        'text_emb': textEmbTensor,
        'style_ttl': style.ttl,
        'text_mask': textMaskTensor,
        'latent_mask': latentMaskTensor,
        'total_step': totalStepTensor,
        'current_step': currentStepTensor,
      });

      final denoisedRaw = await modelOut.values.first.asList();
      final denoised = _safeCast<double>(denoisedRaw);

      // Update noisyLatent list in-place
      var idx = 0;
      for (var b = 0; b < noisyLatent.length; b++) {
        for (var d = 0; d < noisyLatent[b].length; d++) {
          for (var t = 0; t < noisyLatent[b][d].length; t++) {
            noisyLatent[b][d][t] = denoised[idx++];
          }
        }
      }

      // Cleanup step tensors
      await currentNoisyTensor.dispose(); // disposed?
      await currentStepTensor.dispose();
      for (var v in modelOut.values) {
        await v.dispose();
      }
    }

    await totalStepTensor.dispose();

    // 5. Vocoder
    final finalLatentTensor = await _toTensor(noisyLatent, latentShape);
    final vocResult = await _vocoderSession!.run({'latent': finalLatentTensor});
    final wavRaw = await vocResult.values.first.asList();
    final wav = _safeCast<double>(wavRaw);

    // Cleanup
    await textIdsTensor.dispose();
    await textMaskTensor.dispose();
    await finalLatentTensor.dispose();
    await latentMaskTensor.dispose();
    await textEmbTensor.dispose();

    for (var v in textEncResult.values) {
      if (v != textEmbTensor) await v.dispose();
    }

    for (var v in dpResult.values) {
      await v.dispose();
    }
    for (var v in vocResult.values) {
      await v.dispose();
    }

    return {'wav': wav, 'duration': scaledDur};
  }

  Map<String, dynamic> _sampleNoisyLatent(List<double> duration) {
    final wavLenMax = duration.reduce(math.max) * _sampleRate;
    // Fix: wavLengths should be int list, map returns iterable
    final wavLengths = duration.map((d) => (d * _sampleRate).floor()).toList();
    final chunkSize = _baseChunkSize * _chunkCompressFactor;
    final latentLen = ((wavLenMax + chunkSize - 1) / chunkSize).floor();
    final latentDim = _latencyDim * _chunkCompressFactor;

    final random = math.Random();
    final noisyLatent = List.generate(
      duration.length,
      (_) => List.generate(
        latentDim,
        (_) => List.generate(latentLen, (_) {
          final u1 = math.max(1e-10, random.nextDouble());
          final u2 = random.nextDouble();
          return math.sqrt(-2.0 * math.log(u1)) * math.cos(2.0 * math.pi * u2);
        }),
      ),
    );

    final latentMask = _getLatentMask(wavLengths);

    for (var b = 0; b < noisyLatent.length; b++) {
      for (var d = 0; d < noisyLatent[b].length; d++) {
        for (var t = 0; t < noisyLatent[b][d].length; t++) {
          noisyLatent[b][d][t] *= latentMask[b][0][t];
        }
      }
    }

    return {'noisyLatent': noisyLatent, 'latentMask': latentMask};
  }

  List<List<List<double>>> _getLatentMask(List<int> wavLengths) {
    final latentSize = _baseChunkSize * _chunkCompressFactor;
    final latentLengths = wavLengths
        .map((len) => ((len + latentSize - 1) / latentSize).floor())
        .toList();
    // Fix: reduce on empty list if batch is empty (unlikely)
    final maxLen = latentLengths.reduce(math.max);
    return latentLengths
        .map((len) => [List.generate(maxLen, (i) => i < len ? 1.0 : 0.0)])
        .toList();
  }

  List<String> _chunkText(String text, {int maxLen = 300}) {
    final paragraphs = text
        .trim()
        .split(RegExp(r'\n\s*\n+'))
        .where((p) => p.trim().isNotEmpty)
        .toList();

    final chunks = <String>[];
    for (var paragraph in paragraphs) {
      paragraph = paragraph.trim();
      if (paragraph.isEmpty) continue;

      final sentences = paragraph.split(
        RegExp(r'(?<!Mr\.|Mrs\.|Ms\.|Dr\.|Prof\.)(?<!\b[A-Z]\.)(?<=[.!?])\s+'),
      );

      var currentChunk = '';
      for (final sentence in sentences) {
        if (currentChunk.length + sentence.length + 1 <= maxLen) {
          currentChunk += (currentChunk.isNotEmpty ? ' ' : '') + sentence;
        } else {
          if (currentChunk.isNotEmpty) chunks.add(currentChunk.trim());
          currentChunk = sentence;
        }
      }
      if (currentChunk.isNotEmpty) chunks.add(currentChunk.trim());
    }
    return chunks;
  }

  // Helpers from provided code
  List<T> _safeCast<T>(dynamic raw) {
    if (raw is List<T>) return raw;
    if (raw is List) {
      if (raw.isNotEmpty && raw.first is List) {
        return _flattenList<T>(raw);
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
    throw Exception('Cannot convert $raw to List<$T>');
  }

  List<T> _flattenList<T>(dynamic list) {
    if (list is List) {
      return list.expand((e) => _flattenList<T>(e)).toList();
    }
    if (T == double && list is num) {
      return [list.toDouble()] as List<T>;
    }
    return [list as T];
  }

  List<double> _flattenToDouble(dynamic list) {
    if (list is List) return list.expand((e) => _flattenToDouble(e)).toList();
    return [list is num ? list.toDouble() : double.parse(list.toString())];
  }

  Future<OrtValue> _toTensor(dynamic array, List<int> dims) async {
    final flat = _flattenList<double>(array);
    return await OrtValue.fromList(Float32List.fromList(flat), dims);
  }

  Future<OrtValue> _scalarToTensor(List<double> array, List<int> dims) async {
    return await OrtValue.fromList(Float32List.fromList(array), dims);
  }

  Future<OrtValue> _intToTensor(List<List<int>> array, List<int> dims) async {
    // flatten
    final flat = array.expand((row) => row).toList();
    return await OrtValue.fromList(Int64List.fromList(flat), dims);
  }

  Future<Style> _loadVoiceStyle(List<String> paths) async {
    final bsz = paths.length; // usually 1
    // Assuming identical styles if list > 1 or just loading one for now

    final firstJsonStr = await File(paths[0]).readAsString();
    final firstJson = jsonDecode(firstJsonStr);

    final ttlDims = List<int>.from(firstJson['style_ttl']['dims']);
    final dpDims = List<int>.from(firstJson['style_dp']['dims']);

    final ttlFlat = Float32List(bsz * ttlDims[1] * ttlDims[2]);
    final dpFlat = Float32List(bsz * dpDims[1] * dpDims[2]);

    for (var i = 0; i < bsz; i++) {
      final jsonStr = await File(paths[i]).readAsString();
      final json = jsonDecode(jsonStr);

      final ttlData = _flattenToDouble(json['style_ttl']['data']);
      final dpData = _flattenToDouble(json['style_dp']['data']);

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

    return Style(
      await OrtValue.fromList(ttlFlat, ttlShape),
      await OrtValue.fromList(dpFlat, dpShape),
      ttlShape,
      dpShape,
    );
  }

  List<int> _float32ToInt16(List<double> floats) {
    final pcm = <int>[];
    for (var val in floats) {
      if (val > 1.0) val = 1.0;
      if (val < -1.0) val = -1.0;

      final sample = (val * 32767).round();
      pcm.add(sample & 0xFF);
      pcm.add((sample >> 8) & 0xFF);
    }
    return pcm;
  }

  Future<void> _copyAssetToFile(String assetPath, String targetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final file = File(targetPath);
    await file.create(recursive: true);
    await file.writeAsBytes(byteData.buffer.asUint8List());
  }

  void _disposeSessions() {
    _dpSession?.close();
    _textEncSession?.close();
    _vectorEstSession?.close();
    _vocoderSession?.close();
  }

  void dispose() {
    _disposeSessions();
  }
}
