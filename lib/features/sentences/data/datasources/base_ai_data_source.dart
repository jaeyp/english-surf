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
    String sourceLang = 'English',
    String targetLang = 'Korean',
    String? notesLang,
  }) async {
    final systemInstruction = existingTranslation != null
        ? AiPrompts.autoFillInstructionNoTranslation(
            sourceLang: sourceLang,
            notesLang: notesLang,
          )
        : AiPrompts.autoFillInstruction(
            sourceLang: sourceLang,
            targetLang: targetLang,
            notesLang: notesLang,
          );

    final userPrompt =
        (targetExpressions != null && targetExpressions.isNotEmpty)
        ? '$sourceLang INPUT: "$originalText"\nTARGET: ${targetExpressions.join(", ")}'
        : '$sourceLang INPUT: "$originalText"';

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
  Future<String> generateNotes(
    String originalText, {
    String sourceLang = 'English',
    String? notesLang,
  }) async {
    final systemInstruction = AiPrompts.notesInstruction(
      sourceLang: sourceLang,
      notesLang: notesLang,
    );

    final text = await performRequest(
      prompt: '$sourceLang INPUT: "$originalText"',
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
  Future<String> generateEnglishOriginal({
    required String translation,
    String sourceLang = 'English',
    String targetLang = 'Korean',
  }) async {
    final systemInstruction = AiPrompts.reverseGenInstruction(
      sourceLang: sourceLang,
      targetLang: targetLang,
    );

    final text = await performRequest(
      prompt: '$targetLang INPUT: "$translation"',
      systemInstruction: systemInstruction,
      jsonMode: false,
    );

    return text.replaceAll('```', '').trim().replaceAll(RegExp(r'^\"|\"$'), '');
  }

  @override
  Future<String> generateParaphrases({
    required String originalText,
    required String translation,
    String sourceLang = 'English',
  }) async {
    final systemInstruction = AiPrompts.paraphrasesInstruction(
      sourceLang: sourceLang,
    );

    final userPrompt =
        '$sourceLang INPUT: "$originalText"\nTRANSLATION: "$translation"';

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
