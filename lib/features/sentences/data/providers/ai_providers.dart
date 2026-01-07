import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:googleai_dart/googleai_dart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/enums/ai_provider.dart';
import '../../domain/repositories/ai_repository.dart';
import '../repositories/ai_repository_impl.dart';
import '../datasources/ai_data_source.dart';
import '../datasources/google_ai_data_source.dart';
import '../datasources/groq_ai_data_source.dart';
import '../providers/sentence_providers.dart'; // For settingsRepositoryProvider

part 'ai_providers.g.dart';

@riverpod
Future<AiRepository> aiRepository(Ref ref) async {
  final settingsRepository = ref.watch(settingsRepositoryProvider);

  // Initialize Data Sources
  final Map<AiProvider, AiDataSource> dataSources = {};

  // 1. Google AI
  final googleApiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  if (googleApiKey.trim().isNotEmpty) {
    final client = GoogleAIClient(
      config: GoogleAIConfig.googleAI(
        apiVersion: ApiVersion.v1beta,
        authProvider: ApiKeyProvider(googleApiKey),
      ),
    );

    final googleModel = await settingsRepository.getAiModel(AiProvider.google);

    dataSources[AiProvider.google] = GoogleAiDataSource(
      client,
      modelName: googleModel,
    );
  }

  // 2. Groq AI
  final groqApiKey = dotenv.env['GROQ_API_KEY'] ?? '';
  if (groqApiKey.trim().isNotEmpty) {
    final groqModel = await settingsRepository.getAiModel(AiProvider.groq);
    dataSources[AiProvider.groq] = GroqAiDataSource(
      apiKey: groqApiKey,
      modelName: groqModel,
    );
  }

  return AiRepositoryImpl(
    settingsRepository: settingsRepository,
    dataSources: dataSources,
  );
}
