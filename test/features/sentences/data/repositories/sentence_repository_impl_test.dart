import 'package:english_surf/features/sentences/data/datasources/sentence_local_data_source.dart';
import 'package:english_surf/features/sentences/data/repositories/sentence_repository_impl.dart';
import 'package:english_surf/features/sentences/domain/entities/sentence.dart';
import 'package:english_surf/features/sentences/domain/enums/difficulty.dart';
import 'package:english_surf/features/sentences/domain/value_objects/sentence_text.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSentenceLocalDataSource extends Mock
    implements SentenceLocalDataSource {}

void main() {
  late SentenceRepositoryImpl repository;
  late MockSentenceLocalDataSource mockLocalDataSource;

  setUp(() {
    mockLocalDataSource = MockSentenceLocalDataSource();
    repository = SentenceRepositoryImpl(localDataSource: mockLocalDataSource);
  });

  final tSentenceList = [
    Sentence(
      id: 1,
      order: 1,
      original: SentenceText(text: 'Test'),
      translation: '테스트',
      difficulty: Difficulty.beginner,
    ),
  ];

  group('getAllSentences', () {
    test('should return list of sentences from local data source', () async {
      // arrange
      when(
        () => mockLocalDataSource.getSentences(),
      ).thenAnswer((_) async => tSentenceList);

      // act
      final result = await repository.getAllSentences();

      // assert
      expect(result, tSentenceList);
      verify(() => mockLocalDataSource.getSentences()).called(1);
    });
  });
}
