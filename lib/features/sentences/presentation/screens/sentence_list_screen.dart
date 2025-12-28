import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/folder_providers.dart';
import '../../application/providers/selection_providers.dart';
import '../../application/providers/sentence_providers.dart';
import '../widgets/sentence_list_item.dart';
import '../widgets/sentence_filter_bar.dart';
import '../widgets/selection_bottom_bar.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/arguments/study_mode_arguments.dart';

class SentenceListScreen extends ConsumerStatefulWidget {
  const SentenceListScreen({super.key});

  @override
  ConsumerState<SentenceListScreen> createState() => _SentenceListScreenState();
}

class _SentenceListScreenState extends ConsumerState<SentenceListScreen> {
  List<int>? _visibleIds;

  @override
  Widget build(BuildContext context) {
    final sentencesAsync = ref.watch(filteredSentencesProvider);
    final allSentencesAsync = ref.watch(sentenceListProvider);
    final languageMode =
        ref.watch(languageModeProvider).value ??
        LanguageMode.translationToOriginal;

    final isSelectionMode = ref.watch(selectionModeProvider);
    final selection = ref.watch(selectionProvider);
    final currentFolderId = ref.watch(currentFolderProvider);
    final folders = ref.watch(folderListProvider).value ?? [];
    final currentFolder = currentFolderId != null
        ? folders.firstWhere(
            (f) => f.id == currentFolderId,
            orElse: () => folders.firstWhere((f) => f.id == 'default_folder'),
          )
        : null;

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    // Update _visibleIds only when filters change or it's null
    sentencesAsync.whenData((sentences) {
      if (_visibleIds == null) {
        _visibleIds = sentences.map((s) => s.id).toList();
      }
    });

    // Helper to reset visible IDs
    void resetVisibleIds() {
      if (mounted) setState(() => _visibleIds = null);
    }

    // Listen to folder and selection mode changes to reset visible IDs
    ref.listen(currentFolderProvider, (prev, next) {
      if (prev != next) resetVisibleIds();
    });
    ref.listen(selectionModeProvider, (prev, next) {
      if (prev == true && next == false) resetVisibleIds();
    });

    // Listen to filter changes to refresh visible IDs
    ref.listen(sentenceFilterProvider, (previous, next) {
      resetVisibleIds();
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottomNavigationBar: isSelectionMode ? const SelectionBottomBar() : null,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(
              isSelectionMode
                  ? '${selection.length} selected'
                  : (currentFolder?.name ?? 'EnglishSurf'),
            ),
            leading: isSelectionMode
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () =>
                        ref.read(selectionModeProvider.notifier).setMode(false),
                  )
                : const BackButton(),
            floating: true,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            actions: isSelectionMode
                ? [
                    IconButton(
                      icon: const Icon(Icons.select_all),
                      onPressed: () {
                        if (_visibleIds != null) {
                          ref
                              .read(selectionProvider.notifier)
                              .selectAll(_visibleIds!);
                        }
                      },
                    ),
                  ]
                : [
                    IconButton(
                      icon: const Icon(Icons.swap_horiz),
                      tooltip:
                          languageMode == LanguageMode.originalToTranslation
                          ? 'Original → Translation'
                          : 'Translation → Original',
                      onPressed: () {
                        ref.read(languageModeProvider.notifier).toggle();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.play_arrow),
                      onPressed: () async {
                        await context.push(
                          '/study',
                          extra: const StudyModeArguments(
                            initialIndex: 0,
                            isTestMode: true,
                          ),
                        );
                        if (mounted) resetVisibleIds();
                      },
                    ),
                  ],
            bottom: isSelectionMode
                ? null
                : const PreferredSize(
                    preferredSize: Size.fromHeight(66),
                    child: SentenceFilterBar(),
                  ),
          ),

          // Sentence List
          allSentencesAsync.when(
            data: (allSentences) {
              if (_visibleIds == null && sentencesAsync.isLoading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final displaySentences =
                  _visibleIds
                      ?.map((id) => allSentences.firstWhere((s) => s.id == id))
                      .toList() ??
                  [];

              if (displaySentences.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('No sentences found.')),
                );
              }

              return SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: isLandscape ? 32.0 : 0.0,
                  vertical: 8.0,
                ),
                sliver: SliverList.builder(
                  itemCount: displaySentences.length,
                  itemBuilder: (context, index) {
                    final sentence = displaySentences[index];
                    return SentenceListItem(
                      sentence: sentence,
                      languageMode: languageMode,
                      isSelectionMode: isSelectionMode,
                      isSelected: selection.contains(sentence.id),
                      onSelect: (val) => ref
                          .read(selectionProvider.notifier)
                          .toggle(sentence.id),
                      onLongPress: () {
                        if (!isSelectionMode) {
                          ref
                              .read(selectionModeProvider.notifier)
                              .setMode(true);
                          ref
                              .read(selectionProvider.notifier)
                              .toggle(sentence.id);
                        }
                      },
                      onTap: () async {
                        await context.push(
                          '/study',
                          extra: StudyModeArguments(
                            initialIndex: index,
                            isTestMode: false,
                          ),
                        );
                        if (mounted) resetVisibleIds();
                      },
                      onEdit: () async {
                        await context.push('/edit', extra: sentence);
                        if (mounted) setState(() => _visibleIds = null);
                      },
                      onDelete: () {
                        setState(() {
                          _visibleIds?.remove(sentence.id);
                        });
                        ref
                            .read(sentenceListProvider.notifier)
                            .deleteSentence(sentence.id);
                      },
                      onToggleFavorite: () {
                        // Reset visible IDs to ensure the list reflects any changes
                        // (e.g., if a favorite filter is active)
                        resetVisibleIds();
                      },
                    );
                  },
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) =>
                SliverFillRemaining(child: Center(child: Text('Error: $err'))),
          ),
        ],
      ),
      floatingActionButton: isSelectionMode
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'camera_fab',
                  onPressed: () async {
                    await context.push('/camera');
                    // Clear visible IDs to refresh list when coming back from camera
                    setState(() => _visibleIds = null);
                  },
                  child: const Icon(Icons.camera_alt),
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  heroTag: 'add_fab',
                  onPressed: () async {
                    await context.push('/edit');
                    // Clear visible IDs to refresh list when coming back from add
                    setState(() => _visibleIds = null);
                  },
                  child: const Icon(Icons.add),
                ),
              ],
            ),
    );
  }
}
