import '../../domain/entities/ai_generated_content.dart';

abstract class AiDataSource {
  Future<AiGeneratedContent> generateSentenceContent(
    String originalText, {
    List<String>? targetExpressions,
    String? existingTranslation,
    String sourceLang = 'English',
    String targetLang = 'Korean',
    String? notesLang,
  });

  Future<String> generateNotes(
    String originalText, {
    String sourceLang = 'English',
    String? notesLang,
  });

  Future<String> generateEnglishOriginal({
    required String translation,
    String sourceLang = 'English',
    String targetLang = 'Korean',
  });

  Future<String> generateParaphrases({
    required String originalText,
    required String translation,
    String sourceLang = 'English',
  });
}
