import 'package:expense_repository/expense_repository.dart';

class LocalExpenseRepository implements ExpenseRepository {
  final LocalRepositoryStore store;

  const LocalExpenseRepository({
    required this.store,
  });

  @override
  Future<void> createExpense(Expense expense) async {
    final now = DateTime.now();
    expense.userId = store.userId;
    expense.updatedAt = now;
    final change = _change(expense, SyncOperation.upsert);
    store.expenses[expense.expenseId] = expense.withSyncStatus(
      SyncStatus.pending,
      reason: change.reason,
    );
    store.enqueue(change);
    store.emitExpenses();
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    store.expenses.remove(expenseId);
    store.enqueue(
      SyncChange(
        id: 'expense-$expenseId-${DateTime.now().microsecondsSinceEpoch}',
        userId: store.userId,
        entityType: SyncEntityType.expense,
        entityId: expenseId,
        operation: SyncOperation.delete,
        data: const {},
        clientUpdatedAt: DateTime.now(),
      ),
    );
    store.emitExpenses();
  }

  @override
  Future<Expense?> getExpenseById(String expenseId) async {
    return store.expenses[expenseId];
  }

  @override
  Future<ExpensePage> getExpensePage({
    int limit = defaultExpensePageSize,
    ExpensePageCursor? startAfter,
    ExpenseFilter filter = ExpenseFilter.empty,
  }) async {
    final filtered = _filter(store.orderedExpenses(), filter);
    final startIndex = startAfter == null
        ? 0
        : filtered.indexWhere(
              (expense) =>
                  expense.date == startAfter.date &&
                  expense.expenseId == startAfter.expenseId,
            ) +
            1;
    return ExpensePage.fromOrderedExpenses(
      startIndex <= 0
          ? filtered
          : filtered.skip(startIndex).toList(growable: false),
      limit: limit,
    );
  }

  @override
  Future<List<Expense>> getExpenses() async => store.orderedExpenses();

  @override
  Future<List<Expense>> getExpensesByFilter(ExpenseFilter filter) async {
    return _filter(store.orderedExpenses(), filter);
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    final now = DateTime.now();
    expense.userId = store.userId;
    expense.updatedAt = now;
    final change = _change(expense, SyncOperation.upsert);
    store.expenses[expense.expenseId] = expense.withSyncStatus(
      SyncStatus.pending,
      reason: change.reason,
    );
    store.enqueue(change);
    store.emitExpenses();
  }

  @override
  Stream<List<Expense>> watchExpenses() => store.watchExpenses();

  @override
  Stream<ExpensePage> watchRecentExpensePage({
    int limit = defaultExpensePageSize,
  }) {
    return store.watchExpenses().map(
          (expenses) => ExpensePage.fromOrderedExpenses(
            expenses,
            limit: limit,
          ),
        );
  }

  List<Expense> _filter(List<Expense> expenses, ExpenseFilter filter) {
    final query = filter.query.trim().toLowerCase();
    return expenses.where((expense) {
      final matchesQuery = query.isEmpty ||
          expense.description.toLowerCase().contains(query) ||
          expense.categoryName.toLowerCase().contains(query) ||
          expense.paymentMethod.label.toLowerCase().contains(query);
      final matchesCategory = filter.categoryIds.isEmpty ||
          filter.categoryIds.contains(expense.categoryId);
      final matchesMin =
          filter.minAmount == null || expense.amount >= filter.minAmount!;
      final matchesMax =
          filter.maxAmount == null || expense.amount <= filter.maxAmount!;
      final matchesPayment = filter.paymentMethods.isEmpty ||
          filter.paymentMethods.contains(expense.paymentMethod);
      final matchesCurrency = filter.currency == null ||
          filter.currency!.trim().isEmpty ||
          expense.currency.toUpperCase() ==
              filter.currency!.trim().toUpperCase();
      final matchesWallet = filter.walletAccountId == null ||
          filter.walletAccountId!.trim().isEmpty ||
          expense.walletAccountId == filter.walletAccountId!.trim();
      final afterStart =
          filter.startDate == null || !expense.date.isBefore(filter.startDate!);
      final beforeEnd =
          filter.endDate == null || !expense.date.isAfter(filter.endDate!);

      return matchesQuery &&
          matchesCategory &&
          matchesMin &&
          matchesMax &&
          matchesPayment &&
          matchesCurrency &&
          matchesWallet &&
          afterStart &&
          beforeEnd;
    }).toList(growable: false);
  }

  SyncChange _change(Expense expense, SyncOperation operation) {
    return SyncChange(
      id: 'expense-${expense.expenseId}-${DateTime.now().microsecondsSinceEpoch}',
      userId: store.userId,
      entityType: SyncEntityType.expense,
      entityId: expense.expenseId,
      operation: operation,
      data: expense.toEntity().toDocument(),
      clientUpdatedAt: DateTime.now(),
    );
  }
}
