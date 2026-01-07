import 'dart:convert';
import 'dart:developer' as developer;
import 'package:googleai_dart/googleai_dart.dart';
import '../../domain/entities/ai_generated_content.dart';
import 'ai_data_source.dart';

class GoogleAiDataSource implements AiDataSource {
  final GoogleAIClient _client;
  final String _modelName;

  GoogleAiDataSource(this._client, {required String modelName})
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
      'Google AI Request - Model: $_modelName, Text: $originalText',
      name: 'GoogleAiDataSource',
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
    if (text == null || text.isEmpty) {
      throw Exception('AI response was empty');
    }

    return parseResponse(text);
  }

  static AiGeneratedContent parseResponse(String text) {
    try {
      final cleanJson = text
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final Map<String, dynamic> data = jsonDecode(cleanJson);

      if (data['notes'] is List) {
        data['notes'] = (data['notes'] as List).join('\n');
      }
      if (data['examples'] is List) {
        data['examples'] = (data['examples'] as List).join('\n');
      }

      if (data['examples'] is String) {
        final lines = (data['examples'] as String).split('\n');
        final cleanedLines = lines
            .map((line) {
              return line.replaceAll(RegExp(r'^.*:\s*'), '').trim();
            })
            .where((l) => l.isNotEmpty)
            .toList();
        data['examples'] = cleanedLines.join('\n');
      }

      return AiGeneratedContent.fromJson(data);
    } catch (e) {
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

    var cleanText = text.replaceAll('```', '').trim();
    final lines = cleanText.split('\n');
    final cleanedLines = lines
        .map((line) {
          return line.replaceAll(RegExp(r'^.*:\s*'), '').trim();
        })
        .where((l) => l.isNotEmpty)
        .toList();

    return cleanedLines.join('\n');
  }
}
