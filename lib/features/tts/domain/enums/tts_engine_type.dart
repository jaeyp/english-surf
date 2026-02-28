import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Available on-device TTS engines.
enum TtsEngineType { supertonic2, qwen3 }

/// Returns the active TTS engine based on the TTS_ENGINE value in .env.
/// Defaults to [TtsEngineType.supertonic2] if unset or invalid.
TtsEngineType get activeTtsEngine {
  final value = dotenv.env['TTS_ENGINE'] ?? 'supertonic2';
  return TtsEngineType.values.firstWhere(
    (e) => e.name == value,
    orElse: () => TtsEngineType.supertonic2,
  );
}
