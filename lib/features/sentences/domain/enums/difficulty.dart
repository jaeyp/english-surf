/// Difficulty levels for sentences.
enum Difficulty {
  beginner,
  intermediate,
  advanced;

  /// Converts the enum to a JSON-compatible string.
  String toJson() => name;

  /// Creates a Difficulty from a JSON string.
  /// 
  /// Defaults to [beginner] if the string doesn't match any value.
  static Difficulty fromJson(String json) {
    return Difficulty.values.firstWhere(
      (e) => e.name == json,
      orElse: () => Difficulty.beginner,
    );
  }

  /// Returns a human-readable label for UI display.
  String get label {
    switch (this) {
      case Difficulty.beginner:
        return 'Beginner';
      case Difficulty.intermediate:
        return 'Intermediate';
      case Difficulty.advanced:
        return 'Advanced';
    }
  }
}
