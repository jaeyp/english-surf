import 'package:drift/drift.dart';
import '../../domain/entities/sentence.dart';
import '../local/db/app_database.dart';

extension SentenceEntryMapper on SentenceEntry {
  Sentence toDomain() {
    return Sentence(
      id: id,
      order: order,
      original: original,
      translation: translation,
      difficulty: difficulty,
      examples: examples,
      notes: notes,
    );
  }
}

extension SentenceMapper on Sentence {
  SentenceEntry toEntry() {
    return SentenceEntry(
      id: id,
      order: order,
      original: original,
      translation: translation,
      difficulty: difficulty,
      examples: examples,
      notes: notes,
    );
  }

  SentencesCompanion toCompanion({bool includeId = true}) {
    return SentencesCompanion(
      id: includeId ? Value(id) : const Value.absent(),
      order: Value(order),
      original: Value(original),
      translation: Value(translation),
      difficulty: Value(difficulty),
      examples: Value(examples),
      notes: Value(notes),
    );
  }
}
