import 'dart:convert';
import 'dart:developer' as developer;
import 'package:googleai_dart/googleai_dart.dart';
import '../../domain/entities/ai_generated_content.dart';
import '../../domain/repositories/ai_repository.dart';

class AiRepositoryImpl implements AiRepository {
  final GoogleAIClient _client;

  AiRepositoryImpl(this._client);

  @override
  Future<AiGeneratedContent> generateSentenceContent(
    String originalText, {
    List<String>? targetExpressions,
  }) async {
    const systemInstruction = '''
You are a modern English tutor. Task:
1. "translation": Natural Korean translation of the input.
2. "difficulty": one of [beginner, intermediate, advanced].
3. "notes": 1-3 key English expressions (phrasal verbs/vocabulary) from the INPUT. 
   - FORMAT: "English expression: Korean meaning" (e.g., "get up: 일어나다").
   - Separate items with \\n.
4. "examples": 1-2 casual and natural ENGLISH sentences for EACH expression identified in "notes".
   - Separate with \\n.
''';

    final userPrompt =
        (targetExpressions != null && targetExpressions.isNotEmpty)
        ? 'ENGLISH INPUT: "$originalText"\nTARGET: ${targetExpressions.join(", ")}'
        : 'ENGLISH INPUT: "$originalText"';

    developer.log(
      'AI Request (Optimized) - Text: $originalText',
      name: 'AiRepository',
    );

    final response = await _client.models.generateContent(
      model: 'gemini-2.5-flash',
      request: GenerateContentRequest(
        contents: [Content.text(userPrompt)],
        systemInstruction: Content.text(systemInstruction),
        generationConfig: const GenerationConfig(
          responseMimeType: 'application/json',
        ),
      ),
    );

    final text = response.text;
    developer.log('AI Response - Raw text: $text', name: 'AiRepository');

    if (text == null || text.isEmpty) {
      throw Exception('AI response was empty');
    }

    return parseResponse(text);
  }

  static AiGeneratedContent parseResponse(String text) {
    developer.log('Parsing response...', name: 'AiRepository');
    try {
      // Sometimes AI includes markdown code blocks like ```json ... ```
      final cleanJson = text
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      developer.log('Cleaned JSON: $cleanJson', name: 'AiRepository');

      final Map<String, dynamic> data = jsonDecode(cleanJson);
      developer.log(
        'Parsed data keys: ${data.keys.toList()}',
        name: 'AiRepository',
      );

      return AiGeneratedContent.fromJson(data);
    } catch (e, stackTrace) {
      developer.log(
        'Parse error: $e',
        name: 'AiRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to parse AI response: $e\nOriginal text: $text');
    }
  }
}
