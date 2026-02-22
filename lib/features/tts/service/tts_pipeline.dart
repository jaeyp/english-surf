/// Abstract interface for all on-device TTS pipelines.
///
/// Each TTS engine (Supertonic2, Qwen3, etc.) implements this interface
/// so that [TtsService] can remain engine-agnostic.
abstract class TtsPipeline {
  /// Loads models and prepares the pipeline for inference.
  Future<void> init();

  /// Converts [text] to PCM Int16 audio bytes.
  ///
  /// Parameters:
  /// - [lang]: Language code (e.g. 'en', 'ko').
  /// - [speed]: Playback speed multiplier.
  /// - [speaker]: Speaker key (e.g. 'male', 'female').
  Future<List<int>> infer(
    String text, {
    String lang = 'en',
    double speed = 1.0,
    String speaker = 'male',
  });

  /// Audio sample rate in Hz (used for WAV header generation).
  int get sampleRate;

  /// Releases all heavyweight resources (ONNX sessions, etc.).
  void dispose();
}
