import 'package:drift/drift.dart';
import '../../domain/entities/folder.dart';
import '../local/db/app_database.dart';

extension FolderEntryMapper on FolderEntry {
  Folder toDomain() {
    return Folder(
      id: id,
      name: name,
      createdAt: createdAt,
      flagColor: flagColor,
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
    );
  }

  FoldersCompanion toCompanion() {
    return FoldersCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
      flagColor: Value(flagColor),
    );
  }
}
