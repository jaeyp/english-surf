import '../../domain/entities/ai_generated_content.dart';

abstract class AiDataSource {
  Future<AiGeneratedContent> generateSentenceContent(
    String originalText, {
    List<String>? targetExpressions,
  });

  Future<String> generateNotes(String originalText);

  Future<String> generateParaphrases({
    required String originalText,
    required String translation,
  });
}
