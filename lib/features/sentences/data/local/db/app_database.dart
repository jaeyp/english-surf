import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../../domain/enums/difficulty.dart';
import '../../../domain/value_objects/sentence_text.dart';
import 'converters.dart';

part 'app_database.g.dart';

@DataClassName('SentenceEntry')
class Sentences extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get order => integer()();
  TextColumn get original => text().map(const SentenceTextConverter())();
  TextColumn get translation => text()();
  TextColumn get difficulty => text().map(const DifficultyConverter())();
  TextColumn get examples => text().map(const StringListConverter())();
  TextColumn get notes => text()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [Sentences])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          // Add the new isFavorite column
          await m.addColumn(sentences, sentences.isFavorite);
        }
      },
      beforeOpen: (details) async {
        if (details.wasCreated) {
          // If first-time creation, everything is fine
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
