import 'dart:io';

abstract class DataRepository {
  /// Exports all app data (sentences, folders) to a JSON file and shares it.
  Future<void> exportData();

  /// Pick a JSON file and import data into the database.
  /// Returns existing [File] used for import for reference if needed.
  Future<void> importData();
}
