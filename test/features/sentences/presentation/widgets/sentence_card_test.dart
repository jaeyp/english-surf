import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:english_surf/features/sentences/domain/entities/sentence.dart';
import 'package:english_surf/features/sentences/domain/value_objects/sentence_text.dart';
import 'package:english_surf/features/sentences/domain/enums/difficulty.dart';
import 'package:english_surf/features/sentences/presentation/widgets/sentence_card.dart';
import 'package:english_surf/features/sentences/application/providers/sentence_providers.dart';

void main() {
  final testSentence = Sentence(
    id: 1,
    order: 1,
    original: SentenceText(text: 'Hello World'),
    translation: '안녕 세상',
    difficulty: Difficulty.beginner,
    notes: 'Test Note',
    examples: ['Example 1'],
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
        expect(findRichText('Hello World'), findsOneWidget);
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
        expect(findRichText('Hello World'), findsNothing);
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
        expect(findRichText('Hello World'), findsOneWidget);

        // Tap to flip
        await tester.tap(find.byType(SentenceCard));
        await tester.pumpAndSettle(); // Wait for animation

        // Back: Translation + Notes + Examples
        expect(find.text('안녕 세상'), findsOneWidget);
        expect(find.text('Test Note'), findsOneWidget);
        expect(find.text('Example 1'), findsOneWidget);
      },
    );
  });
}

Finder findRichText(String text) {
  return find.byWidgetPredicate((widget) {
    if (widget is RichText) {
      final span = widget.text as TextSpan;
      return span.toPlainText().contains(text);
    }
    return false;
  });
}
