// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Resolves the income + expense lists, surfacing loading/error as an
/// AsyncValue so the dashboard can render the right state.

@ProviderFor(dashboardSources)
final dashboardSourcesProvider = DashboardSourcesProvider._();

/// Resolves the income + expense lists, surfacing loading/error as an
/// AsyncValue so the dashboard can render the right state.

final class DashboardSourcesProvider
    extends
        $FunctionalProvider<
          AsyncValue<DashboardSources>,
          DashboardSources,
          FutureOr<DashboardSources>
        >
    with $FutureModifier<DashboardSources>, $FutureProvider<DashboardSources> {
  /// Resolves the income + expense lists, surfacing loading/error as an
  /// AsyncValue so the dashboard can render the right state.
  DashboardSourcesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardSourcesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardSourcesHash();

  @$internal
  @override
  $FutureProviderElement<DashboardSources> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DashboardSources> create(Ref ref) {
    return dashboardSources(ref);
  }
}

String _$dashboardSourcesHash() => r'48bbb88bd235cad62d3ad9934aeac997d3c0061f';

/// Headline summary for the selected month.

@ProviderFor(dashboardSummary)
final dashboardSummaryProvider = DashboardSummaryProvider._();

/// Headline summary for the selected month.

final class DashboardSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<DashboardSummary>,
          DashboardSummary,
          FutureOr<DashboardSummary>
        >
    with $FutureModifier<DashboardSummary>, $FutureProvider<DashboardSummary> {
  /// Headline summary for the selected month.
  DashboardSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardSummaryHash();

  @$internal
  @override
  $FutureProviderElement<DashboardSummary> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DashboardSummary> create(Ref ref) {
    return dashboardSummary(ref);
  }
}

String _$dashboardSummaryHash() => r'f40dcf272a0b7c9e2aecb7181088035821e5a03b';

/// Last-6-months income vs expense trend.

@ProviderFor(dashboardTrend)
final dashboardTrendProvider = DashboardTrendProvider._();

/// Last-6-months income vs expense trend.

final class DashboardTrendProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MonthlyTotals>>,
          List<MonthlyTotals>,
          FutureOr<List<MonthlyTotals>>
        >
    with
        $FutureModifier<List<MonthlyTotals>>,
        $FutureProvider<List<MonthlyTotals>> {
  /// Last-6-months income vs expense trend.
  DashboardTrendProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardTrendProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardTrendHash();

  @$internal
  @override
  $FutureProviderElement<List<MonthlyTotals>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MonthlyTotals>> create(Ref ref) {
    return dashboardTrend(ref);
  }
}

String _$dashboardTrendHash() => r'ec4302ed35058b7f0474e2b2c959b7d611226781';

/// The headline "what can I still spend" figure for the selected month.

@ProviderFor(safeToSpend)
final safeToSpendProvider = SafeToSpendProvider._();

/// The headline "what can I still spend" figure for the selected month.

final class SafeToSpendProvider
    extends
        $FunctionalProvider<
          AsyncValue<SafeToSpend>,
          SafeToSpend,
          FutureOr<SafeToSpend>
        >
    with $FutureModifier<SafeToSpend>, $FutureProvider<SafeToSpend> {
  /// The headline "what can I still spend" figure for the selected month.
  SafeToSpendProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'safeToSpendProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$safeToSpendHash();

  @$internal
  @override
  $FutureProviderElement<SafeToSpend> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SafeToSpend> create(Ref ref) {
    return safeToSpend(ref);
  }
}

String _$safeToSpendHash() => r'9613574331d36b96b6b0b19942d71d3cae4e685f';
