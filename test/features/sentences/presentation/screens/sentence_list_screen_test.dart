import 'dart:async';
import 'package:english_surf/features/sentences/domain/enums/difficulty.dart';
import 'package:english_surf/features/sentences/domain/enums/sort_type.dart';
import 'package:english_surf/features/sentences/domain/value_objects/sentence_text.dart';
import 'package:english_surf/features/sentences/presentation/screens/sentence_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart';
import 'package:english_surf/features/sentences/application/providers/folder_providers.dart';
import 'package:english_surf/features/sentences/application/providers/sentence_providers.dart';
import 'package:english_surf/features/sentences/data/local/db/app_database.dart';
import 'package:english_surf/features/sentences/data/providers/sentence_providers.dart';
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
  FutureOr<SentenceFilterState> build() => initialState;
}

class MockCurrentFolder extends CurrentFolder {
  final String? initialFolderId;
  MockCurrentFolder(this.initialFolderId);

  @override
  String? build() => initialFolderId;
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

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
          appDatabaseProvider.overrideWithValue(
            AppDatabase(NativeDatabase.memory()),
          ),
          filteredSentencesProvider.overrideWith((ref) => []),
          sentenceListProvider.overrideWith(() => MockSentenceList([])),
          sentenceFilterProvider.overrideWith(
            () => MockSentenceFilter(const SentenceFilterState()),
          ),
          currentFolderProvider.overrideWith(() => MockCurrentFolder(null)),
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
            currentFolderProvider.overrideWith(() => MockCurrentFolder(null)),
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

  testWidgets('should enter selection mode on long press', (tester) async {
    final sentences = [favoriteSentence];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(
            AppDatabase(NativeDatabase.memory()),
          ),
          sentenceListProvider.overrideWith(() => MockSentenceList(sentences)),
          sentenceFilterProvider.overrideWith(
            () => MockSentenceFilter(const SentenceFilterState()),
          ),
          currentFolderProvider.overrideWith(() => MockCurrentFolder(null)),
        ],
        child: const MaterialApp(home: SentenceListScreen()),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Long press a list item
    await tester.longPress(find.text('Translation 1'));
    await tester.pumpAndSettle();

    // 2. Verify selection mode is active (Found in both AppBar and SelectionBottomBar)
    expect(find.text('1 selected'), findsNWidgets(2));
    // 3. Verify selection bottom bar is visible
    expect(
      find.byIcon(Icons.drive_file_move_outlined),
      findsOneWidget,
    ); // Move icon in SelectionBottomBar
    expect(
      find.byIcon(Icons.delete_outline),
      findsOneWidget,
    ); // Delete icon in SelectionBottomBar
  });

  testWidgets('should select all visible items when Select All is pressed', (
    tester,
  ) async {
    final sentences = [
      favoriteSentence,
      favoriteSentence.copyWith(id: 2, translation: 'Translation 2'),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(
            AppDatabase(NativeDatabase.memory()),
          ),
          sentenceListProvider.overrideWith(() => MockSentenceList(sentences)),
          sentenceFilterProvider.overrideWith(
            () => MockSentenceFilter(const SentenceFilterState()),
          ),
          currentFolderProvider.overrideWith(() => MockCurrentFolder(null)),
        ],
        child: const MaterialApp(home: SentenceListScreen()),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Enter selection mode
    await tester.longPress(find.text('Translation 1'));
    await tester.pumpAndSettle();

    // 2. Tap Select All
    await tester.tap(find.byIcon(Icons.select_all));
    await tester.pumpAndSettle();

    // 3. Verify all selected (Found in both AppBar and SelectionBottomBar)
    expect(find.text('2 selected'), findsNWidgets(2));
  });
}
