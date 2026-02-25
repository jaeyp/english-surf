import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:logger/logger.dart';

import '../domain/enums/tts_engine_type.dart';
import '../domain/enums/tts_speaker.dart';
import 'tts_pipeline.dart';
import 'tts_pipeline_factory.dart';

final ttsServiceProvider = Provider<TtsService>((ref) {
  return TtsService(ref);
});

class TtsService with WidgetsBindingObserver {
  final Logger _logger = Logger();
  final AudioPlayer _player = AudioPlayer();
  final TtsPipeline _pipeline = createTtsPipeline(activeTtsEngine);

  TtsService(Ref ref) {
    // Single persistent listener to unlock the UI when playback finishes
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _updateCurrentId(null);
      }
    });

    _initAudioSession();
    WidgetsBinding.instance.addObserver(this);

    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(this);
      dispose();
    });
  }

  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
  }

  /// Pre-initializes the TTS pipeline (copies assets, loads models).
  /// Call this during splash screen to avoid lag on first playback.
  Future<void> init() async {
    await _pipeline.init();
  }

  int _generationId = 0; // Guard against race conditions

  final _currentPlayingIdController = StreamController<String?>.broadcast();
  Stream<String?> get currentPlayingIdStream =>
      _currentPlayingIdController.stream;

  Future<void> play(
    String text,
    TtsSpeaker speaker, {
    String? language,
    double speed = 1.0,
    String? id,
  }) async {
    // 1. Cancel/Invalidate previous requests
    _generationId++;
    final myGenerationId = _generationId;

    _updateCurrentId(id);

    _logger.i(
      'Playing TTS: "$text" (Speaker: $speaker, Lang: $language, Speed: $speed, ID: $id)',
    );

    try {
      List<int> audioBytes = [];

      try {
        final speakerKey = (speaker == TtsSpeaker.female) ? 'female' : 'male';
        final lang = language ?? _detectLanguage(text);

        // Check cancellation before heavy lifting
        if (myGenerationId != _generationId) return;

        audioBytes = await _pipeline.infer(
          text,
          lang: lang,
          speed: speed,
          speaker: speakerKey,
        );
      } catch (e) {
        if (myGenerationId != _generationId) return;
        _logger.w('Pipeline Inference failed. ', error: e);
        _updateCurrentId(null);
        return;
      }

      // 2. Critical Check: Is this request still valid?
      // If stop() or another play() was called during inference, abort.
      if (myGenerationId != _generationId || audioBytes.isEmpty) {
        _logger.d(
          'TTS Cancelled before play (Generation mismatched or empty audio)',
        );
        if (myGenerationId == _generationId) {
          _updateCurrentId(null); // Ensure UI unlocks if audio is empty
        }
        return;
      }

      // Play directly from RAM Stream (RawPcmAudioSource)
      final source = RawPcmAudioSource(
        Uint8List.fromList(audioBytes),
        sampleRate: _pipeline.sampleRate,
      );

      await _player.stop();
      await _player.setAudioSource(source, preload: true);

      if (myGenerationId != _generationId) return;

      await _player.seek(Duration.zero);
      await _player.play();
    } catch (e) {
      if (myGenerationId != _generationId) return;
      _updateCurrentId(null);
      _logger.e('TTS Playback failed', error: e);
      rethrow;
    }
  }

  Future<void> stop() async {
    _generationId++; // Invalidate any pending play requests
    _updateCurrentId(null);
    await _player.stop();
  }

  void _updateCurrentId(String? id) {
    _currentPlayingIdController.add(id);
  }

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  String _detectLanguage(String text) {
    int esCount = 0;
    int ptCount = 0;
    int frCount = 0;

    for (var rune in text.runes) {
      // Korean (Hangul Syllables)
      if (rune >= 0xAC00 && rune <= 0xD7A3) return 'ko';

      // Spanish unique(ish)
      if ('¿¡ñ'.contains(String.fromCharCode(rune))) esCount += 5;
      if ('áéíóú'.contains(String.fromCharCode(rune))) esCount += 1;

      // Portuguese unique(ish)
      if ('ãõ'.contains(String.fromCharCode(rune))) ptCount += 5;
      if ('êô'.contains(String.fromCharCode(rune))) ptCount += 1;

      // French unique(ish)
      if ('àèùœ'.contains(String.fromCharCode(rune))) frCount += 5;
      if ('ç'.contains(String.fromCharCode(rune))) {
        // ç is common in pt and fr
        ptCount += 2;
        frCount += 2;
      }
    }

    // Heuristic winner
    if (esCount > 0 && esCount >= ptCount && esCount >= frCount) return 'es';
    if (ptCount > 0 && ptCount >= esCount && ptCount >= frCount) return 'pt';
    if (frCount > 0 && frCount >= esCount && frCount >= ptCount) return 'fr';

    // Default to English
    return 'en';
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // App went to background: Release heavyweight ONNX resources
      _logger.d('App paused: Disposing ONNX sessions');
      _pipeline.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // App came to foreground: Sessions will be lazy-reloaded on next infer(),
      // or we can pre-warm them here.
      _logger.d('App resumed: Pipeline will re-init on demand');
      // optional: _pipeline.init();
    }
  }

  void dispose() {
    _player.dispose();
    _pipeline.dispose();
    _currentPlayingIdController.close();
  }
}

/// Dynamic Audio Source for just_audio
/// Streams entirely from RAM, appending a WAV Header to raw Mono PCM16 payload
class RawPcmAudioSource extends StreamAudioSource {
  final Uint8List _pcmBytes;
  final int sampleRate;

  RawPcmAudioSource(this._pcmBytes, {required this.sampleRate});

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    final header = _buildWavHeader(_pcmBytes.length, sampleRate);
    final totalBytes = header.length + _pcmBytes.length;

    start ??= 0;
    end ??= totalBytes;

    if (start >= totalBytes) {
      return StreamAudioResponse(
        sourceLength: totalBytes,
        contentLength: 0,
        offset: start,
        stream: Stream.empty(),
        contentType: 'audio/wav',
      );
    }

    final chunkBuilder = BytesBuilder();

    // Check if requested range overlaps with the header
    if (start < header.length) {
      final headerEnd = math.min(end, header.length);
      chunkBuilder.add(header.sublist(start, headerEnd));
    }

    // Check if requested range overlaps with the PCM payload
    if (end > header.length) {
      final pcmStart = math.max(0, start - header.length);
      final pcmEnd = end - header.length;
      chunkBuilder.add(_pcmBytes.sublist(pcmStart, pcmEnd));
    }

    return StreamAudioResponse(
      sourceLength: totalBytes,
      contentLength: chunkBuilder.length,
      offset: start,
      stream: Stream.value(chunkBuilder.takeBytes()),
      contentType: 'audio/wav',
    );
  }

  Uint8List _buildWavHeader(int pcmLength, int sampleRate) {
    final channels = 1;
    final byteRate = sampleRate * channels * 2;
    final header = Uint8List(44);
    final data = ByteData.view(header.buffer);

    data.setUint32(0, 0x52494646, Endian.big); // "RIFF"
    data.setUint32(4, 36 + pcmLength, Endian.little); // File size
    data.setUint32(8, 0x57415645, Endian.big); // "WAVE"
    data.setUint32(12, 0x666D7420, Endian.big); // "fmt "
    data.setUint32(16, 16, Endian.little); // Subchunk1Size
    data.setUint16(20, 1, Endian.little); // AudioFormat (1 = PCM)
    data.setUint16(22, channels, Endian.little); // NumChannels
    data.setUint32(24, sampleRate, Endian.little); // SampleRate
    data.setUint32(28, byteRate, Endian.little); // ByteRate
    data.setUint16(32, channels * 2, Endian.little); // BlockAlign
    data.setUint16(34, 16, Endian.little); // BitsPerSample
    data.setUint32(36, 0x64617461, Endian.big); // "data"
    data.setUint32(40, pcmLength, Endian.little); // Subchunk2Size

    return header;
  }
}
