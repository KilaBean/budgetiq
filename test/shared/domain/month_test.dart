import 'package:budgetiq/shared/domain/month.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('start and endExclusive bound the month', () {
    const june = Month(2026, 6);
    expect(june.start, DateTime(2026, 6, 1));
    expect(june.endExclusive, DateTime(2026, 7, 1));
  });

  test('previous and next wrap across year boundaries', () {
    expect(const Month(2026, 1).previous, const Month(2025, 12));
    expect(const Month(2026, 12).next, const Month(2027, 1));
  });

  test('contains checks date within range', () {
    const june = Month(2026, 6);
    expect(june.contains(DateTime(2026, 6, 15)), isTrue);
    expect(june.contains(DateTime(2026, 7, 1)), isFalse);
    expect(june.contains(DateTime(2026, 5, 31)), isFalse);
  });

  test('ordering compares year then month', () {
    expect(const Month(2026, 1).compareTo(const Month(2026, 2)), lessThan(0));
    expect(
      const Month(2027, 1).compareTo(const Month(2026, 12)),
      greaterThan(0),
    );
  });
}
