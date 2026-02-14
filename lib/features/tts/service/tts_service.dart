import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:logger/logger.dart';

import '../domain/enums/tts_speaker.dart';
import '../utils/memory_audio_source.dart';
import 'supertonic_pipeline.dart'; // Import the new pipeline

final ttsServiceProvider = Provider<TtsService>((ref) {
  return TtsService(ref);
});

class TtsService with WidgetsBindingObserver {
  final Logger _logger = Logger();
  final AudioPlayer _player = AudioPlayer();
  final SupertonicPipeline _pipeline = SupertonicPipeline(); // The pipeline

  TtsService(Ref ref) {
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

  Future<void> play(String text, TtsSpeaker speaker, {String? language}) async {
    _logger.i('Playing TTS: "$text" (Speaker: $speaker, Lang: $language)');

    try {
      List<int> audioBytes;

      try {
        // Init pipeline if needed (it handles its own init state)
        // Map TtsSpeaker to 'male' or 'female' string key
        // Assuming TtsSpeaker has .male and .female values
        // If it has others, default to male.
        final speakerKey = (speaker == TtsSpeaker.female) ? 'female' : 'male';

        // Use the pipeline for inference
        // Pipeline handles initializing loading models from app support dir
        // We currently default to English ('en') as the prompt didn't specify language passing yet.
        // However, text might be Korean.
        // Simple heuristic: if text contains Hangul, use 'ko', else 'en'
        // Use provided language or detect it
        final lang = language ?? _detectLanguage(text);

        audioBytes = await _pipeline.infer(
          text,
          lang: lang,
          speed: 1.05,
          speaker: speakerKey,
        );
        _logger.d('Generated ${audioBytes.length} bytes of audio');
      } catch (e) {
        _logger.w(
          'Supertonic Inference failed. Falling back to beep.',
          error: e,
        );
        // Fallback to beep
        audioBytes = _generateBeep();
      }

      // Play
      final source = MemoryAudioSource(
        Uint8List.fromList(audioBytes),
        sampleRate: _pipeline.sampleRate,
      );
      await _player.setAudioSource(source);
      await _player.play();
    } catch (e) {
      _logger.e('TTS Playback failed', error: e);
      rethrow;
    }
  }

  Future<void> stop() async {
    await _player.stop();
  }

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

  List<int> _generateBeep() {
    final sampleRate = 22050;
    final duration = 0.5; // Short beep
    final numSamples = (sampleRate * duration).toInt();
    final pcm = Uint8List(numSamples * 2);

    for (var i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final sample = (sin(2 * pi * 440 * t) * 32767).toInt();
      pcm[i * 2] = sample & 0xFF; // Low byte
      pcm[i * 2 + 1] = (sample >> 8) & 0xFF; // High byte
    }
    return pcm;
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
  }
}
