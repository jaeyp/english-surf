import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:googleai_dart/googleai_dart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/repositories/ai_repository.dart';
import '../repositories/ai_repository_impl.dart';

part 'ai_providers.g.dart';

@riverpod
AiRepository aiRepository(Ref ref) {
  final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  if (apiKey.trim().isEmpty) {
    throw Exception(
      'GEMINI_API_KEY is missing or empty in .env. '
      'Current .env keys: ${dotenv.env.keys.join(', ')}',
    );
  }

  // Using googleai_dart v3.0.0 with v1beta API version.
  final client = GoogleAIClient(
    config: GoogleAIConfig.googleAI(
      apiVersion: ApiVersion.v1beta,
      authProvider: ApiKeyProvider(apiKey),
    ),
  );

  final modelName = dotenv.env['AI_MODEL'] ?? 'gemini-2.5-flash-lite';
  return AiRepositoryImpl(client, modelName: modelName);
}
