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
    String originalText,
  ) async {
    final prompt =
        '''
You are a creative English tutor helping Korean learners master idiomatic expressions.

INPUT SENTENCE: "$originalText"

TASK:
1. "translation": A natural Korean translation.
2. "notes": Key phrasal verbs or vocabulary notes (separates with newline character).
3. "examples": Generate 2-4 example sentences that:
   - Focus ONLY on the KEY EXPRESSION/PHRASAL VERB identified in notes (show examples using ONLY that key expression, NOT copying the full sentence structure)
   - Each example should have a COMPLETELY DIFFERENT sentence structure
   - VARY sentence types: statements, questions, exclamations, conditionals
   - VARY tenses: present, past, future, perfect
   - Write casual examples that people actually use in daily talk.
   ENGLISH ONLY. Single string, separate examples with newline character.

OUTPUT FORMAT: Return ONLY a valid JSON object. All values must be plain strings.

EXAMPLE:
If input is "I'm looking forward to seeing you.", output should be:
{"translation": "너를 만나기를 고대하고 있어.", "notes": "look forward to + V-ing: ~을 기대하다/고대하다", "examples": "I'm looking forward to the weekend.\\nWe're really looking forward to working with you.\\nCan't wait to see you! (casual)"}

If input is "I've never tried to fix a sink before, but here goes nothing!", the KEY expression is "here goes nothing" (not the whole sentence). Output should be:
{"translation": "싱크대를 고쳐본 적은 없지만, 한번 해보지 뭐!", "notes": "here goes nothing: 밑져야 본전이지, 한번 해보지 뭐 (불확실하지만 시도할 때)", "examples": "I'm about to hit the 'send' button on this risky email, so here goes nothing.\\nOkay, here goes nothing. Wish me luck.\\nShe took a deep breath and thought, 'Here goes nothing.'\\nAfter months of preparation, here goes nothing—time to launch the startup."}

Now generate for: "$originalText"
''';

    developer.log(
      'AI Request - Original text: $originalText',
      name: 'AiRepository',
    );

    final response = await _client.models.generateContent(
      model: 'gemini-2.0-flash',
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
      developer.log(
        'translation: ${data['translation']}',
        name: 'AiRepository',
      );
      developer.log('notes: ${data['notes']}', name: 'AiRepository');
      developer.log('examples: ${data['examples']}', name: 'AiRepository');

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
