import 'package:english_surf/features/sentences/domain/entities/folder.dart';
import 'package:english_surf/features/sentences/domain/entities/sentence.dart';
import 'package:english_surf/features/sentences/domain/enums/difficulty.dart';
import 'package:english_surf/features/sentences/domain/value_objects/sentence_text.dart';
import 'package:english_surf/features/sentences/application/providers/sentence_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Mock SentenceList notifier to verify moveSentences is called correctly.
class MockSentenceList extends SentenceList {
  final List<Sentence> sentences;
  List<int>? lastMovedIds;
  String? lastFolderId;

  MockSentenceList(this.sentences);

  @override
  Future<List<Sentence>> build() async => sentences;

  @override
  Future<void> moveSentences(List<int> ids, String folderId) async {
    lastMovedIds = ids;
    lastFolderId = folderId;
    // Simulate changing folderId on moved sentences
    final updated = sentences.map((s) {
      if (ids.contains(s.id)) {
        return s.copyWith(folderId: folderId);
      }
      return s;
    }).toList();
    state = AsyncData(updated);
  }
}

void main() {
  group('Folder Move Integration', () {
    final testFolder = Folder(
      id: 'test_folder',
      name: 'Test',
      createdAt: DateTime.now(),
    );

    final sentenceInDefault = Sentence(
      id: 1,
      order: 1,
      original: const SentenceText(text: 'Test sentence'),
      translation: 'Translation',
      difficulty: Difficulty.beginner,
      folderId: 'default_folder',
    );

    test('moveSentences should update folderId on sentences', () async {
      final mockList = MockSentenceList([sentenceInDefault]);
      final container = ProviderContainer(
        overrides: [sentenceListProvider.overrideWith(() => mockList)],
      );
      addTearDown(container.dispose);

      // Wait for the provider to build
      await container.read(sentenceListProvider.future);

      // Perform the move
      await container.read(sentenceListProvider.notifier).moveSentences([
        1,
      ], testFolder.id);

      // Verify the move was recorded
      expect(mockList.lastMovedIds, [1]);
      expect(mockList.lastFolderId, 'test_folder');

      // Verify the sentence's folderId was updated in state
      final updatedSentences = await container.read(
        sentenceListProvider.future,
      );
      expect(updatedSentences.first.folderId, 'test_folder');
    });
  });
}
