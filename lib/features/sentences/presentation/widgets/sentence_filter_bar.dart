import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/sentence_providers.dart';
import '../../domain/enums/difficulty.dart';
import '../../domain/enums/sort_type.dart';

class SentenceFilterBar extends ConsumerWidget {
  const SentenceFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterStateAsync = ref.watch(sentenceFilterProvider);
    final notifier = ref.read(sentenceFilterProvider.notifier);

    return filterStateAsync.when(
      data: (filterState) {
        final difficultyLabel = filterState.showFavoritesOnly
            ? 'Favorites'
            : _getDifficultyLabel(filterState.difficulty);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: 8,
          ),
          child: Row(
            children: [
              // Sort Chip
              InputChip(
                label: Text(filterState.sortType.label),
                avatar: const Icon(Icons.sort, size: 18),
                onPressed: () =>
                    _showSortOptions(context, notifier, filterState.sortType),
                selected: filterState.sortType != SortType.random,
              ),
              const SizedBox(width: 8),

              // Difficulty Chip
              InputChip(
                label: Text(difficultyLabel),
                avatar: const Icon(Icons.filter_list, size: 18),
                onPressed: () => _showDifficultyOptions(
                  context,
                  notifier,
                  filterState.difficulty,
                  filterState.showFavoritesOnly,
                ),
                selected:
                    filterState.difficulty != null ||
                    filterState.showFavoritesOnly,
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const SizedBox.shrink(),
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
                leading: Icon(
                  Icons.check,
                  color: type == current ? Colors.blue : Colors.transparent,
                ),
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
    bool showFavoritesOnly,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.check,
                  color: (current == null && !showFavoritesOnly)
                      ? Colors.blue
                      : Colors.transparent,
                ),
                title: const Text('All'),
                onTap: () {
                  notifier.setDifficulty(null);
                  if (showFavoritesOnly) notifier.toggleFavoritesOnly();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.check,
                  color: showFavoritesOnly ? Colors.blue : Colors.transparent,
                ),
                title: const Text('Favorites'),
                onTap: () {
                  if (!showFavoritesOnly) notifier.toggleFavoritesOnly();
                  notifier.setDifficulty(null);
                  Navigator.pop(context);
                },
              ),
              ...Difficulty.values.map((diff) {
                return ListTile(
                  leading: Icon(
                    Icons.check,
                    color: (diff == current && !showFavoritesOnly)
                        ? Colors.blue
                        : Colors.transparent,
                  ),
                  title: Text(
                    diff.name[0].toUpperCase() + diff.name.substring(1),
                    style: const TextStyle(fontSize: 14),
                  ),
                  onTap: () {
                    notifier.setDifficulty(diff);
                    if (showFavoritesOnly) notifier.toggleFavoritesOnly();
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
