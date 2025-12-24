import 'package:english_surf/features/sentences/presentation/screens/sentence_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:english_surf/features/sentences/application/providers/sentence_providers.dart';

void main() {
  testWidgets('SentenceListScreen should have a Camera button', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [filteredSentencesProvider.overrideWith((ref) => [])],
        child: MaterialApp(home: const SentenceListScreen()),
      ),
    );

    // Initial pump
    await tester.pumpAndSettle();

    // Verify Add button exists (standard FAB)
    expect(find.byIcon(Icons.add), findsOneWidget);

    // Verify Camera button exists (Goal)
    expect(find.byIcon(Icons.camera_alt), findsOneWidget);
  });
}
