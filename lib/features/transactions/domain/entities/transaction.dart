import 'package:equatable/equatable.dart';

import '../../../../shared/domain/money.dart';
import '../../../../shared/domain/transaction_kind.dart';

/// A single income or expense entry. Amount is always positive; [kind]
/// determines direction.
class Transaction extends Equatable {
  const Transaction({
    required this.id,
    required this.kind,
    required this.amount,
    required this.occurredOn,
    this.categoryId,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    this.note,
  });

  final String id;
  final TransactionKind kind;
  final Money amount;
  final DateTime occurredOn;
  final String? categoryId;

  /// Denormalized for display (joined from the category table on read).
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColor;
  final String? note;

  @override
  List<Object?> get props => [
    id,
    kind,
    amount,
    occurredOn,
    categoryId,
    categoryName,
    categoryIcon,
    categoryColor,
    note,
  ];
}
