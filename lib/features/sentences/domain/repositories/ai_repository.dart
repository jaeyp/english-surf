import '../entities/ai_generated_content.dart';

abstract class AiRepository {
  Future<AiGeneratedContent> generateSentenceContent(
    String originalText, {
    List<String>? targetExpressions,
    String? existingTranslation,
  });

  Future<String> generateNotes(String originalText);

  Future<String> generateEnglishOriginal({required String translation});

  Future<String> generateParaphrases({
    required String originalText,
    required String translation,
  });
}
