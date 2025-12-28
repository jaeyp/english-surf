import '../entities/ai_generated_content.dart';

abstract class AiRepository {
  Future<AiGeneratedContent> generateSentenceContent(String originalText);
}
