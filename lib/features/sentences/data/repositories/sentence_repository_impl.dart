import 'package:drift/drift.dart';
import '../../domain/entities/sentence.dart';
import '../../domain/repositories/sentence_repository.dart';
import '../../../../core/database/app_database.dart';
import '../models/sentence_mapper.dart';

class SentenceRepositoryImpl implements SentenceRepository {
  final AppDatabase database;

  SentenceRepositoryImpl({required this.database});

  @override
  Future<List<Sentence>> getAllSentences() async {
    final cached = await database.getAllSentences();
    return cached.map((e) => e.toDomain()).toList();

    // TODO: Seed from JSON files (assets/data/seed/xxx.json) if empty
  }

  @override
  Stream<List<Sentence>> watchAllSentences() {
    return database.watchAllSentences().map(
      (entries) => entries.map((entry) => entry.toDomain()).toList(),
    );
  }

  @override
  Future<Sentence?> getSentenceById(int id) async {
    final entry = await (database.select(
      database.sentences,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return entry?.toDomain();
  }

  @override
  Future<List<Sentence>> getSentencesByFolder(String folderId) async {
    final entries = await (database.select(
      database.sentences,
    )..where((t) => t.folderId.equals(folderId))).get();
    return entries.map((e) => e.toDomain()).toList();
  }

  @override
  Stream<List<Sentence>> watchSentencesByFolder(String folderId) {
    return (database.select(database.sentences)
          ..where((t) => t.folderId.equals(folderId)))
        .watch()
        .map((entries) => entries.map((e) => e.toDomain()).toList());
  }

  @override
  Future<void> addSentence(Sentence sentence) async {
    await database.insertSentence(sentence.toCompanion(includeId: false));
  }

  @override
  Future<void> updateSentence(Sentence sentence) async {
    await database.updateSentence(sentence.toEntry());
  }

  @override
  Future<void> deleteSentence(int id) async {
    await database.deleteSentence(id);
  }

  @override
  Future<void> reorderSentences(List<Sentence> sentences) async {
    await database.batch((batch) {
      for (final s in sentences) {
        batch.update(
          database.sentences,
          s.toCompanion(),
          where: (t) => t.id.equals(s.id),
        );
      }
    });
  }

  @override
  Future<void> toggleFavorite(int id, bool isFavorite) async {
    await (database.update(database.sentences)..where((t) => t.id.equals(id)))
        .write(SentencesCompanion(isFavorite: Value(isFavorite)));
  }

  @override
  Future<void> moveSentences(List<int> ids, String folderId) async {
    await (database.update(database.sentences)..where((t) => t.id.isIn(ids)))
        .write(SentencesCompanion(folderId: Value(folderId)));
  }
}
