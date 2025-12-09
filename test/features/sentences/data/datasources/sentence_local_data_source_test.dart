import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:english_surf/features/sentences/data/datasources/sentence_local_data_source.dart';
import 'package:english_surf/features/sentences/domain/entities/sentence.dart';

class MockAssetBundle extends Mock implements AssetBundle {}

void main() {
  late SentenceLocalDataSourceImpl dataSource;
  late MockAssetBundle mockAssetBundle;

  setUp(() {
    mockAssetBundle = MockAssetBundle();
    // 의존성 주입 (생성자 수정 필요 - 현재는 컴파일 에러 발생 예상)
    dataSource = SentenceLocalDataSourceImpl(assetBundle: mockAssetBundle);
  });

  final tJsonString = '''
  [
    {
      "id": 1,
      "order": 1,
      "original": {
        "text": "Hello world",
        "styles": []
      },
      "translation": "안녕 세상",
      "difficulty": "easy",
      "examples": [],
      "notes": ""
    }
  ]
  ''';

  test('should return List<Sentence> from asset bundle', () async {
    // arrange
    when(
      () => mockAssetBundle.loadString('assets/data/sentences.json'),
    ).thenAnswer((_) async => tJsonString);

    // act
    final result = await dataSource.getSentences();

    // assert
    expect(result, isA<List<Sentence>>());
    expect(result.length, 1);
    expect(result.first.original.text, 'Hello world');
    verify(
      () => mockAssetBundle.loadString('assets/data/sentences.json'),
    ).called(1);
  });
}
