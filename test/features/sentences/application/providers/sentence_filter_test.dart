import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:english_surf/features/sentences/application/providers/sentence_providers.dart';
import 'package:english_surf/features/sentences/domain/entities/sentence.dart';
import 'package:english_surf/features/sentences/domain/value_objects/sentence_text.dart';
import 'package:english_surf/features/sentences/domain/enums/difficulty.dart';
import 'package:english_surf/features/sentences/domain/enums/sort_type.dart';
import 'package:english_surf/features/sentences/data/providers/sentence_providers.dart';
import 'package:mocktail/mocktail.dart';
import 'package:english_surf/features/sentences/domain/repositories/sentence_repository.dart';

class MockSentenceRepository extends Mock implements SentenceRepository {}

void main() {
  late MockSentenceRepository mockRepository;

  setUp(() {
    mockRepository = MockSentenceRepository();
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [sentenceRepositoryProvider.overrideWithValue(mockRepository)],
    );
    addTearDown(container.dispose);
    return container;
  }

  final sentences = [
    Sentence(
      id: 1,
      order: 1,
      original: const SentenceText(text: 'Easy'),
      translation: '쉬움',
      difficulty: Difficulty.beginner,
    ),
    Sentence(
      id: 2,
      order: 2,
      original: const SentenceText(text: 'Hard'),
      translation: '어려움',
      difficulty: Difficulty.advanced,
    ),
  ];

  group('SentenceFilter & FilteredSentences', () {
    test('should return all sentences by default', () async {
      when(
        () => mockRepository.getAllSentences(),
      ).thenAnswer((_) async => sentences);
      final container = createContainer();

      final filtered = await container.read(filteredSentencesProvider.future);

      expect(filtered.length, 2);
    });

    test('should filter by difficulty and return to All (null)', () async {
      when(
        () => mockRepository.getAllSentences(),
      ).thenAnswer((_) async => sentences);
      final container = createContainer();

      // 1. Set to Advanced
      container
          .read(sentenceFilterProvider.notifier)
          .setDifficulty(Difficulty.advanced);
      var filtered = await container.read(filteredSentencesProvider.future);
      expect(filtered.length, 1);
      expect(filtered.first.difficulty, Difficulty.advanced);

      // 2. Set back to All (null) -> THIS WAS THE BUG AREA
      container.read(sentenceFilterProvider.notifier).setDifficulty(null);
      filtered = await container.read(filteredSentencesProvider.future);

      expect(
        filtered.length,
        2,
        reason:
            'After setting difficulty to null, all sentences should be returned',
      );
    });

    test('should sort by difficulty', () async {
      when(
        () => mockRepository.getAllSentences(),
      ).thenAnswer((_) async => sentences);
      final container = createContainer();

      container
          .read(sentenceFilterProvider.notifier)
          .setSortType(SortType.difficulty);
      final filtered = await container.read(filteredSentencesProvider.future);

      // Beginner (index 0) should come before Advanced (index 2)
      expect(filtered[0].difficulty, Difficulty.beginner);
      expect(filtered[1].difficulty, Difficulty.advanced);
    });
  });
}
