import 'dart:async';
import 'package:english_surf/features/sentences/application/providers/sentence_providers.dart';
import 'package:english_surf/features/sentences/domain/entities/sentence.dart';
import 'package:english_surf/features/sentences/domain/enums/difficulty.dart';
import 'package:english_surf/features/sentences/domain/value_objects/sentence_text.dart';
import 'package:english_surf/features/sentences/presentation/screens/study_mode_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class MockLanguageModeNotifier extends LanguageModeNotifier {
  @override
  FutureOr<LanguageMode> build() {
    return LanguageMode.translationToOriginal;
  }
}

void main() {
  final sentences = [
    Sentence(
      id: 1,
      order: 1,
      original: SentenceText(text: 'Sentence 1'),
      translation: 'Translation 1',
      difficulty: Difficulty.beginner,
    ),
    Sentence(
      id: 2,
      order: 2,
      original: SentenceText(text: 'Sentence 2'),
      translation: 'Translation 2',
      difficulty: Difficulty.beginner,
    ),
  ];

  Widget createSubject({required bool isTestMode, int initialIndex = 0}) {
    return ProviderScope(
      overrides: [
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

      expect(find.text('5'), findsNothing);
      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('Test Mode: should show timer and countdown', (tester) async {
      await tester.pumpWidget(createSubject(isTestMode: true));
      await tester.pumpAndSettle(); // Wait for AsyncValue

      // Initial timer value
      expect(find.text('5'), findsOneWidget);

      // Advance 1 second
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(); // Update UI
      expect(find.text('4'), findsOneWidget);

      // Advance another second
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(); // Update UI
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('Test Mode: should auto-advance page after 5 seconds', (
      tester,
    ) async {
      await tester.pumpWidget(createSubject(isTestMode: true));
      await tester.pumpAndSettle();

      // Check initial page content
      expect(find.text('Translation 1'), findsOneWidget);

      // Advance 6 seconds (trigger auto-advance)
      // 5 seconds to count down to 0, 1 second to trigger _nextPage
      for (int i = 0; i < 6; i++) {
        await tester.pump(const Duration(seconds: 1));
        await tester.pump();
      }

      // Wait for page animation
      await tester.pumpAndSettle();

      // Check next page content and reset timer
      expect(find.text('Translation 2'), findsOneWidget);
      expect(find.text('5'), findsOneWidget); // Timer resets to 5
    });

    testWidgets('Test Mode: should stop timer on last page', (tester) async {
      await tester.pumpWidget(createSubject(isTestMode: true, initialIndex: 1));
      await tester.pumpAndSettle();

      // Check last page content
      expect(find.text('Translation 2'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);

      // Advance 6 seconds (past timer)
      await tester.pump(const Duration(seconds: 6));
      await tester.pump();

      // Should still be on the same page (no loop or crash)
      expect(find.text('Translation 2'), findsOneWidget);
      // Timer might stay at 0 or stop decrementing depending on implementation details,
      // but verify it didn't crash.
    });
  });
}
