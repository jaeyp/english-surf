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

      expect(find.text('Add Sentence'), findsOneWidget);
      expect(find.byType(TextFormField), findsAtLeastNWidgets(3));

      // Verify Bottom Buttons
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget); // Save
      expect(find.byType(OutlinedButton), findsOneWidget); // Cancel
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
        examples: ['Example 1'],
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

      expect(find.text('Edit Sentence'), findsOneWidget);

      final textFields = tester
          .widgetList<TextFormField>(find.byType(TextFormField))
          .toList();
      expect(textFields[0].controller?.text, 'Original Text');
      expect(textFields[1].controller?.text, 'Translated Text');
      expect(textFields[2].controller?.text, 'Some notes');
      expect(textFields[3].controller?.text, 'Example 1');

      // Verify Save button is still there
      expect(find.widgetWithText(ElevatedButton, 'Save'), findsOneWidget);
    });
  });
}
