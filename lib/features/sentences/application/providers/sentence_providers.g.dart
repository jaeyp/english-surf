// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sentence_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(SentenceList)
const sentenceListProvider = SentenceListProvider._();

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
final class SentenceListProvider
    extends $AsyncNotifierProvider<SentenceList, List<Sentence>> {
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
  const SentenceListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sentenceListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sentenceListHash();

  @$internal
  @override
  SentenceList create() => SentenceList();
}

String _$sentenceListHash() => r'54e222bcdd37342b32ab02b8d031481adc3e6fe5';

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

abstract class _$SentenceList extends $AsyncNotifier<List<Sentence>> {
  FutureOr<List<Sentence>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Sentence>>, List<Sentence>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Sentence>>, List<Sentence>>,
              AsyncValue<List<Sentence>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
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

@ProviderFor(SentenceFilter)
const sentenceFilterProvider = SentenceFilterProvider._();

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
final class SentenceFilterProvider
    extends $AsyncNotifierProvider<SentenceFilter, SentenceFilterState> {
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
  const SentenceFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sentenceFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sentenceFilterHash();

  @$internal
  @override
  SentenceFilter create() => SentenceFilter();
}

String _$sentenceFilterHash() => r'45ea17f2e08b16b87344ec7d6d9d2c66b7e54354';

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

abstract class _$SentenceFilter extends $AsyncNotifier<SentenceFilterState> {
  FutureOr<SentenceFilterState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<SentenceFilterState>, SentenceFilterState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SentenceFilterState>, SentenceFilterState>,
              AsyncValue<SentenceFilterState>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
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

@ProviderFor(filteredSentences)
const filteredSentencesProvider = FilteredSentencesProvider._();

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

final class FilteredSentencesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Sentence>>,
          List<Sentence>,
          FutureOr<List<Sentence>>
        >
    with $FutureModifier<List<Sentence>>, $FutureProvider<List<Sentence>> {
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
  const FilteredSentencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredSentencesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredSentencesHash();

  @$internal
  @override
  $FutureProviderElement<List<Sentence>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Sentence>> create(Ref ref) {
    return filteredSentences(ref);
  }
}

String _$filteredSentencesHash() => r'4f7286db4bf0cc6acb02bb900e01d3e64805081d';

/// ----------------------------------------------------------------------------
/// Provider: LanguageMode
/// ----------------------------------------------------------------------------

@ProviderFor(LanguageModeNotifier)
const languageModeProvider = LanguageModeNotifierProvider._();

/// ----------------------------------------------------------------------------
/// Provider: LanguageMode
/// ----------------------------------------------------------------------------
final class LanguageModeNotifierProvider
    extends $AsyncNotifierProvider<LanguageModeNotifier, LanguageMode> {
  /// ----------------------------------------------------------------------------
  /// Provider: LanguageMode
  /// ----------------------------------------------------------------------------
  const LanguageModeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'languageModeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$languageModeNotifierHash();

  @$internal
  @override
  LanguageModeNotifier create() => LanguageModeNotifier();
}

String _$languageModeNotifierHash() =>
    r'6cce712a0c94fa9f189f91b6488d1bae0144cb08';

/// ----------------------------------------------------------------------------
/// Provider: LanguageMode
/// ----------------------------------------------------------------------------

abstract class _$LanguageModeNotifier extends $AsyncNotifier<LanguageMode> {
  FutureOr<LanguageMode> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<LanguageMode>, LanguageMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<LanguageMode>, LanguageMode>,
              AsyncValue<LanguageMode>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
