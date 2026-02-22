import 'package:logger/logger.dart';

import 'tts_pipeline.dart';

/// Stub implementation for Qwen3-TTS on-device pipeline.
///
/// This will be fully implemented once the Qwen3-TTS ONNX model
/// (INT8 quantized) is prepared and placed in assets/tts/qwen3/.
class Qwen3Pipeline implements TtsPipeline {
  final Logger _logger = Logger();

  @override
  int get sampleRate => 24000;

  @override
  Future<void> init() async {
    _logger.w(
      'Qwen3Pipeline is not yet implemented. '
      'Place the quantized ONNX model in assets/tts/qwen3/ first.',
    );
  }

  @override
  Future<List<int>> infer(
    String text, {
    String lang = 'en',
    double speed = 1.0,
    String speaker = 'male',
  }) async {
    throw UnimplementedError(
      'Qwen3Pipeline inference is not yet implemented. '
      'Set TTS_ENGINE=supertonic2 in .env to use the available engine.',
    );
  }

  @override
  void dispose() {
    // No resources to release yet.
  }
}
