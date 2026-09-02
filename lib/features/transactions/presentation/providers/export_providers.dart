import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../shared/domain/transaction_kind.dart';
import '../../domain/csv_exporter.dart';
import '../../domain/entities/transaction.dart';
import 'transaction_providers.dart';

part 'export_providers.g.dart';

/// Exports all transactions as a CSV file via the system share sheet.
/// State is `true` while the export is in progress.
@riverpod
class TransactionExportController extends _$TransactionExportController {
  @override
  bool build() => false;

  Future<void> export(BuildContext context) async {
    state = true;
    try {
      // Exports what is loaded: the opening window plus any older pages the
      // user pulled in.
      final income =
          ref.read(transactionItemsProvider(TransactionKind.income)) ??
          const <Transaction>[];
      final expenses =
          ref.read(transactionItemsProvider(TransactionKind.expense)) ??
          const <Transaction>[];

      final csv = buildTransactionCsv([...income, ...expenses]);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/budgetiq_export.csv');
      await file.writeAsString(csv);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'text/csv')],
          subject: 'BudgetIQ transaction export',
        ),
      );
    } finally {
      state = false;
    }
  }
}
