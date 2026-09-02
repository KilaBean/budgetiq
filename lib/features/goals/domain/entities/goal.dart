import 'package:equatable/equatable.dart';

import '../../../../shared/domain/money.dart';

/// A single contribution toward a goal (append-only fact).
class GoalContribution extends Equatable {
  const GoalContribution({
    required this.id,
    required this.amount,
    required this.occurredOn,
    this.note,
  });

  final String id;
  final Money amount;
  final DateTime occurredOn;
  final String? note;

  @override
  List<Object?> get props => [id, amount, occurredOn, note];
}

enum GoalStatus { active, met, archived }

/// A savings goal with a target amount and optional deadline.
class Goal extends Equatable {
  const Goal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currencyCode,
    required this.contributions,
    this.targetDate,
    this.status = GoalStatus.active,
  });

  final String id;
  final String name;
  final Money targetAmount;
  final String currencyCode;
  final List<GoalContribution> contributions;
  final DateTime? targetDate;
  final GoalStatus status;

  /// Sum of all contributions.
  Money get contributed =>
      contributions.fold(Money.zero(currencyCode), (sum, c) => sum + c.amount);

  @override
  List<Object?> get props => [
    id,
    name,
    targetAmount,
    currencyCode,
    contributions,
    targetDate,
    status,
  ];
}
