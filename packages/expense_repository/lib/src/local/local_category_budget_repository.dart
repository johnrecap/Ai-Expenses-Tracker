import 'package:expense_repository/expense_repository.dart';

class LocalCategoryBudgetRepository implements CategoryBudgetRepository {
  final LocalRepositoryStore store;

  const LocalCategoryBudgetRepository({required this.store});

  @override
  Future<void> archiveCategoryBudget(String categoryBudgetId) async {
    final current = store.categoryBudgets[categoryBudgetId];
    if (current == null) return;
    final archived =
        current.copyWith(isArchived: true, updatedAt: DateTime.now());
    store.categoryBudgets[categoryBudgetId] = archived;
    store.enqueue(
      store.change(
        entityType: SyncEntityType.categoryBudget,
        entityId: categoryBudgetId,
        operation: SyncOperation.upsert,
        data: archived.toEntity().toDocument(),
      ),
    );
    store.emitCategoryBudgets();
  }

  @override
  Future<List<CategoryBudget>> getCategoryBudgetsForMonth({
    required String month,
    bool includeArchived = false,
  }) async {
    return store
        .orderedCategoryBudgets(includeArchived: includeArchived)
        .where((budget) => budget.month == month)
        .toList(growable: false);
  }

  @override
  Future<void> saveCategoryBudget(CategoryBudget categoryBudget) async {
    final id = categoryBudget.categoryBudgetId.isEmpty
        ? CategoryBudget.categoryBudgetIdFor(
            month: categoryBudget.month,
            categoryId: categoryBudget.categoryId,
            currency: categoryBudget.currency,
          )
        : categoryBudget.categoryBudgetId;
    final normalized = categoryBudget.copyWith(
      categoryBudgetId: id,
      userId:
          categoryBudget.userId.isEmpty ? store.userId : categoryBudget.userId,
      updatedAt: DateTime.now(),
    );
    store.categoryBudgets[id] = normalized;
    store.enqueue(
      store.change(
        entityType: SyncEntityType.categoryBudget,
        entityId: id,
        operation: SyncOperation.upsert,
        data: normalized.toEntity().toDocument(),
      ),
    );
    store.emitCategoryBudgets();
  }

  @override
  Stream<List<CategoryBudget>> watchCategoryBudgetsForMonth({
    required String month,
    bool includeArchived = false,
  }) {
    return store.watchCategoryBudgets().map(
          (_) => store
              .orderedCategoryBudgets(includeArchived: includeArchived)
              .where((budget) => budget.month == month)
              .toList(growable: false),
        );
  }
}
