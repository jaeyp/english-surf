/// Types of text styling that can be applied to sentence text.
enum TextStyleType {
  bold,
  highlight,
  underline,
  strikethrough,
  italic,
  color;

  /// Converts the enum to a JSON-compatible string.
  String toJson() => name;

  /// Creates a TextStyleType from a JSON string.
  /// 
  /// Returns null if the string doesn't match any value.
  static TextStyleType? fromJson(String json) {
    try {
      return TextStyleType.values.firstWhere((e) => e.name == json);
    } catch (_) {
      return null;
    }
  }

  /// Returns a human-readable label for UI display.
  String get label {
    switch (this) {
      case TextStyleType.bold:
        return 'Bold';
      case TextStyleType.highlight:
        return 'Highlight';
      case TextStyleType.underline:
        return 'Underline';
      case TextStyleType.strikethrough:
        return 'Strikethrough';
      case TextStyleType.italic:
        return 'Italic';
      case TextStyleType.color:
        return 'Color';
    }
  }
}
