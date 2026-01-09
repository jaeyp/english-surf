import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../../domain/entities/ai_generated_content.dart';
import 'ai_data_source.dart';

import '../constants/ai_prompts.dart';

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
    const systemInstruction = AiPrompts.autoFillInstruction;

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
    const systemInstruction = AiPrompts.notesInstruction;

    final text = await _callGroqApi(
      prompt: 'ENGLISH INPUT: "$originalText"',
      systemInstruction: systemInstruction,
      jsonMode: false,
    );

    return text.replaceAll('```', '').trim();
  }

  @override
  Future<String> generateExamples({
    required String originalText,
    required String translation,
  }) async {
    const systemInstruction = AiPrompts.examplesInstruction;

    final userPrompt =
        'ENGLISH INPUT: "$originalText"\nTRANSLATION: "$translation"';

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
