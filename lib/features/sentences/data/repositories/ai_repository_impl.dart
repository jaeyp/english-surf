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
    final targetSection =
        (targetExpressions != null && targetExpressions.isNotEmpty)
        ? '\nTARGET EXPRESSIONS: ${targetExpressions.join(", ")}\n(CRITICAL: ONLY generate notes and examples for these specific expressions. Do not pick others.)\n'
        : '';

    final prompt =
        '''
You are a modern English tutor. HELP learners master NATURALLY USED phrasal verbs and important vocabulary.

INPUT SENTENCE: "$originalText"
$targetSection
TASK:
1. "translation": A natural Korean translation.
2. "difficulty": Categorize the sentence into one of: beginner, intermediate, advanced.
3. "notes": Identify 1 to 3 key natural expressions (phrasal verbs or essential vocabulary) actually used in modern daily conversation. 
   - CRITICAL: DO NOT use outdated or "old-fashioned" idioms (e.g., "piece of cake", "raining cats and dogs").
   - FLEXIBILITY: Only generate the number of notes that are truly meaningful. If a sentence is simple, 1 note is enough. Do not force 3 notes.
   - Separate each item with a newline character (\\n).
4. "examples": For EACH expression identified in "notes", provide 1-2 daily life examples.
   - Examples must identify the same pattern/expression.
   - Use casual, natural daily talk.
   - Separate examples with a newline character (\\n).

OUTPUT FORMAT: Return ONLY a valid JSON object. All values must be plain strings.

EXAMPLES:
Simple Example:
Input: "I usually get up at 7."
Output: {
  "translation": "나는 보통 7시에 일어난다.",
  "difficulty": "beginner",
  "notes": "get up: (잠자리에서) 일어나다",
  "examples": "I find it hard to get up early on Mondays.\\nWhat time do you usually get up?"
}

Complex Example:
Input: "I had to call off the meeting because I came down with a nasty cold."
Output: {
  "translation": "심한 감기에 걸려서 회의를 취소해야 했어요.",
  "difficulty": "advanced",
  "notes": "call off: (이미 계획된 행사 등을) 취소하다\\ncome down with: (심각하지 않은 병에) 걸리다/앓아눕다\\nnasty: (상황, 병 등이) 심한, 고약한",
  "examples": "They decided to call off the picnic due to rain.\\nI think I'm coming down with the flu.\\nThat's a nasty cough you've got there."
}

Now generate for: "$originalText"
''';

    developer.log(
      'AI Request - Original text: $originalText',
      name: 'AiRepository',
    );

    final response = await _client.models.generateContent(
      model: 'gemini-2.5-flash-lite',
      request: GenerateContentRequest(contents: [Content.text(prompt)]),
    );

    final text = response.text;
    developer.log('AI Response - Raw text: $text', name: 'AiRepository');

    if (text == null || text.isEmpty) {
      developer.log(
        'AI Response - ERROR: Response was empty',
        name: 'AiRepository',
      );
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
