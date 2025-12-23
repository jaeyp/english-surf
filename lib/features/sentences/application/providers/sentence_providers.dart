import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/sentence.dart';
import '../../domain/enums/difficulty.dart';
import '../../domain/enums/sort_type.dart';
import '../../data/providers/sentence_providers.dart';

part 'sentence_providers.g.dart';

/// ----------------------------------------------------------------------------
/// Provider: SentenceList
/// ----------------------------------------------------------------------------
///
/// **Why it is needed:**
/// The UI needs a way to fetch and display the list of sentences from the data layer
/// without directly interacting with the Repository. It also needs to handle
/// asynchronous states like loading, error, and success automatically.
///
/// **Role:**
/// Acts as the source of truth for the raw sentence data. It communicates with
/// the [SentenceRepository] to fetch data and expose s it as an [AsyncValue].
///
/// **Advantages:**
/// - Decouples the UI from the Data Layer.
/// - Automatically handles async loading and error states.
/// - Caches the data, preventing unnecessary network/disk requests.
///
@riverpod
class SentenceList extends _$SentenceList {
  @override
  Future<List<Sentence>> build() async {
    print('DEBUG: SentenceList.build called. Fetching all sentences...');
    final repository = ref.watch(sentenceRepositoryProvider);
    final sentences = await repository.getAllSentences();
    print('DEBUG: SentenceList.build received ${sentences.length} sentences.');
    return sentences;
  }

  Future<void> addSentence(Sentence sentence) async {
    final repository = ref.read(sentenceRepositoryProvider);
    print('DEBUG: Adding sentence to repository: ${sentence.original.text}');
    await repository.addSentence(sentence);
    print('DEBUG: Sentence added. Invalidating provider...');
    // Refresh the list from the source of truth to get the correct auto-generated ID
    ref.invalidateSelf();
    await future;
  }

  Future<void> updateSentence(Sentence updatedSentence) async {
    final repository = ref.read(sentenceRepositoryProvider);
    await repository.updateSentence(updatedSentence);

    final sentences = await future;
    state = AsyncData(
      sentences.map((s) {
        return s.id == updatedSentence.id ? updatedSentence : s;
      }).toList(),
    );
  }

  Future<void> deleteSentence(int id) async {
    final repository = ref.read(sentenceRepositoryProvider);
    await repository.deleteSentence(id);

    final sentences = await future;
    state = AsyncData(sentences.where((s) => s.id != id).toList());
  }
}

/// ----------------------------------------------------------------------------
/// State: SentenceFilterState
/// ----------------------------------------------------------------------------
/// Simple record-like class to hold filter state.
/// Using a class instead of a Record for better readability in this context.
class SentenceFilterState {
  final Difficulty? difficulty;
  final SortType sortType;

  const SentenceFilterState({this.difficulty, this.sortType = SortType.random});

  SentenceFilterState copyWith({Difficulty? difficulty, SortType? sortType}) {
    return SentenceFilterState(
      difficulty: difficulty ?? this.difficulty,
      sortType: sortType ?? this.sortType,
    );
  }
}

/// ----------------------------------------------------------------------------
/// Provider: SentenceFilter
/// ----------------------------------------------------------------------------
///
/// **Why it is needed:**
/// The user needs to filter sentences by difficulty or sort them by different criteria.
/// This state needs to be preserved across screen rebuilds and shared between widgets.
///
/// **Role:**
/// Manages the current state of filters (Difficulty) and sorting (SortType).
/// It provides methods to update these values from the UI.
///
/// **Advantages:**
/// - Keeps the UI stateless regarding filter logic.
/// - Allows multiple widgets (e.g., a filter bar and a list view) to share the same state.
/// - Centralizes state modification logic.
///
@riverpod
class SentenceFilter extends _$SentenceFilter {
  @override
  FutureOr<SentenceFilterState> build() async {
    final repository = ref.watch(settingsRepositoryProvider);
    final sortType = await repository.getSortType();
    final difficulty = await repository.getDifficultyFilter();
    return SentenceFilterState(difficulty: difficulty, sortType: sortType);
  }

  Future<void> setDifficulty(Difficulty? difficulty) async {
    final repository = ref.read(settingsRepositoryProvider);
    await repository.saveDifficultyFilter(difficulty);
    final current = state.value;
    if (current != null) {
      state = AsyncData(
        SentenceFilterState(difficulty: difficulty, sortType: current.sortType),
      );
    }
  }

  Future<void> setSortType(SortType sortType) async {
    final repository = ref.read(settingsRepositoryProvider);
    await repository.saveSortType(sortType);
    final current = state.value;
    if (current != null) {
      state = AsyncData(current.copyWith(sortType: sortType));
    }
  }
}

/// ----------------------------------------------------------------------------
/// Provider: FilteredSentences
/// ----------------------------------------------------------------------------
///
/// **Why it is needed:**
/// The [SentenceList] provider returns raw data, but the UI often needs to show
/// a subset of that data based on user preferences (filters). Computing this
/// inside the UI widget's build method is inefficient and clutters the UI code.
///
/// **Role:**
/// Listens to both [SentenceList] (data) and [SentenceFilter] (preferences).
/// It applies business logic (filtering and sorting) to the raw data and returns
/// the final list to be displayed.
///
/// **Advantages:**
/// - **Memoization:** Only re-computes when the data or filter changes, optimizing performance.
/// - **Separation of Concerns:** Keeps business logic (filtering/sorting) out of the UI.
/// - **Testability:** The logic can be tested independently of the UI.
///
@riverpod
Future<List<Sentence>> filteredSentences(Ref ref) async {
  final sentences = await ref.watch(sentenceListProvider.future);
  final filterState = await ref.watch(sentenceFilterProvider.future);

  var result = List<Sentence>.from(sentences);

  // 1. Filter by Difficulty
  if (filterState.difficulty != null) {
    result = result
        .where((s) => s.difficulty == filterState.difficulty)
        .toList();
  }

  // 2. Sort
  switch (filterState.sortType) {
    case SortType.order:
      result.sort((a, b) => a.order.compareTo(b.order));
      break;
    case SortType.random:
      result.shuffle();
      break;
  }
  return result;
}

/// ----------------------------------------------------------------------------
/// Enum: LanguageMode
/// ----------------------------------------------------------------------------
enum LanguageMode {
  originalToTranslation, // Original -> Translation (Default)
  translationToOriginal, // Translation -> Original
}

/// ----------------------------------------------------------------------------
/// Provider: LanguageMode
/// ----------------------------------------------------------------------------
@riverpod
class LanguageModeNotifier extends _$LanguageModeNotifier {
  @override
  FutureOr<LanguageMode> build() async {
    final repository = ref.watch(settingsRepositoryProvider);
    return await repository.getLanguageMode();
  }

  Future<void> toggle() async {
    if (!state.hasValue) return;

    final current = state.value!;
    final next = current == LanguageMode.originalToTranslation
        ? LanguageMode.translationToOriginal
        : LanguageMode.originalToTranslation;

    final repository = ref.read(settingsRepositoryProvider);
    await repository.saveLanguageMode(next);
    state = AsyncData(next);
  }
}
