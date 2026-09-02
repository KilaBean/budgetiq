// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(transactionRepository)
final transactionRepositoryProvider = TransactionRepositoryProvider._();

final class TransactionRepositoryProvider
    extends
        $FunctionalProvider<
          TransactionRepository,
          TransactionRepository,
          TransactionRepository
        >
    with $Provider<TransactionRepository> {
  TransactionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionRepositoryHash();

  @$internal
  @override
  $ProviderElement<TransactionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TransactionRepository create(Ref ref) {
    return transactionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransactionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransactionRepository>(value),
    );
  }
}

String _$transactionRepositoryHash() =>
    r'cc71299b0ba874437626bc8e380fb9f40a083014';

/// Loads and manages transactions of a given [kind].
///
/// Holds the rolling window the app opens on; [loadOlder] appends pages of
/// older history on demand.

@ProviderFor(TransactionList)
final transactionListProvider = TransactionListFamily._();

/// Loads and manages transactions of a given [kind].
///
/// Holds the rolling window the app opens on; [loadOlder] appends pages of
/// older history on demand.
final class TransactionListProvider
    extends $AsyncNotifierProvider<TransactionList, TransactionPage> {
  /// Loads and manages transactions of a given [kind].
  ///
  /// Holds the rolling window the app opens on; [loadOlder] appends pages of
  /// older history on demand.
  TransactionListProvider._({
    required TransactionListFamily super.from,
    required TransactionKind super.argument,
  }) : super(
         retry: null,
         name: r'transactionListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$transactionListHash();

  @override
  String toString() {
    return r'transactionListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TransactionList create() => TransactionList();

  @override
  bool operator ==(Object other) {
    return other is TransactionListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$transactionListHash() => r'd09bb84ae3a23b3c693b5114487deca45f6c245f';

/// Loads and manages transactions of a given [kind].
///
/// Holds the rolling window the app opens on; [loadOlder] appends pages of
/// older history on demand.

final class TransactionListFamily extends $Family
    with
        $ClassFamilyOverride<
          TransactionList,
          AsyncValue<TransactionPage>,
          TransactionPage,
          FutureOr<TransactionPage>,
          TransactionKind
        > {
  TransactionListFamily._()
    : super(
        retry: null,
        name: r'transactionListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Loads and manages transactions of a given [kind].
  ///
  /// Holds the rolling window the app opens on; [loadOlder] appends pages of
  /// older history on demand.

  TransactionListProvider call(TransactionKind kind) =>
      TransactionListProvider._(argument: kind, from: this);

  @override
  String toString() => r'transactionListProvider';
}

/// Loads and manages transactions of a given [kind].
///
/// Holds the rolling window the app opens on; [loadOlder] appends pages of
/// older history on demand.

abstract class _$TransactionList extends $AsyncNotifier<TransactionPage> {
  late final _$args = ref.$arg as TransactionKind;
  TransactionKind get kind => _$args;

  FutureOr<TransactionPage> build(TransactionKind kind);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<TransactionPage>, TransactionPage>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TransactionPage>, TransactionPage>,
              AsyncValue<TransactionPage>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// Active filter for a transaction list. Scoped per [kind] so income and
/// expense tabs maintain independent filter state.

@ProviderFor(TransactionFilterController)
final transactionFilterControllerProvider =
    TransactionFilterControllerFamily._();

/// Active filter for a transaction list. Scoped per [kind] so income and
/// expense tabs maintain independent filter state.
final class TransactionFilterControllerProvider
    extends $NotifierProvider<TransactionFilterController, TransactionFilter> {
  /// Active filter for a transaction list. Scoped per [kind] so income and
  /// expense tabs maintain independent filter state.
  TransactionFilterControllerProvider._({
    required TransactionFilterControllerFamily super.from,
    required TransactionKind super.argument,
  }) : super(
         retry: null,
         name: r'transactionFilterControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$transactionFilterControllerHash();

  @override
  String toString() {
    return r'transactionFilterControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TransactionFilterController create() => TransactionFilterController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransactionFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransactionFilter>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TransactionFilterControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$transactionFilterControllerHash() =>
    r'df148d7ac4038df1246be9ed96a062ab290dfc6e';

/// Active filter for a transaction list. Scoped per [kind] so income and
/// expense tabs maintain independent filter state.

final class TransactionFilterControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          TransactionFilterController,
          TransactionFilter,
          TransactionFilter,
          TransactionFilter,
          TransactionKind
        > {
  TransactionFilterControllerFamily._()
    : super(
        retry: null,
        name: r'transactionFilterControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Active filter for a transaction list. Scoped per [kind] so income and
  /// expense tabs maintain independent filter state.

  TransactionFilterControllerProvider call(TransactionKind kind) =>
      TransactionFilterControllerProvider._(argument: kind, from: this);

  @override
  String toString() => r'transactionFilterControllerProvider';
}

/// Active filter for a transaction list. Scoped per [kind] so income and
/// expense tabs maintain independent filter state.

abstract class _$TransactionFilterController
    extends $Notifier<TransactionFilter> {
  late final _$args = ref.$arg as TransactionKind;
  TransactionKind get kind => _$args;

  TransactionFilter build(TransactionKind kind);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<TransactionFilter, TransactionFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TransactionFilter, TransactionFilter>,
              TransactionFilter,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// Loaded transactions of [kind]. `null` while the first page loads.
///
/// Most consumers want the rows rather than the paging state, so they watch
/// this instead of unwrapping [TransactionPage] themselves.

@ProviderFor(transactionItems)
final transactionItemsProvider = TransactionItemsFamily._();

/// Loaded transactions of [kind]. `null` while the first page loads.
///
/// Most consumers want the rows rather than the paging state, so they watch
/// this instead of unwrapping [TransactionPage] themselves.

final class TransactionItemsProvider
    extends
        $FunctionalProvider<
          List<Transaction>?,
          List<Transaction>?,
          List<Transaction>?
        >
    with $Provider<List<Transaction>?> {
  /// Loaded transactions of [kind]. `null` while the first page loads.
  ///
  /// Most consumers want the rows rather than the paging state, so they watch
  /// this instead of unwrapping [TransactionPage] themselves.
  TransactionItemsProvider._({
    required TransactionItemsFamily super.from,
    required TransactionKind super.argument,
  }) : super(
         retry: null,
         name: r'transactionItemsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$transactionItemsHash();

  @override
  String toString() {
    return r'transactionItemsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<Transaction>?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<Transaction>? create(Ref ref) {
    final argument = this.argument as TransactionKind;
    return transactionItems(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Transaction>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Transaction>?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TransactionItemsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$transactionItemsHash() => r'0545a8bc9da74ac13e23da8de86ce4d61163afd5';

/// Loaded transactions of [kind]. `null` while the first page loads.
///
/// Most consumers want the rows rather than the paging state, so they watch
/// this instead of unwrapping [TransactionPage] themselves.

final class TransactionItemsFamily extends $Family
    with $FunctionalFamilyOverride<List<Transaction>?, TransactionKind> {
  TransactionItemsFamily._()
    : super(
        retry: null,
        name: r'transactionItemsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Loaded transactions of [kind]. `null` while the first page loads.
  ///
  /// Most consumers want the rows rather than the paging state, so they watch
  /// this instead of unwrapping [TransactionPage] themselves.

  TransactionItemsProvider call(TransactionKind kind) =>
      TransactionItemsProvider._(argument: kind, from: this);

  @override
  String toString() => r'transactionItemsProvider';
}

/// Filtered + sorted transaction list. `null` while the underlying list loads.
///
/// Filtering applies to the transactions loaded so far — the opening window
/// plus any older pages the user has pulled in.

@ProviderFor(filteredTransactions)
final filteredTransactionsProvider = FilteredTransactionsFamily._();

/// Filtered + sorted transaction list. `null` while the underlying list loads.
///
/// Filtering applies to the transactions loaded so far — the opening window
/// plus any older pages the user has pulled in.

final class FilteredTransactionsProvider
    extends
        $FunctionalProvider<
          List<Transaction>?,
          List<Transaction>?,
          List<Transaction>?
        >
    with $Provider<List<Transaction>?> {
  /// Filtered + sorted transaction list. `null` while the underlying list loads.
  ///
  /// Filtering applies to the transactions loaded so far — the opening window
  /// plus any older pages the user has pulled in.
  FilteredTransactionsProvider._({
    required FilteredTransactionsFamily super.from,
    required TransactionKind super.argument,
  }) : super(
         retry: null,
         name: r'filteredTransactionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$filteredTransactionsHash();

  @override
  String toString() {
    return r'filteredTransactionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<Transaction>?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<Transaction>? create(Ref ref) {
    final argument = this.argument as TransactionKind;
    return filteredTransactions(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Transaction>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Transaction>?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredTransactionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$filteredTransactionsHash() =>
    r'50f675c17ddd76e683f35f336380f8d9c1f9f460';

/// Filtered + sorted transaction list. `null` while the underlying list loads.
///
/// Filtering applies to the transactions loaded so far — the opening window
/// plus any older pages the user has pulled in.

final class FilteredTransactionsFamily extends $Family
    with $FunctionalFamilyOverride<List<Transaction>?, TransactionKind> {
  FilteredTransactionsFamily._()
    : super(
        retry: null,
        name: r'filteredTransactionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Filtered + sorted transaction list. `null` while the underlying list loads.
  ///
  /// Filtering applies to the transactions loaded so far — the opening window
  /// plus any older pages the user has pulled in.

  FilteredTransactionsProvider call(TransactionKind kind) =>
      FilteredTransactionsProvider._(argument: kind, from: this);

  @override
  String toString() => r'filteredTransactionsProvider';
}

/// Sum of the current month's transactions for [kind], derived from
/// [TransactionList]. Returns `null` while loading / on error.

@ProviderFor(currentMonthTotal)
final currentMonthTotalProvider = CurrentMonthTotalFamily._();

/// Sum of the current month's transactions for [kind], derived from
/// [TransactionList]. Returns `null` while loading / on error.

final class CurrentMonthTotalProvider
    extends $FunctionalProvider<Money?, Money?, Money?>
    with $Provider<Money?> {
  /// Sum of the current month's transactions for [kind], derived from
  /// [TransactionList]. Returns `null` while loading / on error.
  CurrentMonthTotalProvider._({
    required CurrentMonthTotalFamily super.from,
    required TransactionKind super.argument,
  }) : super(
         retry: null,
         name: r'currentMonthTotalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$currentMonthTotalHash();

  @override
  String toString() {
    return r'currentMonthTotalProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Money?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Money? create(Ref ref) {
    final argument = this.argument as TransactionKind;
    return currentMonthTotal(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Money? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Money?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CurrentMonthTotalProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$currentMonthTotalHash() => r'eb39193859588e6a63b8298a600b04004783fdad';

/// Sum of the current month's transactions for [kind], derived from
/// [TransactionList]. Returns `null` while loading / on error.

final class CurrentMonthTotalFamily extends $Family
    with $FunctionalFamilyOverride<Money?, TransactionKind> {
  CurrentMonthTotalFamily._()
    : super(
        retry: null,
        name: r'currentMonthTotalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Sum of the current month's transactions for [kind], derived from
  /// [TransactionList]. Returns `null` while loading / on error.

  CurrentMonthTotalProvider call(TransactionKind kind) =>
      CurrentMonthTotalProvider._(argument: kind, from: this);

  @override
  String toString() => r'currentMonthTotalProvider';
}
