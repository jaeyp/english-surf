import 'package:freezed_annotation/freezed_annotation.dart';

part 'text_range.freezed.dart';
part 'text_range.g.dart';

/// Represents a range of text (start and end positions).
///
/// Used to mark portions of text for styling (bold, highlight, etc.).
@freezed
abstract class TextRange with _$TextRange {
  const factory TextRange({required int start, required int end}) = _TextRange;

  factory TextRange.fromJson(Map<String, dynamic> json) =>
      _$TextRangeFromJson(json);
}
