import 'package:freezed_annotation/freezed_annotation.dart';

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
    required String sentence,
    required String translation,
    required String difficulty,
    @Default([]) List<String> examples,
    @Default('') String notes,
  }) = _Sentence;

  factory Sentence.fromJson(Map<String, dynamic> json) =>
      _$SentenceFromJson(json);
}
