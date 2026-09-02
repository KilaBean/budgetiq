// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(budgetRepository)
final budgetRepositoryProvider = BudgetRepositoryProvider._();

final class BudgetRepositoryProvider
    extends
        $FunctionalProvider<
          BudgetRepository,
          BudgetRepository,
          BudgetRepository
        >
    with $Provider<BudgetRepository> {
  BudgetRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetRepositoryHash();

  @$internal
  @override
  $ProviderElement<BudgetRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BudgetRepository create(Ref ref) {
    return budgetRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BudgetRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BudgetRepository>(value),
    );
  }
}

String _$budgetRepositoryHash() => r'30173fc51f070dc2f0d2785fccf713a408da847a';

/// The current month's budget (or `null` if none has been set up).

@ProviderFor(CurrentBudget)
final currentBudgetProvider = CurrentBudgetProvider._();

/// The current month's budget (or `null` if none has been set up).
final class CurrentBudgetProvider
    extends $AsyncNotifierProvider<CurrentBudget, Budget?> {
  /// The current month's budget (or `null` if none has been set up).
  CurrentBudgetProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentBudgetProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentBudgetHash();

  @$internal
  @override
  CurrentBudget create() => CurrentBudget();
}

String _$currentBudgetHash() => r'caf3255fb1ae8372ea4f7cb82ab4d249d99bfd42';

/// The current month's budget (or `null` if none has been set up).

abstract class _$CurrentBudget extends $AsyncNotifier<Budget?> {
  FutureOr<Budget?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Budget?>, Budget?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Budget?>, Budget?>,
              AsyncValue<Budget?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Spent-vs-allocated summary for the dashboard's selected month, combining the
/// budget with that month's expenses. `null` while either source is loading.

@ProviderFor(currentBudgetSummary)
final currentBudgetSummaryProvider = CurrentBudgetSummaryProvider._();

/// Spent-vs-allocated summary for the dashboard's selected month, combining the
/// budget with that month's expenses. `null` while either source is loading.

final class CurrentBudgetSummaryProvider
    extends $FunctionalProvider<BudgetSummary?, BudgetSummary?, BudgetSummary?>
    with $Provider<BudgetSummary?> {
  /// Spent-vs-allocated summary for the dashboard's selected month, combining the
  /// budget with that month's expenses. `null` while either source is loading.
  CurrentBudgetSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentBudgetSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentBudgetSummaryHash();

  @$internal
  @override
  $ProviderElement<BudgetSummary?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BudgetSummary? create(Ref ref) {
    return currentBudgetSummary(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BudgetSummary? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BudgetSummary?>(value),
    );
  }
}

String _$currentBudgetSummaryHash() =>
    r'32c9e91907ec6f838da74a1d51ff4430fada5d91';
