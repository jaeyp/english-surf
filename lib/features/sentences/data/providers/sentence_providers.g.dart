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

@ProviderFor(appDatabase)
const appDatabaseProvider = AppDatabaseProvider._();

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  const AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'63ee888947c6b70ff7ffbf17b8b09651fda53b06';

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
    r'891a11070644e1f2096931a536dab320c039bc7a';

@ProviderFor(folderRepository)
const folderRepositoryProvider = FolderRepositoryProvider._();

final class FolderRepositoryProvider
    extends
        $FunctionalProvider<
          FolderRepository,
          FolderRepository,
          FolderRepository
        >
    with $Provider<FolderRepository> {
  const FolderRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'folderRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$folderRepositoryHash();

  @$internal
  @override
  $ProviderElement<FolderRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FolderRepository create(Ref ref) {
    return folderRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FolderRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FolderRepository>(value),
    );
  }
}

String _$folderRepositoryHash() => r'7fafc846d583aa26e35eb0162de33143bef6b668';

@ProviderFor(sharedPreferences)
const sharedPreferencesProvider = SharedPreferencesProvider._();

final class SharedPreferencesProvider
    extends
        $FunctionalProvider<
          SharedPreferences,
          SharedPreferences,
          SharedPreferences
        >
    with $Provider<SharedPreferences> {
  const SharedPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharedPreferencesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedPreferencesHash();

  @$internal
  @override
  $ProviderElement<SharedPreferences> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SharedPreferences create(Ref ref) {
    return sharedPreferences(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SharedPreferences value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SharedPreferences>(value),
    );
  }
}

String _$sharedPreferencesHash() => r'999569711a4cb996c2bdb3a7dae3d55c4ec99b70';

@ProviderFor(settingsRepository)
const settingsRepositoryProvider = SettingsRepositoryProvider._();

final class SettingsRepositoryProvider
    extends
        $FunctionalProvider<
          SettingsRepository,
          SettingsRepository,
          SettingsRepository
        >
    with $Provider<SettingsRepository> {
  const SettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<SettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SettingsRepository create(Ref ref) {
    return settingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsRepository>(value),
    );
  }
}

String _$settingsRepositoryHash() =>
    r'6f93209551a291b3d875b863ebf8d4263b43f84d';
