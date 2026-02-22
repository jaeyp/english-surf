import '../domain/enums/tts_engine_type.dart';
import 'tts_pipeline.dart';
import 'supertonic_pipeline.dart';
import 'qwen3_pipeline.dart';

/// Creates the appropriate [TtsPipeline] instance for the given [engine].
TtsPipeline createTtsPipeline(TtsEngineType engine) {
  switch (engine) {
    case TtsEngineType.supertonic2:
      return SupertonicPipeline();
    case TtsEngineType.qwen3:
      return Qwen3Pipeline();
  }
}
