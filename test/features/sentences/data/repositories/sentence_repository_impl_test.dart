import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:english_surf/features/sentences/data/repositories/sentence_repository_impl.dart';
import 'package:english_surf/core/database/app_database.dart';
import 'package:english_surf/features/sentences/domain/entities/sentence.dart';
import 'package:english_surf/features/sentences/domain/enums/difficulty.dart';
import 'package:english_surf/features/sentences/domain/value_objects/sentence_text.dart';

void main() {
  late SentenceRepositoryImpl repository;
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = SentenceRepositoryImpl(database: database);
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

  group('getAllSentences', () {
    test('should return empty list when database is empty', () async {
      // act
      final result = await repository.getAllSentences();

      // assert
      expect(result, isEmpty);
    });

    test('should return sentences from database', () async {
      // arrange
      await repository.addSentence(testSentence.copyWith(folderId: 'folder_a'));

      // act
      final result = await repository.getAllSentences();

      // assert
      expect(result.length, 1);
      expect(result.first.original.text, 'Hello');
    });
  });

  group('getSentenceById', () {
    test('should return sentence when id exists', () async {
      // arrange
      await repository.addSentence(testSentence.copyWith(folderId: 'folder_a'));

      // act
      final result = await repository.getSentenceById(1);

      // assert
      expect(result?.original.text, 'Hello');
    });

    test('should return null when id does not exist', () async {
      // act
      final result = await repository.getSentenceById(999);

      // assert
      expect(result, null);
    });
  });

  group('toggleFavorite', () {
    test('should toggle isFavorite status in database', () async {
      // arrange
      await repository.addSentence(testSentence.copyWith(folderId: 'folder_a'));

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

  group('Folder Operations', () {
    test('should move sentences to a new folder', () async {
      // arrange
      await repository.addSentence(testSentence.copyWith(folderId: 'folder_a'));

      // act
      await repository.moveSentences([1], 'new_folder');

      // assert
      final sentence = await repository.getSentenceById(1);
      expect(sentence?.folderId, 'new_folder');
    });

    test('should get sentences by folder', () async {
      // arrange
      await repository.addSentence(
        testSentence.copyWith(id: 1, folderId: 'folder_a'),
      );
      await repository.addSentence(
        testSentence.copyWith(id: 2, folderId: 'folder_b'),
      );
      await repository.addSentence(
        testSentence.copyWith(id: 3, folderId: 'folder_a'),
      );

      // act
      final folderASentences = await repository.getSentencesByFolder(
        'folder_a',
      );
      final folderBSentences = await repository.getSentencesByFolder(
        'folder_b',
      );

      // assert
      expect(folderASentences.length, 2);
      expect(folderASentences.map((s) => s.id), containsAll([1, 3]));
      expect(folderBSentences.length, 1);
      expect(folderBSentences.first.id, 2);
    });
  });

  group('reorderSentences', () {
    test('should update order for multiple sentences', () async {
      // arrange
      await repository.addSentence(testSentence.copyWith(id: 1, order: 10));
      await repository.addSentence(testSentence.copyWith(id: 2, order: 20));

      // act
      final reordered = [
        testSentence.copyWith(id: 1, order: 20),
        testSentence.copyWith(id: 2, order: 10),
      ];
      await repository.reorderSentences(reordered);

      // assert
      final s1 = await repository.getSentenceById(1);
      final s2 = await repository.getSentenceById(2);

      expect(s1?.order, 20);
      expect(s2?.order, 10);
    });
  });
}
