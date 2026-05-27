import 'package:expense_repository/expense_repository.dart';

class LocalRecurringExpenseRepository implements RecurringExpenseRepository {
  final LocalRepositoryStore store;

  const LocalRecurringExpenseRepository({required this.store});

  @override
  Future<void> archiveRecurringExpense(String recurringExpenseId) async {
    final current = store.recurringExpenses[recurringExpenseId];
    if (current == null) return;
    await updateRecurringExpense(
      current.copyWith(
          isArchived: true, isActive: false, updatedAt: DateTime.now()),
    );
  }

  @override
  Future<void> createRecurringExpense(RecurringExpense recurringExpense) async {
    await _save(recurringExpense);
  }

  @override
  Future<List<RecurringExpense>> getDueRecurringExpenses(DateTime now) async {
    return store
        .orderedRecurringExpenses()
        .where(
          (rule) =>
              rule.isActive &&
              !rule.isArchived &&
              !rule.nextRunDate.isAfter(now) &&
              (rule.endDate == null || !rule.endDate!.isBefore(now)),
        )
        .toList(growable: false);
  }

  @override
  Future<void> updateRecurringExpense(RecurringExpense recurringExpense) async {
    await _save(recurringExpense);
  }

  @override
  Stream<List<RecurringExpense>> watchRecurringExpenses({
    bool includeArchived = false,
  }) {
    return store.watchRecurringExpenses().map(
          (_) => store.orderedRecurringExpenses(
            includeArchived: includeArchived,
          ),
        );
  }

  Future<void> _save(RecurringExpense recurringExpense) async {
    final normalized = recurringExpense.copyWith(
      userId: recurringExpense.userId.isEmpty
          ? store.userId
          : recurringExpense.userId,
      updatedAt: DateTime.now(),
    );
    store.recurringExpenses[normalized.recurringExpenseId] = normalized;
    store.enqueue(
      store.change(
        entityType: SyncEntityType.recurringExpense,
        entityId: normalized.recurringExpenseId,
        operation: SyncOperation.upsert,
        data: normalized.toEntity().toDocument(),
      ),
    );
    store.emitRecurringExpenses();
  }
}
