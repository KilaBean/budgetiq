// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(categoryRepository)
final categoryRepositoryProvider = CategoryRepositoryProvider._();

final class CategoryRepositoryProvider
    extends
        $FunctionalProvider<
          CategoryRepository,
          CategoryRepository,
          CategoryRepository
        >
    with $Provider<CategoryRepository> {
  CategoryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryRepositoryHash();

  @$internal
  @override
  $ProviderElement<CategoryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CategoryRepository create(Ref ref) {
    return categoryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CategoryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CategoryRepository>(value),
    );
  }
}

String _$categoryRepositoryHash() =>
    r'db7fa3c588b25ebb802732157ce375c1e0b20dbc';

/// Loads and manages the categories of a given [kind].

@ProviderFor(CategoryList)
final categoryListProvider = CategoryListFamily._();

/// Loads and manages the categories of a given [kind].
final class CategoryListProvider
    extends $AsyncNotifierProvider<CategoryList, List<Category>> {
  /// Loads and manages the categories of a given [kind].
  CategoryListProvider._({
    required CategoryListFamily super.from,
    required TransactionKind super.argument,
  }) : super(
         retry: null,
         name: r'categoryListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$categoryListHash();

  @override
  String toString() {
    return r'categoryListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CategoryList create() => CategoryList();

  @override
  bool operator ==(Object other) {
    return other is CategoryListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$categoryListHash() => r'59c025fbce1fc57c81270351a8d4fc0bc3779904';

/// Loads and manages the categories of a given [kind].

final class CategoryListFamily extends $Family
    with
        $ClassFamilyOverride<
          CategoryList,
          AsyncValue<List<Category>>,
          List<Category>,
          FutureOr<List<Category>>,
          TransactionKind
        > {
  CategoryListFamily._()
    : super(
        retry: null,
        name: r'categoryListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Loads and manages the categories of a given [kind].

  CategoryListProvider call(TransactionKind kind) =>
      CategoryListProvider._(argument: kind, from: this);

  @override
  String toString() => r'categoryListProvider';
}

/// Loads and manages the categories of a given [kind].

abstract class _$CategoryList extends $AsyncNotifier<List<Category>> {
  late final _$args = ref.$arg as TransactionKind;
  TransactionKind get kind => _$args;

  FutureOr<List<Category>> build(TransactionKind kind);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Category>>, List<Category>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Category>>, List<Category>>,
              AsyncValue<List<Category>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
