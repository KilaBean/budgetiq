import 'package:equatable/equatable.dart';

import '../../../../shared/domain/transaction_kind.dart';

/// A user-owned income or expense category.
class Category extends Equatable {
  const Category({
    required this.id,
    required this.kind,
    required this.name,
    this.icon,
    this.color,
    this.isSystem = false,
  });

  final String id;
  final TransactionKind kind;
  final String name;
  final String? icon;
  final String? color;

  /// Seeded default category. Editable, but the UI may treat it differently.
  final bool isSystem;

  Category copyWith({String? name, String? icon, String? color}) => Category(
    id: id,
    kind: kind,
    name: name ?? this.name,
    icon: icon ?? this.icon,
    color: color ?? this.color,
    isSystem: isSystem,
  );

  @override
  List<Object?> get props => [id, kind, name, icon, color, isSystem];
}
