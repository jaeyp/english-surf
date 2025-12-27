import 'package:english_surf/features/sentences/domain/enums/difficulty.dart';
import 'package:english_surf/features/sentences/domain/enums/sort_type.dart';
import 'package:english_surf/features/sentences/domain/value_objects/sentence_text.dart';
import 'package:english_surf/features/sentences/presentation/screens/sentence_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:english_surf/features/sentences/application/providers/sentence_providers.dart';
import 'package:english_surf/features/sentences/domain/entities/sentence.dart';

class MockSentenceList extends SentenceList {
  final List<Sentence> sentences;
  MockSentenceList(this.sentences);

  @override
  Future<List<Sentence>> build() async => sentences;

  @override
  Future<void> toggleFavorite(int id) async {
    final current = state.value ?? [];
    state = AsyncData(
      current
          .map((s) => s.id == id ? s.copyWith(isFavorite: !s.isFavorite) : s)
          .toList(),
    );
  }
}

class MockSentenceFilter extends SentenceFilter {
  final SentenceFilterState initialState;
  MockSentenceFilter(this.initialState);

  @override
  SentenceFilterState build() => initialState;
}

void main() {
  final favoriteSentence = Sentence(
    id: 1,
    order: 1,
    original: const SentenceText(text: 'Original 1'),
    translation: 'Translation 1',
    difficulty: Difficulty.beginner,
    isFavorite: true,
  );

  testWidgets('SentenceListScreen should have a Camera button', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          filteredSentencesProvider.overrideWith((ref) => []),
          sentenceListProvider.overrideWith(() => MockSentenceList([])),
        ],
        child: const MaterialApp(home: SentenceListScreen()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.camera_alt), findsOneWidget);
  });

  testWidgets(
    'Stability: card should remain visible when unstarred while menu is open',
    (tester) async {
      final mockList = MockSentenceList([favoriteSentence]);
      final filterState = SentenceFilterState(
        difficulty: null,
        sortType: SortType.order,
        showFavoritesOnly: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sentenceFilterProvider.overrideWith(
              () => MockSentenceFilter(filterState),
            ),
            sentenceListProvider.overrideWith(() => mockList),
          ],
          child: const MaterialApp(home: SentenceListScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // 1. Verify card exists
      expect(find.text('Translation 1'), findsOneWidget);

      // 2. Open swipe menu
      await tester.drag(find.text('Translation 1'), const Offset(-300, 0));
      await tester.pumpAndSettle();

      // 3. Verify Favorite button (red star)
      final favoriteButton = find.byIcon(Icons.star);
      expect(favoriteButton, findsOneWidget);

      // 4. Tap Favorite to unstar
      await tester.tap(favoriteButton);
      await tester.pump(); // Update UI

      // Verify icon changed to border
      expect(find.byIcon(Icons.star_border), findsOneWidget);

      // 5. CRITICAL: Card should STILL be visible
      expect(find.text('Translation 1'), findsOneWidget);

      // 6. Close the slidable menu by dragging from the middle towards the right
      await tester.dragFrom(
        tester.getCenter(find.byType(SentenceListScreen)),
        const Offset(500, 0),
      );
      await tester.pumpAndSettle();

      // 7. After closure, card vanishes
      expect(find.text('Translation 1'), findsNothing);
    },
  );
}
