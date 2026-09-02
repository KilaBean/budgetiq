import 'package:flutter/material.dart';

import '../../features/categories/domain/entities/category.dart';

/// Maps a category's stored icon name + color string to concrete [IconData] /
/// [Color], with sensible deterministic fallbacks. Centralizes the picker
/// options too so the form and rendering stay in sync.
class CategoryVisual {
  const CategoryVisual._();

  /// Curated icon set (const so icons are tree-shaken). Keys are stored on the
  /// category row.
  static const Map<String, IconData> icons = {
    'payments': Icons.payments,
    'work': Icons.work,
    'trending_up': Icons.trending_up,
    'card_giftcard': Icons.card_giftcard,
    'savings': Icons.savings,
    'restaurant': Icons.restaurant,
    'local_cafe': Icons.local_cafe,
    'shopping_bag': Icons.shopping_bag,
    'directions_car': Icons.directions_car,
    'home': Icons.home,
    'bolt': Icons.bolt,
    'phone_iphone': Icons.phone_iphone,
    'favorite': Icons.favorite,
    'medical_services': Icons.medical_services,
    'movie': Icons.movie,
    'sports_esports': Icons.sports_esports,
    'fitness_center': Icons.fitness_center,
    'school': Icons.school,
    'flight': Icons.flight,
    'pets': Icons.pets,
    'child_care': Icons.child_care,
    'more_horiz': Icons.more_horiz,
  };

  static List<String> get iconNames => icons.keys.toList();

  static IconData iconFor(String? name) => icons[name] ?? Icons.label_outline;

  /// Swatches offered in the color picker.
  static const List<Color> swatches = [
    Color(0xFF1FB58F),
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF10B981),
    Color(0xFF6366F1),
    Color(0xFF14B8A6),
    Color(0xFFF97316),
    Color(0xFF64748B),
    Color(0xFF84CC16),
  ];

  static String toHex(Color c) =>
      '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

  static Color? parseHex(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    var h = hex.replaceFirst('#', '');
    if (h.length == 6) h = 'FF$h';
    final value = int.tryParse(h, radix: 16);
    return value == null ? null : Color(value);
  }

  /// Display color: stored color if valid, else a stable color derived from
  /// [seed] (usually the category name) so every category looks distinct.
  static Color colorFor({String? colorHex, required String seed}) {
    return parseHex(colorHex) ??
        swatches[seed.hashCode.abs() % swatches.length];
  }

  static Color colorForCategory(Category c) =>
      colorFor(colorHex: c.color, seed: c.name);
}
