import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:english_surf/features/sentences/data/repositories/folder_repository_impl.dart';
import 'package:english_surf/features/sentences/data/local/db/app_database.dart';
import 'package:english_surf/features/sentences/domain/entities/folder.dart';
import 'package:english_surf/features/sentences/domain/enums/difficulty.dart';
import 'package:english_surf/features/sentences/domain/value_objects/sentence_text.dart';
import 'package:drift/drift.dart' as drift;

void main() {
  late FolderRepositoryImpl repository;
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = FolderRepositoryImpl(database: database);
  });

  tearDown(() async {
    await database.close();
  });

  final tFolder = Folder(
    id: 'test_folder',
    name: 'Test Folder',
    createdAt: DateTime(2025, 1, 1),
  );

  group('getAllFolders', () {
    test('should return all folders from database', () async {
      // arrange
      await repository.addFolder(tFolder);

      // act
      final result = await repository.getAllFolders();

      // assert
      expect(result.length, 2);
      expect(result.any((f) => f.name == 'Default'), true);
      expect(result.any((f) => f.name == tFolder.name), true);
    });
  });

  group('addFolder', () {
    test('should add folder to database', () async {
      // act
      await repository.addFolder(tFolder);

      // assert
      final result = await repository.getFolderById(tFolder.id);
      expect(result?.name, tFolder.name);
    });
  });

  group('updateFolder', () {
    test('should update folder in database', () async {
      // arrange
      await repository.addFolder(tFolder);
      final updatedFolder = tFolder.copyWith(name: 'Updated Name');

      // act
      await repository.updateFolder(updatedFolder);

      // assert
      final result = await repository.getFolderById(tFolder.id);
      expect(result?.name, 'Updated Name');
    });
  });

  group('deleteFolder', () {
    test('should delete folder and move sentences to default_folder', () async {
      // arrange
      await repository.addFolder(tFolder);

      // Add a sentence in this folder
      await database
          .into(database.sentences)
          .insert(
            SentencesCompanion.insert(
              original: SentenceText(text: 'Test Sentence'),
              translation: '테스트',
              difficulty: Difficulty.beginner,
              folderId: drift.Value(tFolder.id),
              order: 1,
              examples: const [],
              notes: '',
            ),
          );

      // Verify sentence is in the test folder
      var sentences = await (database.select(
        database.sentences,
      )..where((t) => t.folderId.equals(tFolder.id))).get();
      expect(sentences.length, 1);

      // act
      await repository.deleteFolder(tFolder.id);

      // assert
      // 1. Folder should be deleted
      final folderResult = await repository.getFolderById(tFolder.id);
      expect(folderResult, null);

      // 2. Sentence should be moved to default_folder
      sentences = await (database.select(
        database.sentences,
      )..where((t) => t.folderId.equals('default_folder'))).get();
      expect(sentences.length, 1);
    });
  });

  group('getFolderById', () {
    test('should return folder when id exists', () async {
      // arrange
      await repository.addFolder(tFolder);

      // act
      final result = await repository.getFolderById(tFolder.id);

      // assert
      expect(result?.name, tFolder.name);
    });

    test('should return null when id does not exist', () async {
      // act
      final result = await repository.getFolderById('non_existent');

      // assert
      expect(result, null);
    });
  });
}
