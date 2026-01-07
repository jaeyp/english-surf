import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../../domain/entities/ai_generated_content.dart';
import 'ai_data_source.dart';

class GroqAiDataSource implements AiDataSource {
  final String _apiKey;
  final String _modelName;
  final http.Client _client;

  static const String _baseUrl =
      'https://api.groq.com/openai/v1/chat/completions';

  GroqAiDataSource({
    required String apiKey,
    required String modelName,
    http.Client? client,
  }) : _apiKey = apiKey,
       _modelName = modelName,
       _client = client ?? http.Client();

  Future<String> _callGroqApi({
    required String prompt,
    required String systemInstruction,
    bool jsonMode = false,
  }) async {
    final body = {
      'model': _modelName,
      'messages': [
        {'role': 'system', 'content': systemInstruction},
        {'role': 'user', 'content': prompt},
      ],
      if (jsonMode) 'response_format': {'type': 'json_object'},
    };

    developer.log(
      'Groq AI Request - Model: $_modelName',
      name: 'GroqAiDataSource',
    );

    try {
      final response = await _client.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Groq API Error: ${response.statusCode} ${response.body}',
        );
      }

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final content = data['choices'][0]['message']['content'] as String;
      return content;
    } catch (e) {
      developer.log(
        'Groq API Exception: $e',
        name: 'GroqAiDataSource',
        error: e,
      );
      rethrow;
    }
  }

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

Return JSON object.
''';

    final userPrompt =
        (targetExpressions != null && targetExpressions.isNotEmpty)
        ? 'ENGLISH INPUT: "$originalText"\nTARGET: ${targetExpressions.join(", ")}'
        : 'ENGLISH INPUT: "$originalText"';

    final text = await _callGroqApi(
      prompt: userPrompt,
      systemInstruction: systemInstruction,
      jsonMode: true,
    );

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

    final text = await _callGroqApi(
      prompt: 'ENGLISH INPUT: "$originalText"',
      systemInstruction: systemInstruction,
      jsonMode: false,
    );

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

    final text = await _callGroqApi(
      prompt: userPrompt,
      systemInstruction: systemInstruction,
      jsonMode: false,
    );

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
