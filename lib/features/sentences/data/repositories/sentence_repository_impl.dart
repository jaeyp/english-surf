import '../../domain/entities/sentence.dart';
import '../../domain/repositories/sentence_repository.dart';
import '../datasources/sentence_local_data_source.dart';

class SentenceRepositoryImpl implements SentenceRepository {
  final SentenceLocalDataSource localDataSource;

  SentenceRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Sentence>> getAllSentences() async {
    return localDataSource.getSentences();
  }

  @override
  Future<Sentence?> getSentenceById(int id) {
    // TODO: implement getSentenceById
    throw UnimplementedError();
  }

  @override
  Future<void> addSentence(Sentence sentence) {
    // TODO: implement addSentence
    throw UnimplementedError();
  }

  @override
  Future<void> updateSentence(Sentence sentence) {
    // TODO: implement updateSentence
    throw UnimplementedError();
  }

  @override
  Future<void> deleteSentence(int id) {
    // TODO: implement deleteSentence
    throw UnimplementedError();
  }

  @override
  Future<void> reorderSentences(List<Sentence> sentences) {
    // TODO: implement reorderSentences
    throw UnimplementedError();
  }
}
