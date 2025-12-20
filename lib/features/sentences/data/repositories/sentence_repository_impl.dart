import '../../domain/entities/sentence.dart';
import '../../domain/repositories/sentence_repository.dart';
import '../datasources/sentence_local_data_source.dart';
import '../local/db/app_database.dart';
import '../models/sentence_mapper.dart';

class SentenceRepositoryImpl implements SentenceRepository {
  final SentenceLocalDataSource localDataSource;
  final AppDatabase database;

  SentenceRepositoryImpl({
    required this.localDataSource,
    required this.database,
  });

  @override
  Future<List<Sentence>> getAllSentences() async {
    final cached = await database.getAllSentences();
    print('DEBUG: Repository found ${cached.length} items in DB');
    if (cached.isNotEmpty) {
      return cached.map((e) => e.toDomain()).toList();
    }

    print('DEBUG: DB is empty. Seeding from JSON...');
    // Seed from JSON if empty
    final initialSentences = await localDataSource.getSentences();
    await database.insertAllSentences(
      initialSentences.map((s) => s.toCompanion()).toList(),
    );
    return initialSentences;
  }

  @override
  Future<Sentence?> getSentenceById(int id) async {
    final entry = await (database.select(
      database.sentences,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return entry?.toDomain();
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
}
