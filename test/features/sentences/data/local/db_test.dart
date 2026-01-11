import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:english_surf/features/sentences/data/local/db/app_database.dart';
import 'package:english_surf/features/sentences/domain/enums/difficulty.dart';
import 'package:english_surf/features/sentences/domain/value_objects/sentence_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('should insert and retrieve a sentence', () async {
    // Arrange
    final sentence = SentencesCompanion.insert(
      order: 1,
      original: const SentenceText(text: 'Hello world'),
      translation: '안녕 세상',
      difficulty: Difficulty.beginner,
      paraphrases: const ['Hello!', 'World!'],
      notes: 'Basic greeting',
      folderId: const Value('default_folder'),
    );

    // Act
    final id = await database.insertSentence(sentence);
    final retrieved = await database.getAllSentences();

    // Assert
    expect(retrieved.length, 1);
    expect(retrieved.first.id, id);
    expect(retrieved.first.original.text, 'Hello world');
    expect(retrieved.first.difficulty, Difficulty.beginner);
    expect(retrieved.first.folderId, 'default_folder');
  });

  test('should update a sentence', () async {
    // Arrange
    final id = await database.insertSentence(
      SentencesCompanion.insert(
        order: 1,
        original: const SentenceText(text: 'Hello'),
        translation: '안녕',
        difficulty: Difficulty.beginner,
        paraphrases: const [],
        notes: '',
        folderId: const Value('default_folder'),
      ),
    );

    final updatedEntry = SentenceEntry(
      id: id,
      order: 1,
      original: const SentenceText(text: 'Hi'),
      translation: '안녕',
      difficulty: Difficulty.beginner,
      paraphrases: const [],
      notes: 'Updated',
      isFavorite: false,
      folderId: 'default_folder',
    );

    // Act
    await database.updateSentence(updatedEntry);
    final retrieved = await database.getAllSentences();

    // Assert
    expect(retrieved.first.original.text, 'Hi');
    expect(retrieved.first.notes, 'Updated');
  });

  test('should delete a sentence', () async {
    // Arrange
    final id = await database.insertSentence(
      SentencesCompanion.insert(
        order: 1,
        original: const SentenceText(text: 'Delete me'),
        translation: '삭제',
        difficulty: Difficulty.beginner,
        paraphrases: const [],
        notes: '',
      ),
    );

    // Act
    await database.deleteSentence(id);
    final retrieved = await database.getAllSentences();

    // Assert
    expect(retrieved.isEmpty, true);
  });
}
