import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/text_style_type.dart';

part 'text_style.freezed.dart';
part 'text_style.g.dart';

/// Represents a style applied to a range of text.
@freezed
abstract class TextStyle with _$TextStyle {
  const factory TextStyle({
    required TextStyleType type,
    required int start,
    required int end,
    String? value,
  }) = _TextStyle;

  factory TextStyle.fromJson(Map<String, dynamic> json) =>
      _$TextStyleFromJson(json);
}
