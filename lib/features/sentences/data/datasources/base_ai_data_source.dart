import 'dart:convert';
import 'dart:developer' as developer;
import '../../domain/entities/ai_generated_content.dart';
import '../constants/ai_prompts.dart';
import 'ai_data_source.dart';

abstract class BaseAiDataSource implements AiDataSource {
  Future<String> performRequest({
    required String prompt,
    required String systemInstruction,
    bool jsonMode = false,
    double? temperature,
  });

  @override
  Future<AiGeneratedContent> generateSentenceContent(
    String originalText, {
    List<String>? targetExpressions,
    String? existingTranslation,
  }) async {
    final systemInstruction = existingTranslation != null
        ? AiPrompts.autoFillInstructionNoTranslation
        : AiPrompts.autoFillInstruction;

    final userPrompt =
        (targetExpressions != null && targetExpressions.isNotEmpty)
        ? 'ENGLISH INPUT: "$originalText"\nTARGET: ${targetExpressions.join(", ")}'
        : 'ENGLISH INPUT: "$originalText"';

    final text = await performRequest(
      prompt: userPrompt,
      systemInstruction: systemInstruction,
      jsonMode: true,
      temperature:
          0.3, // Lower temperature for accurate translation/definitions
    );

    return parseResponse(text, existingTranslation);
  }

  @override
  Future<String> generateNotes(String originalText) async {
    const systemInstruction = AiPrompts.notesInstruction;

    final text = await performRequest(
      prompt: 'ENGLISH INPUT: "$originalText"',
      systemInstruction: systemInstruction,
      jsonMode: true,
      temperature: 0.3,
    );

    try {
      final cleanJson = text
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      final Map<String, dynamic> data = jsonDecode(cleanJson);

      if (data['notes'] is List) {
        return (data['notes'] as List).join('\n');
      } else if (data['notes'] is String) {
        return data['notes'] as String;
      }
      return text;
    } catch (e) {
      // Fallback if JSON parsing fails, though unlikely with jsonMode: true
      return text.replaceAll('```', '').trim();
    }
  }

  @override
  Future<String> generateEnglishOriginal({required String translation}) async {
    const systemInstruction = AiPrompts.reverseGenInstruction;

    final text = await performRequest(
      prompt: 'KOREAN INPUT: "$translation"',
      systemInstruction: systemInstruction,
      jsonMode: false,
    );

    return text.replaceAll('```', '').trim().replaceAll(RegExp(r'^"|"$'), '');
  }

  @override
  Future<String> generateParaphrases({
    required String originalText,
    required String translation,
  }) async {
    const systemInstruction = AiPrompts.paraphrasesInstruction;

    final userPrompt =
        'ENGLISH INPUT: "$originalText"\nTRANSLATION: "$translation"';

    final text = await performRequest(
      prompt: userPrompt,
      systemInstruction: systemInstruction,
      jsonMode: true,
      temperature: 1.3, // Higher temperature for more variety
    );

    try {
      final cleanJson = text
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      final Map<String, dynamic> data = jsonDecode(cleanJson);

      if (data['paraphrases'] is List) {
        return (data['paraphrases'] as List).join('\n');
      } else if (data['paraphrases'] is String) {
        return data['paraphrases'] as String;
      }
      return text;
    } catch (e) {
      // Fallback if JSON parsing fails
      return text.replaceAll('```', '').trim();
    }
  }

  static AiGeneratedContent parseResponse(
    String text, [
    String? existingTranslation,
  ]) {
    try {
      final cleanJson = text
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final Map<String, dynamic> data = jsonDecode(cleanJson);

      if (existingTranslation != null) {
        data['translation'] = existingTranslation;
      }

      if (data['notes'] is List) {
        data['notes'] = (data['notes'] as List).join('\n');
      } else if (data['notes'] is String) {
        // Fallback legacy support
      }

      if (data['paraphrases'] is List) {
        data['paraphrases'] = (data['paraphrases'] as List).join('\n');
      }

      if (data['paraphrases'] is String) {
        final lines = (data['paraphrases'] as String).split('\n');
        final cleanedLines = lines
            .map((line) {
              return line.replaceAll(RegExp(r'^.*:\s*'), '').trim();
            })
            .where((l) => l.isNotEmpty)
            .toList();
        data['paraphrases'] = cleanedLines.join('\n');
      }

      return AiGeneratedContent.fromJson(data);
    } catch (e) {
      developer.log('Parse Error raw text: $text');
      throw Exception('Failed to parse AI response: $e');
    }
  }
}
