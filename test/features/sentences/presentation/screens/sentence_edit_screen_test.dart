import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:english_surf/features/sentences/presentation/screens/sentence_edit_screen.dart';
import 'package:english_surf/features/sentences/domain/entities/sentence.dart';
import 'package:english_surf/features/sentences/domain/value_objects/sentence_text.dart';
import 'package:english_surf/features/sentences/domain/enums/difficulty.dart';
import 'package:english_surf/features/sentences/domain/repositories/sentence_repository.dart';
import 'package:english_surf/features/sentences/data/providers/sentence_providers.dart';
import 'package:mocktail/mocktail.dart';

class MockSentenceRepository extends Mock implements SentenceRepository {}

void main() {
  late MockSentenceRepository mockRepository;

  setUp(() {
    mockRepository = MockSentenceRepository();
    when(() => mockRepository.getAllSentences()).thenAnswer((_) async => []);
  });

  group('SentenceEditScreen', () {
    testWidgets('should display empty form for a new sentence', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sentenceRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: const MaterialApp(home: SentenceEditScreen()),
        ),
      );

      // Verify Title
      expect(find.text('Add Sentence'), findsOneWidget);

      // Verify Labels/Hints (Behavior: User sees these prompts)
      expect(find.text('Key Sentence:'), findsOneWidget);
      expect(find.text('Translation:'), findsOneWidget);
      expect(find.text('Difficulty:'), findsOneWidget);

      // Verify Buttons
      expect(find.widgetWithText(ElevatedButton, 'Save'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Cancel'), findsOneWidget);
    });

    testWidgets('should display existing sentence data in edit mode', (
      tester,
    ) async {
      const sentence = Sentence(
        id: 1,
        order: 1,
        original: SentenceText(text: 'Original Text'),
        translation: 'Translated Text',
        difficulty: Difficulty.beginner,
        notes: 'Some notes',
        paraphrases: ['Example 1'],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sentenceRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: const MaterialApp(
            home: SentenceEditScreen(sentence: sentence),
          ),
        ),
      );

      // Verify Title
      expect(find.text('Edit Sentence'), findsOneWidget);

      // Verify Content is visible (Behavior: User sees the data they are editing)
      expect(find.text('Original Text'), findsOneWidget);
      expect(find.text('Translated Text'), findsOneWidget);
      expect(find.text('Some notes'), findsOneWidget);
      expect(find.text('Example 1'), findsOneWidget);

      // Verify Save button
      expect(find.widgetWithText(ElevatedButton, 'Save'), findsOneWidget);
    });
  });
}
