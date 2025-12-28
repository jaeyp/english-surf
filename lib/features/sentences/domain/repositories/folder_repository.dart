import '../entities/folder.dart';

abstract class FolderRepository {
  Future<List<Folder>> getAllFolders();
  Stream<List<Folder>> watchAllFolders();
  Future<void> addFolder(Folder folder);
  Future<void> updateFolder(Folder folder);
  Future<void> deleteFolder(String id);
  Future<Folder?> getFolderById(String id);
}
