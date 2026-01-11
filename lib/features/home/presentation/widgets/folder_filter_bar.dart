import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../sentences/application/providers/folder_providers.dart';

class FolderFilterBar extends ConsumerWidget {
  const FolderFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFlag = ref.watch(selectedFlagProvider);
    final allFoldersAsync = ref.watch(folderListProvider);

    // Default to strict 'All' if loading or error,
    // or ideally show available ones if data exists.
    // Since folderListProvider is AsyncValue, we handle it gracefully.
    final availableFlags = allFoldersAsync.when(
      data: (folders) {
        final flags = <String?>{null}; // Always include 'All'
        for (final folder in folders) {
          if (folder.flagColor != null) {
            flags.add(folder.flagColor);
          }
        }
        // Ideally sort the flags to maintain consistent order (e.g. Red, Blue...)
        // We can intersect with our predefined _knownOrder list to keep order.
        return _sortFlags(flags);
      },
      loading: () => [null],
      error: (err, st) => [null],
    );

    return SizedBox(
      height: 70, // Increased height for better touch targets and visual space
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        scrollDirection: Axis.horizontal,
        itemCount: availableFlags.length,
        separatorBuilder: (context, index) => const SizedBox(width: 4),
        itemBuilder: (context, index) {
          final flag = availableFlags[index];
          final isSelected = selectedFlag == flag;

          return InkWell(
            onTap: () {
              ref.read(selectedFlagProvider.notifier).setFlag(flag);
            },
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.transparent, // Background transparent
                borderRadius: BorderRadius.circular(
                  isSelected ? 16 : 8, // Larger radius when selected
                ),
                border: isSelected
                    ? Border.all(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      )
                    : null, // No border when unselected
              ),
              child: Center(
                child: Icon(
                  Icons.bookmark,
                  color: flag == null
                      ? Colors
                            .grey // 'All' color
                      : _getColor(flag),
                  size: 28,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getColor(String colorName) {
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
        return Colors.grey;
    }
  }

  static const List<String> _knownOrder = [
    'Red',
    'Blue',
    'Green',
    'Orange',
    'Purple',
    'Cyan',
    'Pink',
  ];

  List<String?> _sortFlags(Set<String?> flags) {
    final result = <String?>[null]; // All first
    for (final color in _knownOrder) {
      if (flags.contains(color)) {
        result.add(color);
      }
    }
    return result;
  }
}
