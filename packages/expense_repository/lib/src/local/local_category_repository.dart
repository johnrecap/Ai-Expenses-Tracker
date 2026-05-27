import 'package:expense_repository/expense_repository.dart';

class LocalCategoryRepository implements CategoryRepository {
  final LocalRepositoryStore store;

  const LocalCategoryRepository({
    required this.store,
  });

  @override
  Future<void> archiveCategory(Category category) async {
    await updateCategory(
      category.copyWith(
        userId: store.userId,
        isArchived: true,
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> createCategory(Category category) async {
    final normalized = category.copyWith(
      userId: store.userId,
      updatedAt: DateTime.now(),
    );
    store.categories[normalized.categoryId] = normalized;
    store.enqueue(_change(normalized));
    store.emitCategories();
  }

  @override
  Future<List<Category>> getCategories({bool includeArchived = false}) async {
    return store.orderedCategories(includeArchived: includeArchived);
  }

  @override
  Future<void> updateCategory(Category category) async {
    final normalized = category.copyWith(
      userId: store.userId,
      updatedAt: DateTime.now(),
    );
    store.categories[normalized.categoryId] = normalized;
    store.enqueue(_change(normalized));
    store.emitCategories();
  }

  @override
  Stream<List<Category>> watchCategories({bool includeArchived = false}) {
    return store.watchCategories().map(
          (categories) => includeArchived
              ? categories
              : categories
                  .where((category) => !category.isArchived)
                  .toList(growable: false),
        );
  }

  SyncChange _change(Category category) {
    return SyncChange(
      id: 'category-${category.categoryId}-${DateTime.now().microsecondsSinceEpoch}',
      userId: store.userId,
      entityType: SyncEntityType.category,
      entityId: category.categoryId,
      operation:
          category.isArchived ? SyncOperation.delete : SyncOperation.upsert,
      data: category.toEntity().toDocument(),
      clientUpdatedAt: DateTime.now(),
    );
  }
}
