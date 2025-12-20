import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/sentence_providers.dart';
import '../widgets/sentence_list_item.dart';
import '../widgets/sentence_filter_bar.dart';
import 'package:go_router/go_router.dart';

class SentenceListScreen extends ConsumerWidget {
  const SentenceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sentencesAsync = ref.watch(filteredSentencesProvider);
    final languageMode = ref.watch(languageModeProvider);

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('English Surf'),
            floating: true,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent, // Prevents Material 3 tinting
            elevation: 0,
            actions: [
              // Toggle Mode Button (Icon Only)
              IconButton(
                icon: const Icon(Icons.swap_horiz),
                tooltip: languageMode == LanguageMode.originalToTranslation
                    ? 'Original → Translation'
                    : 'Translation → Original',
                onPressed: () {
                  ref.read(languageModeProvider.notifier).toggle();
                },
              ),
              // Study Mode Button
              IconButton(
                icon: const Icon(Icons.play_arrow),
                onPressed: () => context.push('/study'),
              ),
              // Add Sentence Button
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => context.push('/edit'),
              ),
            ],
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(
                66,
              ), // Increased to accommodate consistent bottom margin
              child: SentenceFilterBar(),
            ),
          ),

          // Sentence List
          sentencesAsync.when(
            data: (sentences) {
              if (sentences.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('No sentences found.')),
                );
              }
              return SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: isLandscape ? 32.0 : 0.0,
                  vertical: 8.0,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Align items to start
                    children: sentences.asMap().entries.map((entry) {
                      final index = entry.key;
                      final sentence = entry.value;
                      return SentenceListItem(
                        sentence: sentence,
                        languageMode: languageMode,
                        onTap: () => context.push('/study', extra: index),
                        onEdit: () => context.push('/edit', extra: sentence),
                        onDelete: () {
                          ref
                              .read(sentenceListProvider.notifier)
                              .deleteSentence(sentence.id);
                        },
                      );
                    }).toList(),
                  ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/edit'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
