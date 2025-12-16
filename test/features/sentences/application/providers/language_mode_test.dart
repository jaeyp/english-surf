import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:english_surf/features/sentences/application/providers/sentence_providers.dart';

void main() {
  group('LanguageModeNotifier', () {
    test('initial state should be originalToTranslation', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final mode = container.read(languageModeProvider);
      expect(mode, LanguageMode.originalToTranslation);
    });

    test(
      'toggle should switch between originalToTranslation and translationToOriginal',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        // Initial state
        expect(
          container.read(languageModeProvider),
          LanguageMode.originalToTranslation,
        );

        // Toggle 1: Orig -> Trans
        container.read(languageModeProvider.notifier).toggle();
        expect(
          container.read(languageModeProvider),
          LanguageMode.translationToOriginal,
        );

        // Toggle 2: Trans -> Orig
        container.read(languageModeProvider.notifier).toggle();
        expect(
          container.read(languageModeProvider),
          LanguageMode.originalToTranslation,
        );
      },
    );
  });
}
