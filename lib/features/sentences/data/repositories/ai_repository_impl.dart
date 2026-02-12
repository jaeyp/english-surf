import '../../domain/entities/ai_generated_content.dart';
import '../../domain/repositories/ai_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/enums/ai_provider.dart';
import '../datasources/ai_data_source.dart';

class AiRepositoryImpl implements AiRepository {
  final SettingsRepository _settingsRepository;
  final Map<AiProvider, AiDataSource> _dataSources;

  AiRepositoryImpl({
    required SettingsRepository settingsRepository,
    required Map<AiProvider, AiDataSource> dataSources,
  }) : _settingsRepository = settingsRepository,
       _dataSources = dataSources;

  Future<AiDataSource> _getCurrentDataSource() async {
    final provider = await _settingsRepository.getAiProvider();
    final dataSource = _dataSources[provider];
    if (dataSource == null) {
      throw Exception('Data source not found for provider: $provider');
    }
    return dataSource;
  }

  @override
  Future<AiGeneratedContent> generateSentenceContent(
    String originalText, {
    List<String>? targetExpressions,
    String? existingTranslation,
    String sourceLang = 'English',
    String targetLang = 'Korean',
    String? notesLang,
  }) async {
    final dataSource = await _getCurrentDataSource();
    return dataSource.generateSentenceContent(
      originalText,
      targetExpressions: targetExpressions,
      existingTranslation: existingTranslation,
      sourceLang: sourceLang,
      targetLang: targetLang,
      notesLang: notesLang,
    );
  }

  @override
  Future<String> generateNotes(
    String originalText, {
    String sourceLang = 'English',
    String? notesLang,
  }) async {
    final dataSource = await _getCurrentDataSource();
    return dataSource.generateNotes(
      originalText,
      sourceLang: sourceLang,
      notesLang: notesLang,
    );
  }

  @override
  Future<String> generateEnglishOriginal({
    required String translation,
    String sourceLang = 'English',
    String targetLang = 'Korean',
  }) async {
    final dataSource = await _getCurrentDataSource();
    return dataSource.generateEnglishOriginal(
      translation: translation,
      sourceLang: sourceLang,
      targetLang: targetLang,
    );
  }

  @override
  Future<String> generateParaphrases({
    required String originalText,
    required String translation,
    String sourceLang = 'English',
  }) async {
    final dataSource = await _getCurrentDataSource();
    return dataSource.generateParaphrases(
      originalText: originalText,
      translation: translation,
      sourceLang: sourceLang,
    );
  }
}
