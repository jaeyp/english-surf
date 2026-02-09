import 'package:english_surf/features/sentences/data/datasources/base_ai_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

class MockAiDataSource extends BaseAiDataSource {
  String? mockResponse;
  bool capturedJsonMode = false;

  @override
  Future<String> performRequest({
    required String prompt,
    required String systemInstruction,
    bool jsonMode = false,
    double? temperature,
  }) async {
    capturedJsonMode = jsonMode;
    return mockResponse ?? '';
  }
}

void main() {
  group('BaseAiDataSource.generateParaphrases', () {
    late MockAiDataSource dataSource;

    setUp(() {
      dataSource = MockAiDataSource();
    });

    test('parses JSON list response correctly', () async {
      dataSource.mockResponse = '''
{
  "paraphrases": [
    "Paraphrase 1",
    "Paraphrase 2"
  ]
}
''';

      final result = await dataSource.generateParaphrases(
        originalText: 'Original',
        translation: 'Translation',
      );

      expect(result, 'Paraphrase 1\nParaphrase 2');
      expect(dataSource.capturedJsonMode, true);
    });

    test('parses JSON string response correctly (legacy support)', () async {
      dataSource.mockResponse = '''
{
  "paraphrases": "Legacy Paraphrase 1\\nLegacy Paraphrase 2"
}
''';

      final result = await dataSource.generateParaphrases(
        originalText: 'Original',
        translation: 'Translation',
      );

      expect(result, 'Legacy Paraphrase 1\nLegacy Paraphrase 2');
      expect(dataSource.capturedJsonMode, true);
    });

    test('handles fallback to raw text if JSON parsing fails', () async {
      dataSource.mockResponse = 'Raw text response';

      final result = await dataSource.generateParaphrases(
        originalText: 'Original',
        translation: 'Translation',
      );

      expect(result, 'Raw text response');
    });

    test('handles empty list correctly', () async {
      dataSource.mockResponse = '{"paraphrases": []}';

      final result = await dataSource.generateParaphrases(
        originalText: 'Original',
        translation: 'Translation',
      );

      expect(result, '');
    });
  });
}
