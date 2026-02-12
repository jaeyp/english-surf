import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:english_surf/features/sentences/data/datasources/sentence_local_data_source.dart';
import 'package:english_surf/features/sentences/domain/entities/sentence.dart';
import 'package:english_surf/features/sentences/domain/entities/folder.dart';
import 'package:english_surf/features/sentences/domain/enums/app_language.dart';

class MockAssetBundle extends Mock implements AssetBundle {}

void main() {
  late SentenceLocalDataSourceImpl dataSource;
  late MockAssetBundle mockAssetBundle;

  setUp(() {
    mockAssetBundle = MockAssetBundle();
    dataSource = SentenceLocalDataSourceImpl(assetBundle: mockAssetBundle);
  });

  final tJsonString = '''
  {
    "folder": {
      "id": "123e4567-e89b-12d3-a456-426614174000",
      "name": "Daily English Expressions",
      "createdAt": "2024-01-01T12:00:00.000Z",
      "originalLanguage": "en",
      "translationLanguage": "ko"
    },
    "sentences": [
      {
        "id": 1,
        "order": 1,
        "original": {
          "text": "Hello world",
          "styles": []
        },
        "translation": "안녕 세상",
        "difficulty": "beginner",
        "paraphrases": [],
        "notes": ""
      }
    ]
  }
  ''';

  test('should return Folder and List<Sentence> from asset bundle', () async {
    // arrange
    when(
      () => mockAssetBundle.loadString('assets/data/sentences.json'),
    ).thenAnswer((_) async => tJsonString);

    // act
    final result = await dataSource.getFolderWithSentences();

    // assert
    final (folder, sentences) = result;

    expect(folder, isA<Folder>());
    expect(folder.id, '123e4567-e89b-12d3-a456-426614174000');
    expect(folder.name, 'Daily English Expressions');
    expect(folder.flagColor, null); // Verify null flag
    expect(folder.originalLanguage, AppLanguage.english);
    expect(folder.translationLanguage, AppLanguage.korean);

    expect(sentences, isA<List<Sentence>>());
    expect(sentences.length, 1);
    expect(sentences.first.original.text, 'Hello world');
    expect(sentences.first.folderId, '123e4567-e89b-12d3-a456-426614174000');

    verify(
      () => mockAssetBundle.loadString('assets/data/sentences.json'),
    ).called(1);
  });
}
