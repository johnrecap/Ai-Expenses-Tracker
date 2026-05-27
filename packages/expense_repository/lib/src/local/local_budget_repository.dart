import 'package:expense_repository/expense_repository.dart';

class LocalBudgetRepository implements BudgetRepository {
  final LocalRepositoryStore store;

  const LocalBudgetRepository({required this.store});

  @override
  Future<Budget?> getCurrentMonthBudget({
    required int month,
    required int year,
  }) async {
    final budgetId = Budget.budgetIdFor(month: month, year: year);
    return store.budgets[budgetId];
  }

  @override
  Future<void> saveBudget(Budget budget) async {
    final normalized = budget.copyWith(
      userId: budget.userId.isEmpty ? store.userId : budget.userId,
      budgetId: budget.budgetId.isEmpty
          ? Budget.budgetIdFor(month: budget.month, year: budget.year)
          : budget.budgetId,
      updatedAt: DateTime.now(),
    );
    store.budgets[normalized.budgetId] = normalized;
    store.enqueue(
      store.change(
        entityType: SyncEntityType.budget,
        entityId: normalized.budgetId,
        operation: SyncOperation.upsert,
        data: normalized.toEntity().toDocument(),
      ),
    );
    store.emitBudgets();
  }

  @override
  Stream<Budget?> watchCurrentMonthBudget({
    required int month,
    required int year,
  }) {
    final budgetId = Budget.budgetIdFor(month: month, year: year);
    return store.watchBudgets().map((budgets) => store.budgets[budgetId]);
  }
}
