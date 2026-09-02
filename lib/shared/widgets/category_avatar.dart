import 'package:flutter/material.dart';

import '../../features/categories/domain/entities/category.dart';
import '../utils/category_visual.dart';

/// Circular tinted chip showing a category's icon in its color. Works from raw
/// fields (transactions) or a full [Category] (manager/budgets).
class CategoryAvatar extends StatelessWidget {
  const CategoryAvatar({
    super.key,
    required this.iconName,
    required this.seed,
    this.colorHex,
    this.size = 40,
  });

  factory CategoryAvatar.fromCategory(Category category, {double size = 40}) =>
      CategoryAvatar(
        iconName: category.icon,
        colorHex: category.color,
        seed: category.name,
        size: size,
      );

  final String? iconName;
  final String? colorHex;
  final String seed;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = CategoryVisual.colorFor(colorHex: colorHex, seed: seed);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        shape: BoxShape.circle,
      ),
      child: Icon(
        CategoryVisual.iconFor(iconName),
        color: color,
        size: size * 0.5,
      ),
    );
  }
}
