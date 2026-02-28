import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle, RootIsolateToken;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:logger/logger.dart';
import 'dart:async';
import 'dart:convert';
import 'tts_pipeline.dart';
import 'tts_worker_isolate.dart';

class SupertonicPipeline implements TtsPipeline {
  final Logger _logger = Logger();

  // The engine is entirely hosted inside this Worker Isolate
  TtsWorkerIsolate? _worker;

  // Helpers
  Map<String, dynamic>? _config; // tts.json

  // Config values
  int _sampleRate = 24000;
  int _baseChunkSize = 16;
  int _chunkCompressFactor = 1;
  int _latencyDim = 64;

  // Job Cancellation Control
  int _currentJobId = 0;

  @override
  int get sampleRate => _sampleRate;

  bool _isInitialized = false;
  Future<void>? _initFuture;

  SupertonicPipeline();

  @override
  Future<void> init() async {
    if (_isInitialized) return;
    if (_initFuture != null) return _initFuture;

    _initFuture = _doInit();
    try {
      await _initFuture;
      _isInitialized = true;
    } finally {
      _initFuture = null;
    }
  }

  Future<void> _doInit() async {
    try {
      final dir = await getApplicationSupportDirectory();

      // Define files to prepare (map of assetKey -> targetFileName)
      // assetKey is relative to 'flutter_assets' root effectively, usually 'assets/tts/...'
      final models = [
        'duration_predictor.onnx',
        'text_encoder.onnx',
        'vector_estimator.onnx',
        'vocoder.onnx',
      ];

      final configs = [
        'tts.json',
        'unicode_indexer.json',
        'M2.json',
        'F2.json',
      ];

      // Map to store resolved paths
      final resolvedPaths = <String, String>{};

      // 1. Try to find assets in the App Bundle (iOS Zero-Copy)
      if (Platform.isIOS || Platform.isMacOS) {
        try {
          final bundleDir = File(Platform.resolvedExecutable).parent;
          // Common locations for flutter_assets in iOS builds
          final candidates = [
            p.join(
              bundleDir.path,
              'Frameworks',
              'App.framework',
              'flutter_assets',
            ),
            p.join(
              bundleDir.path,
              'flutter_assets',
            ), // Sometimes here in debug/other configs
          ];

          for (final candidate in candidates) {
            if (await Directory(candidate).exists()) {
              _logger.i('Found flutter_assets at $candidate');

              // Check if all critical models exist here
              bool allFound = true;
              for (final m in models) {
                if (!File(
                  p.join(candidate, 'assets', 'tts', 'supertonic2', m),
                ).existsSync()) {
                  allFound = false;
                  break;
                }
              }

              if (allFound) {
                // Use these paths directly!
                for (final m in models) {
                  resolvedPaths[m] = p.join(
                    candidate,
                    'assets',
                    'tts',
                    'supertonic2',
                    m,
                  );
                }
                for (final c in configs) {
                  // Configs might not be strictly required to exist, but if models are there, these likely are too.
                  final configPath = p.join(
                    candidate,
                    'assets',
                    'tts',
                    'supertonic2',
                    c,
                  );
                  if (File(configPath).existsSync()) {
                    resolvedPaths[c] = configPath;
                  }
                }
                _logger.i('Using direct asset paths (Zero-Copy) from Bundle.');
                break;
              }
            }
          }
        } catch (e) {
          _logger.w('Failed to resolve bundle path', error: e);
        }
      }

      // 2. If not found in bundle (e.g. Android), fallback to Copy-to-Documents
      for (var fileName in [...models, ...configs]) {
        if (resolvedPaths.containsKey(fileName)) continue;

        // Destination path
        final filePath = p.join(dir.path, fileName);
        resolvedPaths[fileName] = filePath;

        // Copy if needed (Android or fallback)
        if (!File(filePath).existsSync()) {
          try {
            _logger.d('Copying $fileName to $filePath');
            await _copyAssetToFile(
              'assets/tts/supertonic2/$fileName',
              filePath,
            );
          } catch (e) {
            _logger.w('Failed to copy $fileName', error: e);
          }
        }
      }

      // Define paths from resolved map
      final dpPath = resolvedPaths['duration_predictor.onnx']!;
      final textEncPath = resolvedPaths['text_encoder.onnx']!;
      final vectorEstPath = resolvedPaths['vector_estimator.onnx']!;
      final vocoderPath = resolvedPaths['vocoder.onnx']!;

      final indexerPath = resolvedPaths['unicode_indexer.json']!;
      final configPath = resolvedPaths['tts.json']!;
      final maleStylePath = resolvedPaths['M2.json']!;
      final femaleStylePath = resolvedPaths['F2.json']!;

      if (!File(dpPath).existsSync()) {
        _logger.w('Models not found. Skipping init.');
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

      // Initialize the Fully Automated Worker Isolate
      _worker = TtsWorkerIsolate();
      await _worker!.init(RootIsolateToken.instance!);

      final indexerJsonStr = await File(indexerPath).readAsString();

      await _worker!.sendRequest('init_onnx_pipeline', {
        'indexerJsonStr': indexerJsonStr,
        'dpPath': dpPath,
        'textEncPath': textEncPath,
        'vectorEstPath': vectorEstPath,
        'vocoderPath': vocoderPath,
        'maleStylePath': maleStylePath,
        'femaleStylePath': femaleStylePath,
        'sampleRate': _sampleRate,
        'baseChunkSize': _baseChunkSize,
        'chunkCompressFactor': _chunkCompressFactor,
        'latencyDim': _latencyDim,
      });

      _logger.i('SupertonicPipeline Initialized in Fully Isolated Context');
    } catch (e) {
      final errStr = e.toString();
      if (errStr.contains('Future already completed')) {
        _logger.w(
          'Swallowed benign double-completion error from Native: $errStr',
        );
        return; // Proceed normally, natively cached Futures are not fatal
      }

      _logger.e('Failed to initialize SupertonicPipeline', error: e);
      _worker?.dispose();
      rethrow;
    }
  }

  @override
  Future<List<int>> infer(
    String text, {
    String lang = 'en',
    double speed = 1.05,
    String speaker = 'male',
  }) async {
    if (!_isInitialized) await init();

    if (!_isInitialized || _worker == null) {
      throw Exception('Pipeline not ready (Worker Isolate failed)');
    }

    final maxLen = lang == 'ko' ? 120 : 300;
    final chunks = _chunkText(text, maxLen: maxLen);
    final langList = List.filled(chunks.length, lang);
    final silenceDuration = 0.3;

    // Track a new Job ID and send cancellation to previous jobs
    final jobId = ++_currentJobId;

    // Send a cancellation signal to the isolate to abort old job runs
    // This allows fluid card swiping in Study Mode
    unawaited(_worker!.sendRequest('cancel_job', {}));

    // We accumulate PCM Bytes
    final pcmCat = <int>[];

    try {
      for (var i = 0; i < chunks.length; i++) {
        // Stop fetching if we've been superseded by a new swipe/audio request
        if (_currentJobId != jobId) {
          _logger.i('Job $jobId explicitly cancelled on Main Thread');
          return [];
        }

        final response = await _worker!.sendRequest('infer', {
          'jobId': jobId,
          'textList': [chunks[i]],
          'langList': [langList[i]],
          'speaker': speaker,
          'speed': speed,
          'totalStep': 5,
        });

        final result = response as Map<String, dynamic>;

        // Zero-copy receiving from Isolate!
        final uint8Wav = result['wavBytes'] as Uint8List;

        if (pcmCat.isEmpty) {
          pcmCat.addAll(uint8Wav);
        } else {
          // Append silence
          final silenceSamples = (silenceDuration * _sampleRate).floor();
          // Int16 occupies 2 bytes each, so multiply by 2 for Uint8List layout
          pcmCat.addAll(List.filled(silenceSamples * 2, 0));
          pcmCat.addAll(uint8Wav);
        }
      }

      if (pcmCat.isEmpty) return [];

      // Wrap raw PCM with WAV header and stream it directly
      return pcmCat;
    } catch (e) {
      if (e.toString().contains('Cancelled')) {
        _logger.i('Job $jobId interrupted gracefully during Inference');
        return [];
      }
      rethrow;
    }
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

  Future<void> _copyAssetToFile(String assetPath, String targetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final buffer = data.buffer;
    await File(
      targetPath,
    ).writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  @override
  Future<void> dispose() async {
    _worker?.dispose();
    _isInitialized = false;
  }
}
