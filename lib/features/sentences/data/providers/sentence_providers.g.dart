// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sentence_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sentenceLocalDataSource)
const sentenceLocalDataSourceProvider = SentenceLocalDataSourceProvider._();

final class SentenceLocalDataSourceProvider
    extends
        $FunctionalProvider<
          SentenceLocalDataSource,
          SentenceLocalDataSource,
          SentenceLocalDataSource
        >
    with $Provider<SentenceLocalDataSource> {
  const SentenceLocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sentenceLocalDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sentenceLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<SentenceLocalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SentenceLocalDataSource create(Ref ref) {
    return sentenceLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SentenceLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SentenceLocalDataSource>(value),
    );
  }
}

String _$sentenceLocalDataSourceHash() =>
    r'957cb31c7fdc25cf1b91255897042986a1236ec6';

@ProviderFor(sentenceRepository)
const sentenceRepositoryProvider = SentenceRepositoryProvider._();

final class SentenceRepositoryProvider
    extends
        $FunctionalProvider<
          SentenceRepository,
          SentenceRepository,
          SentenceRepository
        >
    with $Provider<SentenceRepository> {
  const SentenceRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sentenceRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sentenceRepositoryHash();

  @$internal
  @override
  $ProviderElement<SentenceRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SentenceRepository create(Ref ref) {
    return sentenceRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SentenceRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SentenceRepository>(value),
    );
  }
}

String _$sentenceRepositoryHash() =>
    r'0b7c109ba03a40be67322db6c43c5757b386e5c0';
