import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/difficulty.dart';

part 'sentence.freezed.dart';
part 'sentence.g.dart';

/// Represents a single English sentence for learning purposes.
/// 
/// This entity contains an English sentence with translations,
/// difficulty level, examples, and additional notes.
@freezed
class Sentence with _$Sentence {
  const factory Sentence({
    required int id,
    required int order,
    required String sentence,
    required String translation,
    @JsonKey(
      fromJson: Difficulty.fromJson,
      toJson: _difficultyToJson,
    )
    required Difficulty difficulty,
    @Default([]) List<String> examples,
    @Default('') String notes,
  }) = _Sentence;

  factory Sentence.fromJson(Map<String, dynamic> json) =>
      _$SentenceFromJson(json);
}

/// Helper function for JSON serialization of Difficulty enum.
String _difficultyToJson(Difficulty difficulty) => difficulty.toJson();
