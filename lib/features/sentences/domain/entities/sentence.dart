import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/difficulty.dart';
import '../value_objects/sentence_text.dart';

part 'sentence.freezed.dart';
part 'sentence.g.dart';

/// Represents a single English sentence for learning purposes.
///
/// This entity contains an English sentence with translations,
/// difficulty level, examples, and additional notes.
@freezed
abstract class Sentence with _$Sentence {
  const factory Sentence({
    required int id,
    required int order,
    @JsonKey(
      name: 'original',
      fromJson: _sentenceTextFromJson,
      toJson: _sentenceTextToJson,
    )
    required SentenceText original,
    required String translation,
    @JsonKey(fromJson: Difficulty.fromJson, toJson: _difficultyToJson)
    required Difficulty difficulty,
    @Default([]) List<String> examples,
    @Default('') String notes,
  }) = _Sentence;

  factory Sentence.fromJson(Map<String, dynamic> json) =>
      _$SentenceFromJson(json);
}

/// Helper function for JSON deserialization of SentenceText.
SentenceText _sentenceTextFromJson(dynamic json) {
  if (json is Map<String, dynamic>) {
    return SentenceText.fromJson(json);
  }
  // Fallback: empty
  return const SentenceText(text: '');
}

/// Helper function for JSON serialization of SentenceText.
Map<String, dynamic> _sentenceTextToJson(SentenceText sentenceText) {
  return sentenceText.toJson();
}

/// Helper function for JSON serialization of Difficulty enum.
String _difficultyToJson(Difficulty difficulty) => difficulty.toJson();
