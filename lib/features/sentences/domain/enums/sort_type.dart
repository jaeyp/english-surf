/// Sort types for sentence lists.
enum SortType {
  order,
  difficulty,
  random;

  /// Converts the enum to a JSON-compatible string.
  String toJson() => name;

  /// Creates a SortType from a JSON string.
  /// 
  /// Defaults to [random] if the string doesn't match any value.
  static SortType fromJson(String json) {
    return SortType.values.firstWhere(
      (e) => e.name == json,
      orElse: () => SortType.random,
    );
  }

  /// Returns a human-readable label for UI display.
  String get label {
    switch (this) {
      case SortType.order:
        return 'Order';
      case SortType.difficulty:
        return 'Difficulty';
      case SortType.random:
        return 'Random';
    }
  }
}
