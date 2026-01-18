import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:english_surf/features/sentences/domain/entities/sentence.dart';
import 'package:english_surf/features/sentences/domain/value_objects/sentence_text.dart';
import 'package:english_surf/features/sentences/domain/enums/difficulty.dart';
import 'package:english_surf/features/sentences/presentation/widgets/sentence_card.dart';
import 'package:english_surf/features/sentences/application/providers/sentence_providers.dart';

void main() {
  final testSentence = const Sentence(
    id: 1,
    order: 1,
    original: SentenceText(text: 'Hello World'),
    translation: '안녕 세상',
    difficulty: Difficulty.beginner,
    notes: 'Test Note',
    paraphrases: ['Example 1'],
  );

  group('SentenceCard', () {
    testWidgets(
      'should display Original on front in originalToTranslation mode',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SentenceCard(
                sentence: testSentence,
                languageMode: LanguageMode.originalToTranslation,
              ),
            ),
          ),
        );

        // Front should show Original (RichText)
        expect(find.text('Hello World', findRichText: true), findsOneWidget);
        expect(find.text('안녕 세상'), findsNothing);
      },
    );

    testWidgets(
      'should display Translation on front in translationToOriginal mode',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SentenceCard(
                sentence: testSentence,
                languageMode: LanguageMode.translationToOriginal,
              ),
            ),
          ),
        );

        // Front should show Translation (Text)
        expect(find.text('안녕 세상'), findsOneWidget);
        expect(find.text('Hello World', findRichText: true), findsNothing);
      },
    );

    testWidgets(
      'should display Back content with Notes/Examples when flipped',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SentenceCard(
                sentence: testSentence,
                languageMode: LanguageMode.originalToTranslation,
              ),
            ),
          ),
        );

        // Initial: Front (Original)
        expect(find.text('Hello World', findRichText: true), findsOneWidget);

        // Tap near top of card to avoid SelectableText (which consumes taps)
        // Card is centered in 600h screen. Height 400. Top at 100.
        // Tap at 150 is inside card (100 < 150 < 500).
        await tester.tapAt(const Offset(400, 150));
        await tester.pumpAndSettle(); // Wait for animation

        // Back: Translation + Notes + Examples
        expect(find.text('안녕 세상'), findsOneWidget);
        expect(find.text('Test Note'), findsOneWidget);
        expect(find.text('Example 1'), findsOneWidget);
      },
    );

    testWidgets(
      'should flip when tapping outside the visual card (expanded tap area)',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 300,
                  height: 600,
                  child: SentenceCard(
                    sentence: testSentence,
                    languageMode: LanguageMode.originalToTranslation,
                  ),
                ),
              ),
            ),
          ),
        );

        // Initial: Front
        expect(find.text('Hello World', findRichText: true), findsOneWidget);

        // Card is centered in 800x600 screen, occupying 300x600.
        // It starts at x = (800-300)/2 = 250.
        // Tapping at x=400 (inside), y=50 (above visual card)
        await tester.tapAt(const Offset(400, 50));
        await tester.pumpAndSettle();

        // Should be flipped
        expect(find.text('안녕 세상'), findsOneWidget);
      },
    );

    testWidgets('should display star icon and trigger callback', (
      tester,
    ) async {
      bool isFavoriteToggled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SentenceCard(
              sentence: testSentence.copyWith(isFavorite: true),
              languageMode: LanguageMode.originalToTranslation,
              onFavoriteToggle: () {
                isFavoriteToggled = true;
              },
            ),
          ),
        ),
      );

      // Verify star icon presence
      expect(find.byIcon(Icons.star), findsOneWidget);

      // Tap the star icon
      await tester.tap(find.byIcon(Icons.star));
      await tester.pump();

      // Verify callback triggered
      expect(isFavoriteToggled, isTrue);
    });
  });
}
