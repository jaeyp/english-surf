import 'package:freezed_annotation/freezed_annotation.dart';
import 'text_style.dart';

part 'sentence_text.freezed.dart';
part 'sentence_text.g.dart';

/// Value object representing formatted sentence text.
///
/// Encapsulates the plain text and styling information as a list of styles.
///
/// JSON Format:
/// ```json
/// {
///   "text": "give and go",
///   "styles": [
///     {"type": "highlight", "start": 0, "end": 11},
///     {"type": "bold", "start": 0, "end": 11}
///   ]
/// }
/// ```
@freezed
abstract class SentenceText with _$SentenceText {
  const factory SentenceText({
    /// Plain text with all markup removed
    required String plainText,

    /// List of styles applied to the text
    @Default([]) List<TextStyle> styles,
  }) = _SentenceText;

  factory SentenceText.fromJson(Map<String, dynamic> json) =>
      _$SentenceTextFromJson(json);
}
