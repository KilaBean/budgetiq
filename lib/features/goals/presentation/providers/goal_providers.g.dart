// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(goalRepository)
final goalRepositoryProvider = GoalRepositoryProvider._();

final class GoalRepositoryProvider
    extends $FunctionalProvider<GoalRepository, GoalRepository, GoalRepository>
    with $Provider<GoalRepository> {
  GoalRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goalRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goalRepositoryHash();

  @$internal
  @override
  $ProviderElement<GoalRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoalRepository create(Ref ref) {
    return goalRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoalRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoalRepository>(value),
    );
  }
}

String _$goalRepositoryHash() => r'5d4300502689e83cf2cfc261211bbb5058946616';

/// Loads and manages the user's goals.

@ProviderFor(GoalList)
final goalListProvider = GoalListProvider._();

/// Loads and manages the user's goals.
final class GoalListProvider
    extends $AsyncNotifierProvider<GoalList, List<Goal>> {
  /// Loads and manages the user's goals.
  GoalListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goalListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goalListHash();

  @$internal
  @override
  GoalList create() => GoalList();
}

String _$goalListHash() => r'e12c007f11929a42af880cd4a91aaed59de8192e';

/// Loads and manages the user's goals.

abstract class _$GoalList extends $AsyncNotifier<List<Goal>> {
  FutureOr<List<Goal>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Goal>>, List<Goal>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Goal>>, List<Goal>>,
              AsyncValue<List<Goal>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Convenience selector for a single goal from the loaded list.

@ProviderFor(goalById)
final goalByIdProvider = GoalByIdFamily._();

/// Convenience selector for a single goal from the loaded list.

final class GoalByIdProvider extends $FunctionalProvider<Goal?, Goal?, Goal?>
    with $Provider<Goal?> {
  /// Convenience selector for a single goal from the loaded list.
  GoalByIdProvider._({
    required GoalByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'goalByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$goalByIdHash();

  @override
  String toString() {
    return r'goalByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Goal?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Goal? create(Ref ref) {
    final argument = this.argument as String;
    return goalById(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Goal? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Goal?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GoalByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$goalByIdHash() => r'c197ebef2fae0b63ab655b77c79818c63d02fa7c';

/// Convenience selector for a single goal from the loaded list.

final class GoalByIdFamily extends $Family
    with $FunctionalFamilyOverride<Goal?, String> {
  GoalByIdFamily._()
    : super(
        retry: null,
        name: r'goalByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Convenience selector for a single goal from the loaded list.

  GoalByIdProvider call(String goalId) =>
      GoalByIdProvider._(argument: goalId, from: this);

  @override
  String toString() => r'goalByIdProvider';
}
