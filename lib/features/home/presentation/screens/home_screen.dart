import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../sentences/application/providers/folder_providers.dart';
import '../widgets/folder_filter_bar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredFoldersAsync = ref.watch(filteredFoldersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('EnglishSurf'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          const FolderFilterBar(),
          Expanded(
            child: filteredFoldersAsync.when(
              data: (folders) => _FolderList(folders: folders),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddFolderDialog(context, ref),
        child: const Icon(Icons.create_new_folder),
      ),
    );
  }

  void _showAddFolderDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Folder'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Folder name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref
                    .read(folderListProvider.notifier)
                    .addFolder(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _FolderList extends ConsumerWidget {
  final List<dynamic> folders;

  const _FolderList({required this.folders});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (folders.isEmpty) {
      return const Center(child: Text('No folders found.'));
    }

    return ListView.separated(
      itemCount: folders.length,
      separatorBuilder: (context, index) =>
          const Divider(height: 1, indent: 16, endIndent: 16),
      itemBuilder: (context, index) {
        final folder = folders[index];
        return _FolderTile(folder: folder);
      },
      // Ensure the FAB doesn't cover the last item
      padding: const EdgeInsets.only(bottom: 80, top: 16),
    );
  }
}

class _FolderTile extends ConsumerWidget {
  final dynamic folder;

  const _FolderTile({required this.folder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Determine if we show a bookmark icon
    final flagColor = _getFlagColor(folder.flagColor);
    final hasFlag = flagColor != null;

    return InkWell(
      onTap: () {
        ref.read(currentFolderProvider.notifier).setFolder(folder.id);
        context.push('/sentences');
      },
      onLongPress: () => _showFlagSelectionDialog(context, ref, folder),
      child: Stack(
        children: [
          Container(
            constraints: const BoxConstraints(minHeight: 64),
            padding: const EdgeInsets.only(
              left: 54,
              right: 16,
              top: 8,
              bottom: 8,
            ),
            color: Colors.grey.withValues(alpha: 0.05),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    folder.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                if (folder.id != 'default_folder')
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                    onSelected: (value) {
                      if (value == 'rename') {
                        _showRenameDialog(context, ref, folder);
                      }
                      if (value == 'delete') {
                        _showDeleteDialog(context, ref, folder);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'rename',
                        child: Text('Rename'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (hasFlag)
            Positioned(
              top: 0,
              left: 16, // "Stuck" position
              child: Icon(
                Icons.bookmark,
                color: flagColor,
                size: 32, // Slightly larger for "real bookmark" feel?
              ),
            ),
        ],
      ),
    );
  }

  Color? _getFlagColor(String? colorName) {
    if (colorName == null) return null;
    switch (colorName) {
      case 'Red':
        return Colors.red;
      case 'Blue':
        return Colors.blue;
      case 'Green':
        return Colors.green;
      case 'Orange':
        return Colors.orange;
      case 'Purple':
        return Colors.purple;
      case 'Cyan':
        return Colors.cyanAccent;
      case 'Pink':
        return Colors.pinkAccent;
      default:
        return null;
    }
  }

  void _showFlagSelectionDialog(
    BuildContext context,
    WidgetRef ref,
    dynamic folder,
  ) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        // title: const Text('Select Flag'), // Removed title
        contentPadding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 8,
        ), // Reduced padding
        children: [
          _buildFlagOption(context, ref, folder, null, 'None'),
          _buildFlagOption(context, ref, folder, 'Red', 'Red'),
          _buildFlagOption(context, ref, folder, 'Blue', 'Blue'),
          _buildFlagOption(context, ref, folder, 'Green', 'Green'),
          _buildFlagOption(context, ref, folder, 'Orange', 'Orange'),
          _buildFlagOption(context, ref, folder, 'Purple', 'Purple'),
          _buildFlagOption(context, ref, folder, 'Cyan', 'Cyan'),
          _buildFlagOption(context, ref, folder, 'Pink', 'Pink'),
        ],
      ),
    );
  }

  Widget _buildFlagOption(
    BuildContext context,
    WidgetRef ref,
    dynamic folder,
    String? colorValue,
    String label,
  ) {
    final isSelected = folder.flagColor == colorValue;
    return SimpleDialogOption(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      onPressed: () {
        ref
            .read(folderListProvider.notifier)
            .updateFolder(folder.copyWith(flagColor: colorValue));
        Navigator.pop(context);
      },
      child: Row(
        children: [
          // Checkmark (or placeholder)
          Icon(
            Icons.check,
            color: isSelected ? Colors.blue : Colors.transparent,
            size: 24,
          ),
          const SizedBox(width: 16),
          // Label
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ), // Increased size
          ),
          const Spacer(), // Spacer
          // Bookmark Icon
          Icon(
            Icons.bookmark,
            color: _getFlagColor(colorValue) ?? Colors.grey,
            size: 28,
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref, dynamic folder) {
    final controller = TextEditingController(text: folder.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Folder'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Folder name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref
                    .read(folderListProvider.notifier)
                    .updateFolder(folder.copyWith(name: controller.text));
                Navigator.pop(context);
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, dynamic folder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Folder'),
        content: Text(
          'Are you sure you want to delete "${folder.name}"? Sentences in this folder will be moved to the Default folder.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(folderListProvider.notifier).deleteFolder(folder.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
