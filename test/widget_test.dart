import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:english_surf/l10n/app_localizations.dart';
import 'package:english_surf/features/home/presentation/home_screen.dart';

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

    // Verify that the title and body text are present.
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Welcome to Flutter Boilerplate'), findsOneWidget);
  });
}
