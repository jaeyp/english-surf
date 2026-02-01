import 'package:flutter_test/flutter_test.dart';
import 'package:english_surf/features/sentences/data/datasources/base_ai_data_source.dart';
import 'package:english_surf/features/sentences/domain/enums/difficulty.dart';

void main() {
  group('BaseAiDataSource.parseResponse', () {
    test('successfully parses clean JSON content', () {
      const mockJson = '''
{
  "translation": "테스트 번역",
  "difficulty": "beginner",
  "notes": "테스트 노트",
  "paraphrases": "Example 1\\nExample 2"
}
''';

      final result = BaseAiDataSource.parseResponse(mockJson);

      expect(result.translation, '테스트 번역');
      expect(result.difficulty, Difficulty.beginner);
      expect(result.notes, '테스트 노트');
      expect(result.paraphrases, 'Example 1\nExample 2');
    });

    test('successfully parses AI content wrapped in markdown code blocks', () {
      const mockJson = '''
```json
{
  "translation": "마크다운 번역",
  "difficulty": "intermediate",
  "notes": "마크다운 노트",
  "paraphrases": "Markdown Example"
}
```
''';

      final result = BaseAiDataSource.parseResponse(mockJson);

      expect(result.translation, '마크다운 번역');
      expect(result.difficulty, Difficulty.intermediate);
      expect(result.notes, '마크다운 노트');
      expect(result.paraphrases, 'Markdown Example');
    });

    test('throws exception when response is invalid JSON', () {
      const mockJson = 'Invalid JSON';

      expect(() => BaseAiDataSource.parseResponse(mockJson), throwsException);
    });

    test('successfully parses complex multi-note response', () {
      const mockJson = '''
{
  "translation": "심한 감기에 걸려서 회의를 취소해야 했어요.",
  "notes": "call off: (이미 계획된 행사 등을) 취소하다\\ncome down with: (심각하지 않은 병에) 걸리다/앓아눕다\\nnasty: (상황, 병 등이) 심한, 고약한",
  "paraphrases": "They decided to call off the picnic due to rain.\\nI think I'm coming down with the flu.\\nThat's a nasty cough you've got there."
}
''';

      final result = BaseAiDataSource.parseResponse(mockJson);

      expect(result.translation, '심한 감기에 걸려서 회의를 취소해야 했어요.');
      expect(result.notes, contains('call off'));
      expect(result.notes, contains('come down with'));
      expect(result.notes, contains('nasty'));
      expect(result.notes.split('\n').length, 3);
      expect(result.paraphrases.split('\n').length, 3);
    });

    test('throws exception when some keys are missing', () {
      const mockJson = '{"translation": "missing other keys"}';

      expect(() => BaseAiDataSource.parseResponse(mockJson), throwsException);
    });
  });
}
