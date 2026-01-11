import 'dart:async';
import 'package:english_surf/features/sentences/application/providers/sentence_providers.dart';
import 'package:english_surf/features/sentences/domain/entities/sentence.dart';
import 'package:english_surf/features/sentences/domain/enums/difficulty.dart';
import 'package:english_surf/features/sentences/domain/value_objects/sentence_text.dart';
import 'package:english_surf/features/study/presentation/screens/study_mode_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class MockLanguageModeNotifier extends LanguageModeNotifier {
  @override
  FutureOr<LanguageMode> build() {
    return LanguageMode.translationToOriginal;
  }
}

class MockSentenceList extends SentenceList {
  final List<Sentence> sentences;
  MockSentenceList(this.sentences);

  @override
  Future<List<Sentence>> build() async => sentences;

  @override
  Future<void> toggleFavorite(int id) async {}

  @override
  Future<void> deleteSentence(int id) async {}
}

void main() {
  const s1 = Sentence(
    id: 1,
    order: 1,
    original: SentenceText(text: 'Sentence 1'),
    translation: 'Translation 1',
    difficulty: Difficulty.beginner,
  );
  const s2 = Sentence(
    id: 2,
    order: 2,
    original: SentenceText(text: 'Sentence 2'),
    translation: 'Translation 2',
    difficulty: Difficulty.intermediate,
  );
  final sentences = [s1, s2];

  Widget createSubject({required bool isTestMode, int initialIndex = 0}) {
    return ProviderScope(
      overrides: [
        sentenceListProvider.overrideWith(() => MockSentenceList(sentences)),
        filteredSentencesProvider.overrideWith((ref) async => sentences),
        languageModeProvider.overrideWith(() => MockLanguageModeNotifier()),
      ],
      child: MaterialApp(
        home: StudyModeScreen(
          initialIndex: initialIndex,
          isTestMode: isTestMode,
        ),
      ),
    );
  }

  group('StudyModeScreen', () {
    testWidgets('Standard Mode: should NOT show timer', (tester) async {
      await tester.pumpWidget(createSubject(isTestMode: false));
      await tester.pumpAndSettle(); // Wait for AsyncValue

      expect(find.text('10'), findsNothing);
      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('Test Mode: should show timer and countdown', (tester) async {
      await tester.pumpWidget(createSubject(isTestMode: true));
      await tester.pumpAndSettle(); // Wait for AsyncValue

      // Initial timer value
      expect(find.text('10'), findsOneWidget);

      // Advance 1 second
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(); // Update UI
      expect(find.text('9'), findsOneWidget);

      // Advance another second
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(); // Update UI
      expect(find.text('8'), findsOneWidget);
    });

    testWidgets('Test Mode: should auto-advance page after 10 seconds', (
      tester,
    ) async {
      await tester.pumpWidget(createSubject(isTestMode: true));
      await tester.pumpAndSettle();

      // Check initial page content
      expect(find.text('Translation 1'), findsOneWidget);

      // Advance 11 seconds (trigger auto-advance)
      // 10 seconds to count down to 0, 1 second to trigger _nextPage
      for (int i = 0; i < 11; i++) {
        await tester.pump(const Duration(seconds: 1));
        await tester.pump();
      }

      // Wait for page animation
      await tester.pumpAndSettle();

      // Check next page content and reset timer
      expect(find.text('Translation 2'), findsOneWidget);
      expect(find.text('10'), findsOneWidget); // Timer resets to 10
    });

    testWidgets('Test Mode: should loop to first page after last page', (
      tester,
    ) async {
      await tester.pumpWidget(createSubject(isTestMode: true, initialIndex: 1));
      await tester.pumpAndSettle();

      // Check last page content
      expect(find.text('Translation 2'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);

      // Advance 11 seconds (past timer)
      await tester.pump(const Duration(seconds: 11));
      await tester.pump();
      await tester.pumpAndSettle();

      // Should loop back to first page
      expect(find.text('Translation 1'), findsOneWidget);
    });

    testWidgets(
      'List Stability: should not remove card when unstarred in filtered study session',
      (tester) async {
        // Setup: Start with a list that includes favorite status
        final favSentences = [
          sentences[0].copyWith(isFavorite: true),
          sentences[1].copyWith(isFavorite: true),
        ];

        // Override with these sentences
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              sentenceListProvider.overrideWith(
                () => MockSentenceList(favSentences),
              ),
              filteredSentencesProvider.overrideWith(
                (ref) async => favSentences,
              ),
              languageModeProvider.overrideWith(
                () => MockLanguageModeNotifier(),
              ),
            ],
            child: const MaterialApp(
              home: StudyModeScreen(initialIndex: 0, isTestMode: false),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Verify initial state (2 cards in total)
        expect(find.text('1 / 2'), findsOneWidget);

        // 2. Unstar the first card
        final starIcon = find.byIcon(Icons.star);
        expect(starIcon, findsOneWidget);
        await tester.tap(starIcon);
        await tester.pump(); // Update icon

        // 3. Verify card still exists in PageView even if unstarred
        expect(find.text('1 / 2'), findsOneWidget);
        expect(find.text('Translation 1'), findsOneWidget);

        // 4. Navigate to next card and back
        final pageView = tester.widget<PageView>(find.byType(PageView));
        pageView.controller!.jumpToPage(1);
        await tester.pumpAndSettle();
        expect(find.text('2 / 2'), findsOneWidget);

        pageView.controller!.jumpToPage(0);
        await tester.pumpAndSettle();
        expect(find.text('1 / 2'), findsOneWidget);
        expect(find.text('Translation 1'), findsOneWidget);
      },
    );

    testWidgets('Test Mode: should pause timer when card is flipped', (
      tester,
    ) async {
      await tester.pumpWidget(createSubject(isTestMode: true));
      await tester.pumpAndSettle();

      // Initial timer value
      expect(find.text('10'), findsOneWidget);

      // Advance 1 second -> should be 9
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      expect(find.byKey(const ValueKey('timer_text')), findsOneWidget);
      expect(
        (tester.widget<Text>(find.byKey(const ValueKey('timer_text')))).data,
        '9',
      );

      // 1. Flip the card to back (pauses timer)
      await tester.tapAt(const Offset(400, 300));
      await tester.pumpAndSettle(); // Wait for flip animation

      // Advance 2 seconds -> should STILL be 9
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();

      final timerTextAfterFlip = tester
          .widget<Text>(find.byKey(const ValueKey('timer_text')))
          .data;
      expect(
        timerTextAfterFlip,
        '9',
        reason: 'Timer should be paused at 9 while flipped',
      );

      // 2. Flip back to front (resumes timer)
      await tester.tapAt(const Offset(400, 300));
      await tester.pumpAndSettle();

      // Advance 1 second -> should be 8
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('timer_text'))).data,
        '8',
      );
    });

    testWidgets(
      'Test Mode: manual swipe should reset timer and cancel previous',
      (tester) async {
        await tester.pumpWidget(createSubject(isTestMode: true));
        await tester.pumpAndSettle();

        // 1. Initial timer at 10
        expect(
          tester.widget<Text>(find.byKey(const ValueKey('timer_text'))).data,
          '10',
        );

        // 2. Advance to 8
        await tester.pump(const Duration(seconds: 2));
        await tester.pump();
        expect(
          tester.widget<Text>(find.byKey(const ValueKey('timer_text'))).data,
          '8',
        );

        // 3. Manually swipe to next page
        await tester.fling(find.byType(PageView), const Offset(-500, 0), 2000);
        await tester.pumpAndSettle();

        // 4. Verify page changed and timer reset
        expect(find.text('2 / 2'), findsOneWidget);
        // Note: pumpAndSettle might advance time enough for one tick
        final timerValue = tester
            .widget<Text>(find.byKey(const ValueKey('timer_text')))
            .data;
        expect(
          timerValue == '10' || timerValue == '9',
          true,
          reason: 'Timer should reset to 10 (might tick to 9 during settle)',
        );

        // 5. Advance 1 second -> should be 8 or 9
        await tester.pump(const Duration(seconds: 1));
        await tester.pump();
        final finalTimerValue = tester
            .widget<Text>(find.byKey(const ValueKey('timer_text')))
            .data;
        expect(
          finalTimerValue == '9' || finalTimerValue == '8',
          true,
          reason: 'Timer should continue from 10/9 down to 9/8',
        );
      },
    );
  });
}
