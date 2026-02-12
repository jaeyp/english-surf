import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/folder.dart';
import '../../domain/enums/app_language.dart';
import '../../data/providers/sentence_providers.dart';

part 'folder_providers.g.dart';

@riverpod
class FolderList extends _$FolderList {
  @override
  Future<List<Folder>> build() async {
    final repository = ref.watch(folderRepositoryProvider);
    return repository.getAllFolders();
  }

  Future<void> addFolder(
    String name, {
    AppLanguage originalLanguage = AppLanguage.english,
    AppLanguage translationLanguage = AppLanguage.korean,
  }) async {
    final repository = ref.read(folderRepositoryProvider);
    final folder = Folder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      createdAt: DateTime.now(),
      originalLanguage: originalLanguage,
      translationLanguage: translationLanguage,
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

@riverpod
class SelectedFlag extends _$SelectedFlag {
  @override
  String? build() => null; // null means 'All'

  void setFlag(String? flagColor) {
    state = flagColor;
  }
}

@riverpod
Future<List<Folder>> filteredFolders(Ref ref) async {
  final allFolders = await ref.watch(folderListProvider.future);
  final selectedFlag = ref.watch(selectedFlagProvider);

  // 1. Filter
  var result = allFolders;
  if (selectedFlag != null) {
    result = result.where((f) => f.flagColor == selectedFlag).toList();
  }

  // 2. Sort (Alphabetical)
  result.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  return result;
}
