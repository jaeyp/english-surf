import 'package:drift/drift.dart';
import '../local/db/app_database.dart';
import '../../domain/entities/folder.dart';
import '../../domain/repositories/folder_repository.dart';
import '../models/folder_mapper.dart';

class FolderRepositoryImpl implements FolderRepository {
  final AppDatabase database;

  FolderRepositoryImpl({required this.database});

  @override
  Future<List<Folder>> getAllFolders() async {
    final entries = await database.select(database.folders).get();
    return entries.map((e) => e.toDomain()).toList();
  }

  @override
  Stream<List<Folder>> watchAllFolders() {
    return database
        .select(database.folders)
        .watch()
        .map((entries) => entries.map((e) => e.toDomain()).toList());
  }

  @override
  Future<void> addFolder(Folder folder) async {
    await database.into(database.folders).insert(folder.toCompanion());
  }

  @override
  Future<void> updateFolder(Folder folder) async {
    await database.update(database.folders).replace(folder.toEntry());
  }

  @override
  Future<void> deleteFolder(String id) async {
    await database.transaction(() async {
      // 1. Move sentences to default folder
      await (database.update(database.sentences)
            ..where((t) => t.folderId.equals(id)))
          .write(const SentencesCompanion(folderId: Value('default_folder')));

      // 2. Delete the folder
      await (database.delete(
        database.folders,
      )..where((t) => t.id.equals(id))).go();
    });
  }

  @override
  Future<Folder?> getFolderById(String id) async {
    final entry = await (database.select(
      database.folders,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return entry?.toDomain();
  }
}
