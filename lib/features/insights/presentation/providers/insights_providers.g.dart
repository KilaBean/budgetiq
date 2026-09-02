// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insights_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Deterministic insights for the current month.

@ProviderFor(insights)
final insightsProvider = InsightsProvider._();

/// Deterministic insights for the current month.

final class InsightsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Insight>>,
          List<Insight>,
          FutureOr<List<Insight>>
        >
    with $FutureModifier<List<Insight>>, $FutureProvider<List<Insight>> {
  /// Deterministic insights for the current month.
  InsightsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'insightsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$insightsHash();

  @$internal
  @override
  $FutureProviderElement<List<Insight>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Insight>> create(Ref ref) {
    return insights(ref);
  }
}

String _$insightsHash() => r'466511a262e142d38d6d8fec01f1c9237f387d5c';

/// The 0–100 financial health score with its factor breakdown.

@ProviderFor(healthScore)
final healthScoreProvider = HealthScoreProvider._();

/// The 0–100 financial health score with its factor breakdown.

final class HealthScoreProvider
    extends
        $FunctionalProvider<
          AsyncValue<HealthScore>,
          HealthScore,
          FutureOr<HealthScore>
        >
    with $FutureModifier<HealthScore>, $FutureProvider<HealthScore> {
  /// The 0–100 financial health score with its factor breakdown.
  HealthScoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'healthScoreProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$healthScoreHash();

  @$internal
  @override
  $FutureProviderElement<HealthScore> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<HealthScore> create(Ref ref) {
    return healthScore(ref);
  }
}

String _$healthScoreHash() => r'56d576fb8615af406798891a54731fd0c11dc566';
