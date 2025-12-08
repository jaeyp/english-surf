import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/text_style_type.dart';
import 'text_range.dart';
import 'text_style.dart' as ts;

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
class SentenceText with _$SentenceText {
  const factory SentenceText({
    /// Plain text with all markup removed
    required String plainText,
    
    /// List of styles applied to the text
    @Default([]) List<ts.TextStyle> styles,
  }) = _SentenceText;

  factory SentenceText.fromJson(Map<String, dynamic> json) =>
      _$SentenceTextFromJson(json);
}
