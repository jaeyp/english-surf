import '../entities/sentence.dart';
import '../enums/difficulty.dart';
import '../enums/sort_type.dart';

/// Repository interface for Sentence data operations.
/// 
/// This defines the contract for data operations without specifying
/// the implementation details (e.g., local file, database, network).
abstract class SentenceRepository {
  /// Retrieves all sentences.
  /// 
  /// Returns a list of all sentences available in the data source.
  Future<List<Sentence>> getAllSentences();

  /// Retrieves a single sentence by its ID.
  /// 
  /// Returns the sentence if found, null otherwise.
  Future<Sentence?> getSentenceById(int id);

  /// Adds a new sentence.
  /// 
  /// The sentence must have a unique ID and order value.
  Future<void> addSentence(Sentence sentence);

  /// Updates an existing sentence.
  /// 
  /// Replaces the sentence with the same ID.
  Future<void> updateSentence(Sentence sentence);

  /// Deletes a sentence by its ID.
  Future<void> deleteSentence(int id);

  /// Reorders sentences by updating their order field.
  /// 
  /// Takes a list of sentences with updated order values and persists them.
  Future<void> reorderSentences(List<Sentence> sentences);

  /// Retrieves sentences filtered by difficulty level.
  Future<List<Sentence>> getSentencesByDifficulty(Difficulty difficulty);

  /// Retrieves sentences sorted by the specified type.
  Future<List<Sentence>> getSentencesSorted(SortType sortType);
}
