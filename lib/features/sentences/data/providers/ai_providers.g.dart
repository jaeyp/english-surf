// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(aiRepository)
const aiRepositoryProvider = AiRepositoryProvider._();

final class AiRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<AiRepository>,
          AiRepository,
          FutureOr<AiRepository>
        >
    with $FutureModifier<AiRepository>, $FutureProvider<AiRepository> {
  const AiRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aiRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aiRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<AiRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AiRepository> create(Ref ref) {
    return aiRepository(ref);
  }
}

String _$aiRepositoryHash() => r'9489f28a47ab9a8e5d3316bfa7cee46a675e2022';
