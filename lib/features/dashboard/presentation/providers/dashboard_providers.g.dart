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

/// Current-month dashboard headline summary.

@ProviderFor(dashboardSummary)
final dashboardSummaryProvider = DashboardSummaryProvider._();

/// Current-month dashboard headline summary.

final class DashboardSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<DashboardSummary>,
          DashboardSummary,
          FutureOr<DashboardSummary>
        >
    with $FutureModifier<DashboardSummary>, $FutureProvider<DashboardSummary> {
  /// Current-month dashboard headline summary.
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

String _$dashboardSummaryHash() => r'8ec57eda4c090fb735ec013aab0dd9de09d6b281';

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
