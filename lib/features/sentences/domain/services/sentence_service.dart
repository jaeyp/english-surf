import '../entities/sentence.dart';
import '../enums/difficulty.dart';
import '../enums/sort_type.dart';
import '../repositories/sentence_repository.dart';

/// Domain service for sentence-related business logic.
///
/// This service encapsulates business rules for filtering, sorting,
/// and other operations on sentences. It uses the repository for
/// data access but keeps business logic separate.
class SentenceService {
  final SentenceRepository _repository;

  SentenceService(this._repository);

  /// Retrieves all sentences with optional filtering and sorting.
  ///
  /// If [difficulty] is provided, only sentences of that difficulty are returned.
  /// The results are sorted according to [sortType].
  Future<List<Sentence>> getSentences({
    Difficulty? difficulty,
    SortType sortType = SortType.random,
  }) async {
    var sentences = await _repository.getAllSentences();

    // Apply difficulty filter if specified
    if (difficulty != null) {
      sentences = sentences.where((s) => s.difficulty == difficulty).toList();
    }

    // Apply sorting
    return _sortSentences(sentences, sortType);
  }

  /// Retrieves a single sentence by ID.
  Future<Sentence?> getSentenceById(int id) {
    return _repository.getSentenceById(id);
  }

  /// Adds a new sentence after validation.
  ///
  /// Validates that the sentence has valid data before adding.
  Future<void> addSentence(Sentence sentence) async {
    _validateSentence(sentence);
    await _repository.addSentence(sentence);
  }

  /// Updates an existing sentence after validation.
  Future<void> updateSentence(Sentence sentence) async {
    _validateSentence(sentence);
    await _repository.updateSentence(sentence);
  }

  /// Deletes a sentence by ID.
  Future<void> deleteSentence(int id) {
    return _repository.deleteSentence(id);
  }

  /// Reorders sentences by updating their order values.
  ///
  /// This ensures that order values are sequential starting from 1.
  Future<void> reorderSentences(List<Sentence> sentences) async {
    // Ensure order values are sequential
    final reorderedSentences = sentences.asMap().entries.map((entry) {
      return entry.value.copyWith(order: entry.key + 1);
    }).toList();

    await _repository.reorderSentences(reorderedSentences);
  }

  /// Sorts sentences according to the specified sort type.
  List<Sentence> _sortSentences(List<Sentence> sentences, SortType sortType) {
    final sorted = List<Sentence>.from(sentences);

    switch (sortType) {
      case SortType.order:
        sorted.sort((a, b) => a.order.compareTo(b.order));
        break;
      case SortType.difficulty:
        sorted.sort((a, b) => a.difficulty.index.compareTo(b.difficulty.index));
        break;
      case SortType.random:
        sorted.shuffle();
        break;
    }

    return sorted;
  }

  /// Validates sentence data.
  ///
  /// Throws [ArgumentError] if validation fails.
  void _validateSentence(Sentence sentence) {
    if (sentence.original.text.trim().isEmpty) {
      throw ArgumentError('Sentence text cannot be empty');
    }
    if (sentence.translation.trim().isEmpty) {
      throw ArgumentError('Translation cannot be empty');
    }
    if (sentence.order < 1) {
      throw ArgumentError('Order must be greater than 0');
    }
  }
}
