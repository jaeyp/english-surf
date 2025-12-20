import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:english_surf/features/sentences/application/providers/sentence_providers.dart';
import 'package:english_surf/features/sentences/domain/entities/sentence.dart';
import 'package:english_surf/features/sentences/domain/value_objects/sentence_text.dart';
import 'package:english_surf/features/sentences/domain/enums/difficulty.dart';
import 'package:english_surf/features/sentences/data/providers/sentence_providers.dart';
import 'package:mocktail/mocktail.dart';
import 'package:english_surf/features/sentences/domain/repositories/sentence_repository.dart';

class MockSentenceRepository extends Mock implements SentenceRepository {}

void main() {
  late MockSentenceRepository mockRepository;

  setUp(() {
    mockRepository = MockSentenceRepository();
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [sentenceRepositoryProvider.overrideWithValue(mockRepository)],
    );
    addTearDown(container.dispose);
    return container;
  }

  final testSentence = Sentence(
    id: 1,
    order: 1,
    original: const SentenceText(text: 'Hello'),
    translation: '안녕',
    difficulty: Difficulty.beginner,
  );

  group('SentenceList', () {
    test('initial state should fetch from repository', () async {
      when(
        () => mockRepository.getAllSentences(),
      ).thenAnswer((_) async => [testSentence]);

      final container = createContainer();

      // Wait for build
      await container.read(sentenceListProvider.future);

      expect(container.read(sentenceListProvider).value, [testSentence]);
    });

    test('addSentence should update state', () async {
      when(() => mockRepository.getAllSentences()).thenAnswer((_) async => []);

      final container = createContainer();

      await container.read(sentenceListProvider.future);
      expect(container.read(sentenceListProvider).value, []);

      await container
          .read(sentenceListProvider.notifier)
          .addSentence(testSentence);

      expect(container.read(sentenceListProvider).value, [testSentence]);
    });

    test('updateSentence should update existing sentence', () async {
      when(
        () => mockRepository.getAllSentences(),
      ).thenAnswer((_) async => [testSentence]);

      final container = createContainer();
      await container.read(sentenceListProvider.future);

      final updated = testSentence.copyWith(translation: '안녕 세상');
      await container
          .read(sentenceListProvider.notifier)
          .updateSentence(updated);

      expect(
        container.read(sentenceListProvider).value!.first.translation,
        '안녕 세상',
      );
    });

    test('deleteSentence should remove sentence from state', () async {
      when(
        () => mockRepository.getAllSentences(),
      ).thenAnswer((_) async => [testSentence]);

      final container = createContainer();
      await container.read(sentenceListProvider.future);

      await container.read(sentenceListProvider.notifier).deleteSentence(1);

      expect(container.read(sentenceListProvider).value, isEmpty);
    });
  });
}
