import 'package:flutter/material.dart';

import 'entities/transaction.dart';

/// Immutable filter criteria for the transaction list.
class TransactionFilter {
  const TransactionFilter({this.dateRange, this.categoryIds = const {}});

  final DateTimeRange? dateRange;

  /// Empty means "all categories".
  final Set<String> categoryIds;

  bool get isActive => dateRange != null || categoryIds.isNotEmpty;

  int get activeCount =>
      (dateRange != null ? 1 : 0) + (categoryIds.isNotEmpty ? 1 : 0);

  TransactionFilter copyWith({
    Object? dateRange = _sentinel,
    Set<String>? categoryIds,
  }) => TransactionFilter(
    dateRange: dateRange == _sentinel
        ? this.dateRange
        : dateRange as DateTimeRange?,
    categoryIds: categoryIds ?? this.categoryIds,
  );

  List<Transaction> apply(List<Transaction> all) {
    return all.where((t) {
      if (dateRange != null) {
        final d = DateTime(
          t.occurredOn.year,
          t.occurredOn.month,
          t.occurredOn.day,
        );
        final start = DateTime(
          dateRange!.start.year,
          dateRange!.start.month,
          dateRange!.start.day,
        );
        final end = DateTime(
          dateRange!.end.year,
          dateRange!.end.month,
          dateRange!.end.day,
        );
        if (d.isBefore(start) || d.isAfter(end)) return false;
      }
      if (categoryIds.isNotEmpty && !categoryIds.contains(t.categoryId ?? '')) {
        return false;
      }
      return true;
    }).toList();
  }
}

// Sentinel so copyWith can distinguish "pass null" from "omit".
const Object _sentinel = Object();
