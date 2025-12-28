import 'package:flutter_test/flutter_test.dart';
import 'package:english_surf/features/sentences/data/repositories/ai_repository_impl.dart';

void main() {
  group('AiRepositoryImpl.parseResponse', () {
    test('successfully parses clean JSON content', () {
      const mockJson = '''
{
  "translation": "테스트 번역",
  "notes": "테스트 노트",
  "examples": "Example 1\\nExample 2"
}
''';

      final result = AiRepositoryImpl.parseResponse(mockJson);

      expect(result.translation, '테스트 번역');
      expect(result.notes, '테스트 노트');
      expect(result.examples, 'Example 1\nExample 2');
    });

    test('successfully parses AI content wrapped in markdown code blocks', () {
      const mockJson = '''
```json
{
  "translation": "마크다운 번역",
  "notes": "마크다운 노트",
  "examples": "Markdown Example"
}
```
''';

      final result = AiRepositoryImpl.parseResponse(mockJson);

      expect(result.translation, '마크다운 번역');
      expect(result.notes, '마크다운 노트');
      expect(result.examples, 'Markdown Example');
    });

    test('throws exception when response is invalid JSON', () {
      const mockJson = 'Invalid JSON';

      expect(() => AiRepositoryImpl.parseResponse(mockJson), throwsException);
    });

    test('throws exception when some keys are missing', () {
      const mockJson = '{"translation": "missing other keys"}';

      expect(() => AiRepositoryImpl.parseResponse(mockJson), throwsException);
    });
  });
}
