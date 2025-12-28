import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/selection_providers.dart';
import '../../application/providers/sentence_providers.dart';
import '../../application/providers/folder_providers.dart';

class SelectionBottomBar extends ConsumerWidget {
  const SelectionBottomBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectionCount = ref.watch(selectionProvider.select((s) => s.length));
    if (selectionCount == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Text(
              '$selectionCount selected',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _showMoveDialog(context, ref),
              icon: const Icon(Icons.drive_file_move_outlined),
              label: const Text('Move'),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: () => _showDeleteConfirmation(context, ref),
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoveDialog(BuildContext context, WidgetRef ref) {
    showDialog(context: context, builder: (context) => const _BulkMoveDialog());
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Selected'),
        content: Text(
          'Are you sure you want to delete ${ref.read(selectionProvider).length} sentences?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final ids = ref.read(selectionProvider).toList();
              final notifier = ref.read(sentenceListProvider.notifier);
              for (final id in ids) {
                notifier.deleteSentence(id);
              }
              ref.read(selectionModeProvider.notifier).setMode(false);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _BulkMoveDialog extends ConsumerWidget {
  const _BulkMoveDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foldersAsync = ref.watch(folderListProvider);

    return AlertDialog(
      title: const Text('Move to Folder'),
      content: foldersAsync.when(
        data: (folders) => SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: folders.length,
            itemBuilder: (context, index) {
              final folder = folders[index];
              return ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: Text(folder.name),
                onTap: () async {
                  final ids = ref.read(selectionProvider).toList();
                  await ref
                      .read(sentenceListProvider.notifier)
                      .moveSentences(ids, folder.id);
                  ref.read(selectionModeProvider.notifier).setMode(false);
                  if (context.mounted) Navigator.pop(context);
                },
              );
            },
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Text('Error: $err'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
