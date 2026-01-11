import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:drift/native.dart';
import 'package:english_surf/features/sentences/data/datasources/sentence_local_data_source.dart';
import 'package:english_surf/features/sentences/data/repositories/sentence_repository_impl.dart';
import 'package:english_surf/core/database/app_database.dart';
import 'package:english_surf/features/sentences/domain/entities/sentence.dart';
import 'package:english_surf/features/sentences/domain/enums/difficulty.dart';
import 'package:english_surf/features/sentences/domain/value_objects/sentence_text.dart';

class MockSentenceLocalDataSource extends Mock
    implements SentenceLocalDataSource {}

void main() {
  late SentenceRepositoryImpl repository;
  late MockSentenceLocalDataSource mockLocalDataSource;
  late AppDatabase database;

  setUp(() {
    mockLocalDataSource = MockSentenceLocalDataSource();
    database = AppDatabase(NativeDatabase.memory());
    repository = SentenceRepositoryImpl(
      localDataSource: mockLocalDataSource,
      database: database,
    );
  });

  tearDown(() async {
    await database.close();
  });

  const testSentence = Sentence(
    id: 1,
    order: 1,
    original: SentenceText(text: 'Hello'),
    translation: '안녕하세요',
    difficulty: Difficulty.beginner,
  );

  final tSentenceList = [testSentence];

  group('getAllSentences', () {
    test('should seed from local data source when database is empty', () async {
      // arrange
      when(
        () => mockLocalDataSource.getSentences(),
      ).thenAnswer((_) async => tSentenceList);

      // act
      final result = await repository.getAllSentences();

      // assert
      expect(result.length, tSentenceList.length);
      expect(result.first.original.text, tSentenceList.first.original.text);
      verify(() => mockLocalDataSource.getSentences()).called(1);

      // Verify it's actually in the database now
      final dbContent = await database.getAllSentences();
      expect(dbContent.isNotEmpty, true);
    });

    test('should return from database when not empty', () async {
      // arrange
      when(
        () => mockLocalDataSource.getSentences(),
      ).thenAnswer((_) async => tSentenceList);

      // Pre-fill database
      await repository.getAllSentences();
      clearInteractions(mockLocalDataSource);

      // act
      final result = await repository.getAllSentences();

      // assert
      expect(result.isNotEmpty, true);
      verifyNever(() => mockLocalDataSource.getSentences());
    });
  });

  group('getSentenceById', () {
    test('should return sentence when id exists', () async {
      // arrange
      when(
        () => mockLocalDataSource.getSentences(),
      ).thenAnswer((_) async => tSentenceList);
      await repository.getAllSentences(); // Ensure seeding

      // act
      final result = await repository.getSentenceById(1);

      // assert
      expect(result?.original.text, tSentenceList.first.original.text);
    });

    test('should return null when id does not exist', () async {
      // arrange
      when(
        () => mockLocalDataSource.getSentences(),
      ).thenAnswer((_) async => tSentenceList);
      await repository.getAllSentences(); // Ensure seeding

      // act
      final result = await repository.getSentenceById(999);

      // assert
      expect(result, null);
    });
  });

  group('toggleFavorite', () {
    test('should toggle isFavorite status in database', () async {
      // arrange
      when(
        () => mockLocalDataSource.getSentences(),
      ).thenAnswer((_) async => tSentenceList);
      await repository.getAllSentences(); // Seed

      // act
      await repository.toggleFavorite(1, true);

      // assert
      final sentence = await repository.getSentenceById(1);
      expect(sentence?.isFavorite, true);

      // act again
      await repository.toggleFavorite(1, false);

      // assert again
      final sentence2 = await repository.getSentenceById(1);
      expect(sentence2?.isFavorite, false);
    });
  });
}
