import '../../../../shared/domain/money.dart';
import '../../domain/entities/goal.dart';

/// Maps goal rows (with embedded goal_contributions) to the [Goal] aggregate.
class GoalModel {
  const GoalModel._();

  static Goal fromJson(Map<String, dynamic> json, String currencyCode) {
    final currency = currencyCode;
    final rawContributions =
        (json['goal_contributions'] as List?) ?? const <dynamic>[];

    final contributions =
        rawContributions
            .whereType<Map>()
            .map((c) => c.cast<String, dynamic>())
            // Embedded rows include soft-deleted ones; exclude them here.
            .where((c) => c['deleted_at'] == null)
            .map((c) => _contributionFromJson(c, currency))
            .toList()
          ..sort((a, b) => b.occurredOn.compareTo(a.occurredOn));

    return Goal(
      id: json['id'] as String,
      name: json['name'] as String,
      currencyCode: currency,
      targetAmount: Money.fromDatabase(
        json['target_amount'] as Object,
        currencyCode: currency,
      ),
      targetDate: json['target_date'] == null
          ? null
          : DateTime.parse(json['target_date'] as String),
      status: _status(json['status'] as String?),
      contributions: contributions,
    );
  }

  static GoalContribution _contributionFromJson(
    Map<String, dynamic> json,
    String currency,
  ) {
    return GoalContribution(
      id: json['id'] as String,
      amount: Money.fromDatabase(
        json['amount'] as Object,
        currencyCode: currency,
      ),
      occurredOn: DateTime.parse(json['occurred_on'] as String),
      note: json['note'] as String?,
    );
  }

  static GoalStatus _status(String? raw) => switch (raw) {
    'met' => GoalStatus.met,
    'archived' => GoalStatus.archived,
    _ => GoalStatus.active,
  };
}
