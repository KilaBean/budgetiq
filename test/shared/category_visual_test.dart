import 'package:budgetiq/shared/domain/money.dart';
import 'package:budgetiq/shared/utils/category_visual.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CategoryVisual', () {
    test('parses #RRGGBB and #AARRGGBB hex', () {
      expect(CategoryVisual.parseHex('#FF0000'), const Color(0xFFFF0000));
      expect(CategoryVisual.parseHex('00FF00'), const Color(0xFF00FF00));
      expect(CategoryVisual.parseHex('not-a-color'), isNull);
      expect(CategoryVisual.parseHex(null), isNull);
    });

    test('toHex round-trips a swatch', () {
      final hex = CategoryVisual.toHex(CategoryVisual.swatches.first);
      expect(CategoryVisual.parseHex(hex), CategoryVisual.swatches.first);
    });

    test('colorFor uses stored color, else a stable name-based fallback', () {
      expect(
        CategoryVisual.colorFor(colorHex: '#3B82F6', seed: 'x'),
        const Color(0xFF3B82F6),
      );
      final a = CategoryVisual.colorFor(colorHex: null, seed: 'Food');
      final b = CategoryVisual.colorFor(colorHex: null, seed: 'Food');
      expect(a, b); // deterministic
    });

    test('iconFor falls back for unknown names', () {
      expect(CategoryVisual.iconFor('restaurant'), Icons.restaurant);
      expect(CategoryVisual.iconFor('nope'), Icons.label_outline);
    });
  });

  group('Money.formatCompact', () {
    test('keeps small amounts precise, abbreviates large ones', () {
      expect(
        Money.fromMajor(1234.5).formatCompact(locale: 'en_US'),
        contains('1,234.50'),
      );
      final big = Money.fromMajor(2500000).formatCompact(locale: 'en_US');
      expect(big.contains('M'), isTrue);
    });
  });
}
