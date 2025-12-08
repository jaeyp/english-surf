import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/text_style_type.dart';
import 'text_range.dart';

part 'text_style.freezed.dart';
part 'text_style.g.dart';

/// Represents a style applied to a text range.
///
/// This value object encapsulates both the style type and the range
/// it applies to, plus any additional values (e.g., color hex code).
@freezed
abstract class TextStyle with _$TextStyle {
  const factory TextStyle({
    /// The type of style (bold, highlight, etc.)
    @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson)
    required TextStyleType type,

    /// The range of text this style applies to
    required TextRange range,

    /// Optional value for styles that need it (e.g., color: "#FF0000")
    String? value,
  }) = _TextStyle;

  factory TextStyle.fromJson(Map<String, dynamic> json) =>
      _$TextStyleFromJson(json);
}

/// Helper function for JSON deserialization of TextStyleType.
TextStyleType _typeFromJson(String json) {
  return TextStyleType.fromJson(json) ?? TextStyleType.bold;
}

/// Helper function for JSON serialization of TextStyleType.
String _typeToJson(TextStyleType type) => type.toJson();
