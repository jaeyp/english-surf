import '../entities/sentence.dart';

/// Repository interface for Sentence data operations.
/// 
/// This defines the contract for data access operations only.
/// Business logic (filtering, sorting, validation) is handled
/// by the SentenceService in the domain/services layer.
abstract class SentenceRepository {
  /// Retrieves all sentences from the data source.
  /// 
  /// Returns a list of all sentences without any filtering or sorting.
  Future<List<Sentence>> getAllSentences();

  /// Retrieves a single sentence by its ID.
  /// 
  /// Returns the sentence if found, null otherwise.
  Future<Sentence?> getSentenceById(int id);

  /// Adds a new sentence to the data source.
  /// 
  /// The sentence must have a unique ID and order value.
  Future<void> addSentence(Sentence sentence);

  /// Updates an existing sentence in the data source.
  /// 
  /// Replaces the sentence with the same ID.
  Future<void> updateSentence(Sentence sentence);

  /// Deletes a sentence by its ID from the data source.
  Future<void> deleteSentence(int id);

  /// Persists a list of sentences with updated order values.
  /// 
  /// This is used after reordering sentences via drag-and-drop.
  Future<void> reorderSentences(List<Sentence> sentences);
}
