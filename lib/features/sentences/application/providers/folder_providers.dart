import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/folder.dart';
import '../../data/providers/sentence_providers.dart';

part 'folder_providers.g.dart';

@riverpod
class FolderList extends _$FolderList {
  @override
  Future<List<Folder>> build() async {
    final repository = ref.watch(folderRepositoryProvider);
    return repository.getAllFolders();
  }

  Future<void> addFolder(String name) async {
    final repository = ref.read(folderRepositoryProvider);
    final folder = Folder(
      id: DateTime.now().millisecondsSinceEpoch
          .toString(), // Simplified ID generation
      name: name,
      createdAt: DateTime.now(),
    );
    await repository.addFolder(folder);
    ref.invalidateSelf();
  }

  Future<void> updateFolder(Folder folder) async {
    final repository = ref.read(folderRepositoryProvider);
    await repository.updateFolder(folder);
    ref.invalidateSelf();
  }

  Future<void> deleteFolder(String id) async {
    final repository = ref.read(folderRepositoryProvider);
    await repository.deleteFolder(id);
    ref.invalidateSelf();
  }
}

@Riverpod(keepAlive: true)
class CurrentFolder extends _$CurrentFolder {
  @override
  String? build() => null; // null means Home screen (all folders)

  void setFolder(String? folderId) {
    state = folderId;
  }
}
