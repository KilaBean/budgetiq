import '../../../../shared/domain/transaction_kind.dart';
import '../entities/category.dart';

/// Contract for reading and managing categories. Implementations throw a
/// [Failure](../../../../core/error/failure.dart) on error.
abstract interface class CategoryRepository {
  /// Active (non-deleted) categories of [kind], newest server state first
  /// falling back to cache when offline.
  Future<List<Category>> getCategories(TransactionKind kind);

  Future<Category> createCategory({
    required TransactionKind kind,
    required String name,
    String? icon,
    String? color,
  });

  Future<Category> updateCategory(Category category);

  /// Soft-deletes a category. Existing transactions keep their history.
  Future<void> deleteCategory(Category category);
}
