import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/sentence_providers.dart';
import '../widgets/sentence_list_item.dart';
import '../widgets/sentence_filter_bar.dart';
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

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    // Update _visibleIds only when filters change or it's null
    sentencesAsync.whenData((sentences) {
      if (_visibleIds == null) {
        _visibleIds = sentences.map((s) => s.id).toList();
      }
    });

    // Listen to provider changes to update _visibleIds when filters change
    ref.listen(sentenceFilterProvider, (previous, next) {
      // Refresh visible IDs when filter explicitly changes
      ref.read(filteredSentencesProvider.future).then((sentences) {
        setState(() {
          _visibleIds = sentences.map((s) => s.id).toList();
        });
      });
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('English Surf'),
            floating: true,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.swap_horiz),
                tooltip: languageMode == LanguageMode.originalToTranslation
                    ? 'Original → Translation'
                    : 'Translation → Original',
                onPressed: () {
                  ref.read(languageModeProvider.notifier).toggle();
                },
              ),
              IconButton(
                icon: const Icon(Icons.play_arrow),
                onPressed: () => context.push(
                  '/study',
                  extra: const StudyModeArguments(
                    initialIndex: 0,
                    isTestMode: true,
                  ),
                ),
              ),
            ],
            bottom: const PreferredSize(
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
                      onTap: () => context.push(
                        '/study',
                        extra: StudyModeArguments(
                          initialIndex: index,
                          isTestMode: false,
                        ),
                      ),
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
                        // Refresh list only if the card should no longer be visible
                        ref.read(filteredSentencesProvider.future).then((
                          sentences,
                        ) {
                          if (mounted) {
                            final stillVisible = sentences.any(
                              (s) => s.id == sentence.id,
                            );
                            if (!stillVisible) {
                              setState(() => _visibleIds = null);
                            }
                          }
                        });
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
      floatingActionButton: Row(
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
