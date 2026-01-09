// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folder_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FolderList)
const folderListProvider = FolderListProvider._();

final class FolderListProvider
    extends $AsyncNotifierProvider<FolderList, List<Folder>> {
  const FolderListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'folderListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$folderListHash();

  @$internal
  @override
  FolderList create() => FolderList();
}

String _$folderListHash() => r'1609cda9eb24a9aa20d1b8343150dc447a9ae25b';

abstract class _$FolderList extends $AsyncNotifier<List<Folder>> {
  FutureOr<List<Folder>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Folder>>, List<Folder>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Folder>>, List<Folder>>,
              AsyncValue<List<Folder>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(CurrentFolder)
const currentFolderProvider = CurrentFolderProvider._();

final class CurrentFolderProvider
    extends $NotifierProvider<CurrentFolder, String?> {
  const CurrentFolderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentFolderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentFolderHash();

  @$internal
  @override
  CurrentFolder create() => CurrentFolder();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$currentFolderHash() => r'55899272986875b34acad59bf6106933a74a68d6';

abstract class _$CurrentFolder extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(SelectedFlag)
const selectedFlagProvider = SelectedFlagProvider._();

final class SelectedFlagProvider
    extends $NotifierProvider<SelectedFlag, String?> {
  const SelectedFlagProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedFlagProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedFlagHash();

  @$internal
  @override
  SelectedFlag create() => SelectedFlag();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$selectedFlagHash() => r'353898adfc307860907300a509d871c6ff5ccc25';

abstract class _$SelectedFlag extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(filteredFolders)
const filteredFoldersProvider = FilteredFoldersProvider._();

final class FilteredFoldersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Folder>>,
          List<Folder>,
          FutureOr<List<Folder>>
        >
    with $FutureModifier<List<Folder>>, $FutureProvider<List<Folder>> {
  const FilteredFoldersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredFoldersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredFoldersHash();

  @$internal
  @override
  $FutureProviderElement<List<Folder>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Folder>> create(Ref ref) {
    return filteredFolders(ref);
  }
}

String _$filteredFoldersHash() => r'949e7af8010b2ded52091ee00fcec59036f7f2e4';
