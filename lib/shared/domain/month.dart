import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

/// A calendar month (year + month), used for grouping transactions and, later,
/// budgets and reporting.
class Month extends Equatable implements Comparable<Month> {
  const Month(this.year, this.month)
    : assert(month >= 1 && month <= 12, 'month must be 1-12');

  final int year;
  final int month;

  factory Month.fromDate(DateTime date) => Month(date.year, date.month);

  factory Month.current() => Month.fromDate(DateTime.now());

  /// First day of this month (local).
  DateTime get start => DateTime(year, month);

  /// First day of the next month — exclusive upper bound for range queries.
  DateTime get endExclusive => DateTime(year, month + 1);

  Month get previous =>
      month == 1 ? Month(year - 1, 12) : Month(year, month - 1);

  Month get next => month == 12 ? Month(year + 1, 1) : Month(year, month + 1);

  bool contains(DateTime date) =>
      !date.isBefore(start) && date.isBefore(endExclusive);

  /// Whole months from this month to [other] (negative if [other] is earlier).
  int monthsUntil(Month other) =>
      (other.year - year) * 12 + (other.month - month);

  /// e.g. "June 2026".
  String get label => DateFormat.yMMMM().format(start);

  @override
  int compareTo(Month other) {
    final byYear = year.compareTo(other.year);
    return byYear != 0 ? byYear : month.compareTo(other.month);
  }

  @override
  List<Object?> get props => [year, month];

  @override
  String toString() => label;
}
