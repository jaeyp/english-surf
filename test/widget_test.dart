import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:english_surf/l10n/app_localizations.dart';
import 'package:english_surf/features/home/presentation/screens/home_screen.dart';

void main() {
  testWidgets('HomeScreen displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: HomeScreen(),
        ),
      ),
    );

    // Verify that the title is present.
    expect(find.text('EnglishSurf'), findsOneWidget);
    // Verify that the Add Folder FAB is present
    expect(find.byIcon(Icons.create_new_folder), findsOneWidget);
  });
}
