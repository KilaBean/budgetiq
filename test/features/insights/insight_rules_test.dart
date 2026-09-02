import 'package:budgetiq/features/insights/domain/entities/insight.dart';
import 'package:budgetiq/features/insights/domain/services/insight_rules.dart';
import 'package:budgetiq/features/transactions/domain/entities/transaction.dart';
import 'package:budgetiq/shared/domain/money.dart';
import 'package:budgetiq/shared/domain/month.dart';
import 'package:budgetiq/shared/domain/transaction_kind.dart';
import 'package:flutter_test/flutter_test.dart';

Transaction _e(double amount, DateTime on, {String? category}) => Transaction(
  id: 'e-$amount-${on.millisecondsSinceEpoch}-${category ?? ''}',
  kind: TransactionKind.expense,
  amount: Money.fromMajor(amount),
  occurredOn: on,
  categoryName: category,
);

Transaction _i(double amount, DateTime on) => Transaction(
  id: 'i-$amount-${on.millisecondsSinceEpoch}',
  kind: TransactionKind.income,
  amount: Money.fromMajor(amount),
  occurredOn: on,
);

void main() {
  const june = Month(2026, 6);

  test('flags spending more on a category month-over-month', () {
    final insights = generateInsights(
      month: june,
      income: const [],
      expense: [
        _e(100, DateTime(2026, 5, 5), category: 'Food'),
        _e(118, DateTime(2026, 6, 5), category: 'Food'), // +18%
      ],
    );
    expect(
      insights.any(
        (i) =>
            i.type == InsightType.spendingChange &&
            i.message.contains('18%') &&
            i.message.contains('Food'),
      ),
      isTrue,
    );
  });

  test('detects a 3-month consecutive category increase', () {
    final insights = generateInsights(
      month: june,
      income: const [],
      expense: [
        _e(50, DateTime(2026, 3, 1), category: 'Transport'),
        _e(60, DateTime(2026, 4, 1), category: 'Transport'),
        _e(70, DateTime(2026, 5, 1), category: 'Transport'),
        _e(90, DateTime(2026, 6, 1), category: 'Transport'),
      ],
    );
    expect(insights.any((i) => i.type == InsightType.spendingTrend), isTrue);
  });

  test('warns when spending exceeds income', () {
    final insights = generateInsights(
      month: june,
      income: [_i(1000, DateTime(2026, 6, 1))],
      expense: [_e(1200, DateTime(2026, 6, 2))],
    );
    expect(
      insights.any(
        (i) =>
            i.type == InsightType.savingsRate &&
            i.severity == InsightSeverity.negative,
      ),
      isTrue,
    );
  });

  test('praises a strong savings rate', () {
    final insights = generateInsights(
      month: june,
      income: [_i(1000, DateTime(2026, 6, 1))],
      expense: [_e(500, DateTime(2026, 6, 2))], // 50% saved
    );
    expect(
      insights.any(
        (i) =>
            i.type == InsightType.savingsRate &&
            i.severity == InsightSeverity.positive,
      ),
      isTrue,
    );
  });

  test('no data yields no insights', () {
    expect(
      generateInsights(month: june, income: const [], expense: const []),
      isEmpty,
    );
  });

  test('insights are ordered most-actionable first', () {
    final insights = generateInsights(
      month: june,
      income: [_i(1000, DateTime(2026, 6, 1))],
      expense: [
        _e(2000, DateTime(2026, 5, 1)), // prev month, drives a change insight
        _e(1200, DateTime(2026, 6, 2)), // overspend → negative
      ],
    );
    expect(insights.first.severity, InsightSeverity.negative);
  });
}
