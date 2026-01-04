import 'dart:convert';
import 'dart:developer' as developer;
import 'package:googleai_dart/googleai_dart.dart';
import '../../domain/entities/ai_generated_content.dart';
import '../../domain/repositories/ai_repository.dart';

class AiRepositoryImpl implements AiRepository {
  final GoogleAIClient _client;
  final String _modelName;

  AiRepositoryImpl(this._client, {required String modelName})
    : _modelName = modelName;

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
   - return as a SINGLE STRING joined by \\n. NOT a JSON array.
4. "examples": 1-2 casual and natural ENGLISH sentences for EACH expression identified in "notes".
   - return as a SINGLE STRING joined by \\n. NOT a JSON array.
   - STRICTLY ONLY English sentences. Do NOT include the expression label or key (e.g., do NOT write "expression: sentence"). Just the sentence.
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
      model: _modelName,
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

      // Robust handling: Convert List to String if necessary
      if (data['notes'] is List) {
        data['notes'] = (data['notes'] as List).join('\n');
      }
      if (data['examples'] is List) {
        data['examples'] = (data['examples'] as List).join('\n');
      }

      // Sanitization: Remove expression keys from examples if present
      if (data['examples'] is String) {
        final lines = (data['examples'] as String).split('\n');
        final cleanedLines = lines
            .map((line) {
              // Regex to remove prefix like "expression: " or "- "
              // Matches start of line, optional non-word chars, some word chars, colon, whitespace
              return line.replaceAll(RegExp(r'^.*:\s*'), '').trim();
            })
            .where((l) => l.isNotEmpty)
            .toList();
        data['examples'] = cleanedLines.join('\n');
      }

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

  @override
  Future<String> generateNotes(String originalText) async {
    const systemInstruction = '''
You are a modern English tutor. Task:
Extract 1-3 key English expressions (phrasal verbs/vocabulary) from the INPUT.
- FORMAT: "English expression: Korean meaning" (e.g., "get up: 일어나다").
- return as a SINGLE STRING joined by \\n.
- Do NOT return JSON. Just the raw string text.
''';

    developer.log(
      'AI Request (Notes) - Text: $originalText',
      name: 'AiRepository',
    );

    final response = await _client.models.generateContent(
      model: _modelName,
      request: GenerateContentRequest(
        contents: [Content.text('ENGLISH INPUT: "$originalText"')],
        systemInstruction: Content.text(systemInstruction),
      ),
    );

    final text = response.text;
    if (text == null || text.isEmpty) {
      throw Exception('AI response was empty');
    }

    // Cleanup just in case AI wraps in JSON or code blocks
    return text.replaceAll('```', '').trim();
  }

  @override
  Future<String> generateExamples({required String notes}) async {
    const systemInstruction = '''
You are a modern English tutor. Task:
Create 1-2 casual and natural ENGLISH sentences for EACH expression identified in the provided NOTES.
- NOTES CONTEXT: Use the expressions and meanings listed in notes to generate relevant examples.
- STRICTLY ONLY English sentences. 
- Do NOT include the expression label or key (e.g., do NOT write "expression: sentence"). Just the sentence.
- return as a SINGLE STRING joined by \\n.
- Do NOT return JSON. Just the raw string text.
''';

    final userPrompt = 'NOTES:\n$notes';

    developer.log(
      'AI Request (Examples) - Notes: $notes',
      name: 'AiRepository',
    );

    final response = await _client.models.generateContent(
      model: _modelName,
      request: GenerateContentRequest(
        contents: [Content.text(userPrompt)],
        systemInstruction: Content.text(systemInstruction),
      ),
    );

    final text = response.text;
    if (text == null || text.isEmpty) {
      throw Exception('AI response was empty');
    }

    // Sanitize: strip markdown and labels if present
    var cleanText = text.replaceAll('```', '').trim();
    final lines = cleanText.split('\n');
    final cleanedLines = lines
        .map((line) {
          // Regex to remove prefix like "expression: " or "- "
          return line.replaceAll(RegExp(r'^.*:\s*'), '').trim();
        })
        .where((l) => l.isNotEmpty)
        .toList();

    return cleanedLines.join('\n');
  }
}
