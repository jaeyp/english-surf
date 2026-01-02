import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:english_surf/features/sentences/domain/entities/sentence.dart';
import 'package:english_surf/features/sentences/domain/value_objects/sentence_text.dart';
import 'package:english_surf/features/sentences/domain/enums/difficulty.dart';
import 'package:english_surf/features/sentences/domain/enums/sort_type.dart';
import 'package:english_surf/features/sentences/domain/repositories/sentence_repository.dart';
import 'package:english_surf/features/sentences/domain/repositories/settings_repository.dart';
import 'package:english_surf/features/sentences/data/providers/sentence_providers.dart'
    as data_providers;
import 'package:english_surf/features/sentences/application/providers/sentence_providers.dart';
import 'package:mocktail/mocktail.dart';

class MockSentenceRepository extends Mock implements SentenceRepository {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(SortType.random);
    registerFallbackValue(Difficulty.beginner);
    registerFallbackValue(LanguageMode.translationToOriginal);
  });

  late MockSentenceRepository mockRepository;
  late MockSettingsRepository mockSettingsRepository;

  setUp(() {
    mockRepository = MockSentenceRepository();
    mockSettingsRepository = MockSettingsRepository();

    // Default mock behavior
    when(
      () => mockSettingsRepository.getSortType(),
    ).thenAnswer((_) async => SortType.random);
    when(
      () => mockSettingsRepository.getDifficultyFilter(),
    ).thenAnswer((_) async => null);
    when(
      () => mockSettingsRepository.saveSortType(any()),
    ).thenAnswer((_) async => {});
    when(
      () => mockSettingsRepository.saveDifficultyFilter(any()),
    ).thenAnswer((_) async => {});
    when(
      () => mockSettingsRepository.getShowFavoritesOnly(),
    ).thenAnswer((_) async => false);
    when(
      () => mockSettingsRepository.saveShowFavoritesOnly(any()),
    ).thenAnswer((_) async => {});
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        data_providers.sentenceRepositoryProvider.overrideWithValue(
          mockRepository,
        ),
        data_providers.settingsRepositoryProvider.overrideWithValue(
          mockSettingsRepository,
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  final sentences = [
    const Sentence(
      id: 1,
      order: 1,
      original: SentenceText(text: 'Sentence 1'),
      translation: '쉬움',
      difficulty: Difficulty.beginner,
    ),
    const Sentence(
      id: 2,
      order: 2,
      original: SentenceText(text: 'Sentence 2'),
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

      // Ensure filter is loaded
      await container.read(sentenceFilterProvider.future);

      // 1. Set to Advanced
      await container
          .read(sentenceFilterProvider.notifier)
          .setDifficulty(Difficulty.advanced);
      var filtered = await container.read(filteredSentencesProvider.future);
      expect(filtered.length, 1);
      expect(filtered.first.difficulty, Difficulty.advanced);

      // 2. Set back to All (null)
      await container.read(sentenceFilterProvider.notifier).setDifficulty(null);
      filtered = await container.read(filteredSentencesProvider.future);

      expect(
        filtered.length,
        2,
        reason:
            'After setting difficulty to null, all sentences should be returned',
      );
    });

    test('should sort by order', () async {
      when(
        () => mockRepository.getAllSentences(),
      ).thenAnswer((_) async => [sentences[1], sentences[0]]);
      final container = createContainer();

      // Ensure filter is loaded
      await container.read(sentenceFilterProvider.future);

      await container
          .read(sentenceFilterProvider.notifier)
          .setSortType(SortType.order);
      final filtered = await container.read(filteredSentencesProvider.future);

      expect(filtered[0].order, 1);
      expect(filtered[1].order, 2);
    });

    test('should filter by favorites', () async {
      final favSentences = [
        sentences[0].copyWith(isFavorite: true),
        sentences[1].copyWith(isFavorite: false),
      ];
      when(
        () => mockRepository.getAllSentences(),
      ).thenAnswer((_) async => favSentences);
      final container = createContainer();

      await container.read(sentenceFilterProvider.future);

      // Act
      await container
          .read(sentenceFilterProvider.notifier)
          .toggleFavoritesOnly();
      final filtered = await container.read(filteredSentencesProvider.future);

      // Assert
      expect(filtered.length, 1);
      expect(filtered.first.id, 1);
    });

    test(
      'should save favorites filter state to repository when toggled',
      () async {
        when(
          () => mockRepository.getAllSentences(),
        ).thenAnswer((_) async => sentences);
        final container = createContainer();
        await container.read(sentenceFilterProvider.future);

        // Act
        await container
            .read(sentenceFilterProvider.notifier)
            .toggleFavoritesOnly();

        // Assert
        verify(
          () => mockSettingsRepository.saveShowFavoritesOnly(true),
        ).called(1);
      },
    );

    test(
      'should rehydrate showFavoritesOnly state from settings on build',
      () async {
        // Setup: Mock repository to return true for favorites filter
        when(
          () => mockSettingsRepository.getShowFavoritesOnly(),
        ).thenAnswer((_) async => true);
        when(
          () => mockRepository.getAllSentences(),
        ).thenAnswer((_) async => sentences);

        final container = createContainer();

        // Act
        final filterState = await container.read(sentenceFilterProvider.future);

        // Assert
        expect(filterState.showFavoritesOnly, true);
      },
    );
  });
}
