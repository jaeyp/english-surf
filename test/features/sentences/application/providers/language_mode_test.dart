import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:english_surf/features/sentences/application/providers/sentence_providers.dart';
import 'package:english_surf/features/sentences/data/providers/sentence_providers.dart'
    as data_providers;
import 'package:english_surf/features/sentences/domain/repositories/settings_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late MockSettingsRepository mockSettingsRepository;

  setUp(() {
    mockSettingsRepository = MockSettingsRepository();
    // Default mock behavior
    when(
      () => mockSettingsRepository.getLanguageMode(),
    ).thenAnswer((_) async => LanguageMode.translationToOriginal);
    when(
      () => mockSettingsRepository.saveLanguageMode(any()),
    ).thenAnswer((_) async => {});
  });

  setUpAll(() {
    registerFallbackValue(LanguageMode.translationToOriginal);
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        data_providers.settingsRepositoryProvider.overrideWithValue(
          mockSettingsRepository,
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('LanguageModeNotifier', () {
    test('initial state should be translationToOriginal', () async {
      final container = createContainer();

      final mode = await container.read(languageModeProvider.future);
      expect(mode, LanguageMode.translationToOriginal);
    });

    test(
      'toggle should switch between translationToOriginal and originalToTranslation',
      () async {
        final container = createContainer();

        // Ensure initialized
        await container.read(languageModeProvider.future);

        // Initial state
        expect(
          container.read(languageModeProvider).value,
          LanguageMode.translationToOriginal,
        );

        // Toggle 1: Trans -> Orig
        await container.read(languageModeProvider.notifier).toggle();
        expect(
          container.read(languageModeProvider).value,
          LanguageMode.originalToTranslation,
        );

        // Toggle 2: Orig -> Trans
        await container.read(languageModeProvider.notifier).toggle();
        expect(
          container.read(languageModeProvider).value,
          LanguageMode.translationToOriginal,
        );
      },
    );
  });
}
