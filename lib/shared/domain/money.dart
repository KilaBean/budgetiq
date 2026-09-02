import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

/// Immutable monetary amount stored in minor units (e.g. cents) to avoid
/// floating-point rounding errors in financial calculations.
///
/// BudgetIQ is single-currency per user (Phase 0 decision), but the currency
/// code travels with the value so formatting and future multi-currency support
/// remain correct.
class Money extends Equatable implements Comparable<Money> {
  const Money({required this.minorUnits, required this.currencyCode});

  /// Amount in the currency's smallest unit (cents for USD/EUR, etc.).
  final int minorUnits;

  final String currencyCode;

  static const int _minorPerMajor = 100;

  factory Money.zero([String currencyCode = 'USD']) =>
      Money(minorUnits: 0, currencyCode: currencyCode);

  /// Builds from a major-unit value (e.g. `12.34` dollars), rounding to the
  /// nearest minor unit.
  factory Money.fromMajor(num major, {String currencyCode = 'USD'}) => Money(
    minorUnits: (major * _minorPerMajor).round(),
    currencyCode: currencyCode,
  );

  /// Parses a value as returned by Postgres `numeric` (may be `num` or
  /// `String` depending on the driver).
  factory Money.fromDatabase(Object value, {String currencyCode = 'USD'}) {
    final major = switch (value) {
      final num n => n,
      final String s => num.parse(s),
      _ => throw FormatException('Unsupported money value: $value'),
    };
    return Money.fromMajor(major, currencyCode: currencyCode);
  }

  /// Major-unit representation suitable for sending to the `numeric` column.
  double get major => minorUnits / _minorPerMajor;

  bool get isZero => minorUnits == 0;
  bool get isPositive => minorUnits > 0;

  // BudgetIQ is single-currency per user, so arithmetic operates on the minor
  // units and keeps the left operand's currency rather than asserting equality.
  // This keeps aggregations safe even if older rows carry a different stored
  // currency code than the user's current one.
  Money operator +(Money other) => Money(
    minorUnits: minorUnits + other.minorUnits,
    currencyCode: currencyCode,
  );

  Money operator -(Money other) => Money(
    minorUnits: minorUnits - other.minorUnits,
    currencyCode: currencyCode,
  );

  /// Formats using the active locale and the value's currency, e.g. `$1,234.50`.
  String format({String? locale}) {
    final format = NumberFormat.simpleCurrency(
      locale: locale,
      name: currencyCode,
    );
    return format.format(major);
  }

  /// Compact, abbreviated form for tight spaces, e.g. `$1.2K`, `₵3.4M`. Falls
  /// back to the full [format] below 10,000 so small amounts stay precise.
  String formatCompact({String? locale}) {
    if (minorUnits.abs() < 1000000) return format(locale: locale);
    return NumberFormat.compactSimpleCurrency(
      locale: locale,
      name: currencyCode,
    ).format(major);
  }

  @override
  int compareTo(Money other) => minorUnits.compareTo(other.minorUnits);

  @override
  List<Object?> get props => [minorUnits, currencyCode];

  @override
  String toString() => format();
}
