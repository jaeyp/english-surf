import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../../features/sentences/domain/enums/difficulty.dart';
import '../../../features/sentences/domain/value_objects/sentence_text.dart';
import 'converters.dart';

part 'app_database.g.dart';

@DataClassName('SentenceEntry')
class Sentences extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get order => integer()();
  TextColumn get original => text().map(const SentenceTextConverter())();
  TextColumn get translation => text()();
  TextColumn get difficulty => text().map(const DifficultyConverter())();
  TextColumn get paraphrases => text().map(const StringListConverter())();
  TextColumn get notes => text()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  TextColumn get folderId => text().nullable().references(Folders, #id)();
}

@DataClassName('FolderEntry')
class Folders extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get flagColor => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Sentences, Folders])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.addColumn(sentences, sentences.isFavorite);
        }
        if (from < 3) {
          // 1. Create folders table
          await m.createTable(folders);
          // 2. Add folderId to sentences
          await m.addColumn(sentences, sentences.folderId);

          // 3. Seed "Default" folder
          final defaultFolderId = 'default_folder';
          await into(folders).insert(
            FoldersCompanion.insert(
              id: defaultFolderId,
              name: 'Default',
              createdAt: DateTime.now(),
            ),
          );

          // 4. Move all existing sentences to the "Default" folder
          await (update(sentences)..where((t) => t.folderId.isNull())).write(
            SentencesCompanion(folderId: Value(defaultFolderId)),
          );
        }
        if (from < 4) {
          await m.addColumn(folders, folders.flagColor);
        }
        if (from < 5) {
          await m.renameColumn(sentences, 'examples', sentences.paraphrases);
        }
      },
      beforeOpen: (details) async {
        if (details.wasCreated) {
          // Seed "Default" folder on fresh install
          final defaultFolderId = 'default_folder';
          await into(folders).insert(
            FoldersCompanion.insert(
              id: defaultFolderId,
              name: 'Default',
              createdAt: DateTime.now(),
            ),
          );
        }
      },
    );
  }

  // CRUD Operations
  Future<List<SentenceEntry>> getAllSentences() => select(sentences).get();

  Stream<List<SentenceEntry>> watchAllSentences() => select(sentences).watch();

  Future<int> insertSentence(SentencesCompanion entry) =>
      into(sentences).insert(entry);

  Future<bool> updateSentence(SentenceEntry entry) =>
      update(sentences).replace(entry);

  Future<int> deleteSentence(int id) =>
      (delete(sentences)..where((t) => t.id.equals(id))).go();

  Future<void> insertAllSentences(List<SentencesCompanion> entries) async {
    await batch((batch) {
      batch.insertAll(sentences, entries);
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app.db'));
    return NativeDatabase(file);
  });
}
