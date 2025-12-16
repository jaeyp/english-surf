import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/sentence_providers.dart';
import '../widgets/sentence_list_item.dart';
import '../widgets/sentence_filter_bar.dart';
import 'study_mode_screen.dart';

class SentenceListScreen extends ConsumerWidget {
  const SentenceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sentencesAsync = ref.watch(filteredSentencesProvider);
    final languageMode = ref.watch(languageModeProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('English Surf'),
            floating: true,
            pinned: true,
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
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const StudyModeScreen(),
                    ),
                  );
                },
              ),
              // Add Sentence Button
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  // TODO: Navigate to Add Screen
                },
              ),
            ],
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(50),
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
              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final sentence = sentences[index];
                  return SentenceListItem(
                    sentence: sentence,
                    languageMode: languageMode,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              StudyModeScreen(initialIndex: index),
                        ),
                      );
                    },
                    onEdit: () {
                      // TODO: Navigate to Edit Screen
                    },
                    onDelete: () {
                      // TODO: Call Repository to delete (Phase 5)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Delete not implemented yet (Phase 5)'),
                        ),
                      );
                    },
                  );
                }, childCount: sentences.length),
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
    );
  }
}
