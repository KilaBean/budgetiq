import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/cache/cache_box.dart';
import '../../../../core/network/connectivity_provider.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../shared/domain/transaction_kind.dart';
import '../../../sync/presentation/providers/sync_providers.dart';
import '../../data/datasources/category_local_data_source.dart';
import '../../data/datasources/category_remote_data_source.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';

part 'category_providers.g.dart';

@Riverpod(keepAlive: true)
CategoryRepository categoryRepository(Ref ref) {
  return CategoryRepositoryImpl(
    remote: CategoryRemoteDataSource(ref.watch(supabaseClientProvider)),
    local: CategoryLocalDataSource(ref.watch(jsonListCacheProvider)),
    queue: ref.watch(syncQueueProvider),
    isOnline: () => ref.read(isOnlineProvider),
    currentUserId: () => ref.read(supabaseClientProvider).auth.currentUser?.id,
    onEnqueued: () =>
        ref.read(syncControllerProvider.notifier).notifyEnqueued(),
  );
}

/// Loads and manages the categories of a given [kind].
@riverpod
class CategoryList extends _$CategoryList {
  @override
  Future<List<Category>> build(TransactionKind kind) {
    return ref.watch(categoryRepositoryProvider).getCategories(kind);
  }

  Future<void> create({
    required String name,
    String? icon,
    String? color,
  }) async {
    await ref
        .read(categoryRepositoryProvider)
        .createCategory(kind: kind, name: name, icon: icon, color: color);
    ref.invalidateSelf();
    await future;
  }

  Future<void> edit(Category category) async {
    await ref.read(categoryRepositoryProvider).updateCategory(category);
    ref.invalidateSelf();
    await future;
  }

  Future<void> delete(Category category) async {
    await ref.read(categoryRepositoryProvider).deleteCategory(category);
    ref.invalidateSelf();
    await future;
  }
}
