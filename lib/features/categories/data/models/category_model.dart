import '../../../../shared/domain/transaction_kind.dart';
import '../../domain/entities/category.dart';

/// Maps category rows between Supabase/JSON and the [Category] entity.
class CategoryModel {
  const CategoryModel._();

  static Category fromJson(Map<String, dynamic> json, TransactionKind kind) {
    return Category(
      id: json['id'] as String,
      kind: kind,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      isSystem: (json['is_system'] as bool?) ?? false,
    );
  }

  /// Fields the client is allowed to write (server owns id/timestamps).
  static Map<String, dynamic> toInsert(Category category, String userId) {
    return {
      'user_id': userId,
      'name': category.name,
      'icon': category.icon,
      'color': category.color,
      'is_system': category.isSystem,
    };
  }

  static Map<String, dynamic> toUpdate(Category category) {
    return {
      'name': category.name,
      'icon': category.icon,
      'color': category.color,
    };
  }
}
