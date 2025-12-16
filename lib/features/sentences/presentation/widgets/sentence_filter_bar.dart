import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/sentence_providers.dart';
import '../../domain/enums/difficulty.dart';
import '../../domain/enums/sort_type.dart';

class SentenceFilterBar extends ConsumerWidget {
  const SentenceFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(sentenceFilterProvider);
    final notifier = ref.read(sentenceFilterProvider.notifier);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Sort Chip
          InputChip(
            label: Text('Sort: ${filterState.sortType.label}'),
            avatar: const Icon(Icons.sort, size: 18),
            onPressed: () =>
                _showSortOptions(context, notifier, filterState.sortType),
            selected:
                filterState.sortType !=
                SortType.random, // Highlight if not default
          ),
          const SizedBox(width: 8),

          // Difficulty Chip
          InputChip(
            label: Text(
              'Difficulty: ${_getDifficultyLabel(filterState.difficulty)}',
            ),
            avatar: const Icon(Icons.filter_list, size: 18),
            onPressed: () => _showDifficultyOptions(
              context,
              notifier,
              filterState.difficulty,
            ),
            selected: filterState.difficulty != null, // Highlight if filtered
          ),
        ],
      ),
    );
  }

  String _getDifficultyLabel(Difficulty? difficulty) {
    if (difficulty == null) return 'All';
    return difficulty.name[0].toUpperCase() + difficulty.name.substring(1);
  }

  void _showSortOptions(
    BuildContext context,
    SentenceFilter notifier,
    SortType current,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: SortType.values.map((type) {
              return ListTile(
                leading: type == current
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                title: Text(type.label),
                onTap: () {
                  notifier.setSortType(type);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showDifficultyOptions(
    BuildContext context,
    SentenceFilter notifier,
    Difficulty? current,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: current == null
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                title: const Text('All'),
                onTap: () {
                  notifier.setDifficulty(null);
                  Navigator.pop(context);
                },
              ),
              ...Difficulty.values.map((diff) {
                return ListTile(
                  leading: diff == current
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  title: Text(
                    diff.name[0].toUpperCase() + diff.name.substring(1),
                  ),
                  onTap: () {
                    notifier.setDifficulty(diff);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
