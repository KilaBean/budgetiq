// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_month_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The month the dashboard is showing.
///
/// Everything on the dashboard — summary, insights, budget snapshot — reads
/// this rather than "now", so stepping back a month moves the whole screen
/// together. Bounded to months the loaded window can actually answer for.

@ProviderFor(SelectedMonth)
final selectedMonthProvider = SelectedMonthProvider._();

/// The month the dashboard is showing.
///
/// Everything on the dashboard — summary, insights, budget snapshot — reads
/// this rather than "now", so stepping back a month moves the whole screen
/// together. Bounded to months the loaded window can actually answer for.
final class SelectedMonthProvider
    extends $NotifierProvider<SelectedMonth, Month> {
  /// The month the dashboard is showing.
  ///
  /// Everything on the dashboard — summary, insights, budget snapshot — reads
  /// this rather than "now", so stepping back a month moves the whole screen
  /// together. Bounded to months the loaded window can actually answer for.
  SelectedMonthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedMonthProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedMonthHash();

  @$internal
  @override
  SelectedMonth create() => SelectedMonth();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Month value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Month>(value),
    );
  }
}

String _$selectedMonthHash() => r'c300edd9f7df44147da5215ddc202dc72c933836';

/// The month the dashboard is showing.
///
/// Everything on the dashboard — summary, insights, budget snapshot — reads
/// this rather than "now", so stepping back a month moves the whole screen
/// together. Bounded to months the loaded window can actually answer for.

abstract class _$SelectedMonth extends $Notifier<Month> {
  Month build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Month, Month>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Month, Month>,
              Month,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
