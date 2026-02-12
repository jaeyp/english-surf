import 'package:drift/drift.dart';
import '../../domain/entities/folder.dart';
import '../../../../core/database/app_database.dart';

extension FolderEntryMapper on FolderEntry {
  Folder toDomain() {
    return Folder(
      id: id,
      name: name,
      createdAt: createdAt,
      flagColor: flagColor,
      originalLanguage: originalLanguage,
      translationLanguage: translationLanguage,
    );
  }
}

extension FolderMapper on Folder {
  FolderEntry toEntry() {
    return FolderEntry(
      id: id,
      name: name,
      createdAt: createdAt,
      flagColor: flagColor,
      originalLanguage: originalLanguage,
      translationLanguage: translationLanguage,
    );
  }

  FoldersCompanion toCompanion() {
    return FoldersCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
      flagColor: Value(flagColor),
      originalLanguage: Value(originalLanguage),
      translationLanguage: Value(translationLanguage),
    );
  }
}
