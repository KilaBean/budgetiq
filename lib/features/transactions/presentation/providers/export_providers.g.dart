// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Exports all transactions as a CSV file via the system share sheet.
/// State is `true` while the export is in progress.

@ProviderFor(TransactionExportController)
final transactionExportControllerProvider =
    TransactionExportControllerProvider._();

/// Exports all transactions as a CSV file via the system share sheet.
/// State is `true` while the export is in progress.
final class TransactionExportControllerProvider
    extends $NotifierProvider<TransactionExportController, bool> {
  /// Exports all transactions as a CSV file via the system share sheet.
  /// State is `true` while the export is in progress.
  TransactionExportControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionExportControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionExportControllerHash();

  @$internal
  @override
  TransactionExportController create() => TransactionExportController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$transactionExportControllerHash() =>
    r'8c6bc0f8f17c42842f7c3786545c56e4604973c7';

/// Exports all transactions as a CSV file via the system share sheet.
/// State is `true` while the export is in progress.

abstract class _$TransactionExportController extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
