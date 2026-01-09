import 'dart:convert';
import 'dart:developer' as developer;
import 'package:googleai_dart/googleai_dart.dart';
import '../../domain/entities/ai_generated_content.dart';
import 'ai_data_source.dart';

import '../constants/ai_prompts.dart';

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
    const systemInstruction = AiPrompts.autoFillInstruction;

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
    const systemInstruction = AiPrompts.notesInstruction;

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
  Future<String> generateExamples({
    required String originalText,
    required String translation,
  }) async {
    const systemInstruction = AiPrompts.examplesInstruction;

    final userPrompt =
        'ENGLISH INPUT: "$originalText"\nTRANSLATION: "$translation"';

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
