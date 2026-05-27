import 'package:expense_repository/expense_repository.dart';

class MigrationComparisonResult<T> {
  final T legacyValue;
  final T migratedValue;
  final bool matches;

  const MigrationComparisonResult({
    required this.legacyValue,
    required this.migratedValue,
    required this.matches,
  });
}

class MigrationComparisonExpenseRepository implements ExpenseRepository {
  final ExpenseRepository legacy;
  final ExpenseRepository migrated;
  final void Function(String message) onMismatch;

  const MigrationComparisonExpenseRepository({
    required this.legacy,
    required this.migrated,
    this.onMismatch = _ignoreMismatch,
  });

  @override
  Future<void> createExpense(Expense expense) =>
      migrated.createExpense(expense);

  @override
  Future<void> deleteExpense(String expenseId) =>
      migrated.deleteExpense(expenseId);

  @override
  Future<Expense?> getExpenseById(String expenseId) async {
    final legacyValue = await legacy.getExpenseById(expenseId);
    final migratedValue = await migrated.getExpenseById(expenseId);
    if (legacyValue?.expenseId != migratedValue?.expenseId) {
      onMismatch('Expense $expenseId differs between legacy and VPS stores.');
    }
    return migratedValue;
  }

  @override
  Future<ExpensePage> getExpensePage({
    int limit = defaultExpensePageSize,
    ExpensePageCursor? startAfter,
    ExpenseFilter filter = ExpenseFilter.empty,
  }) {
    return migrated.getExpensePage(
      limit: limit,
      startAfter: startAfter,
      filter: filter,
    );
  }

  @override
  Future<List<Expense>> getExpenses() async {
    final legacyValue = await legacy.getExpenses();
    final migratedValue = await migrated.getExpenses();
    if (legacyValue.length != migratedValue.length) {
      onMismatch(
        'Expense count differs: legacy=${legacyValue.length}, migrated=${migratedValue.length}.',
      );
    }
    return migratedValue;
  }

  @override
  Future<List<Expense>> getExpensesByFilter(ExpenseFilter filter) {
    return migrated.getExpensesByFilter(filter);
  }

  @override
  Future<void> updateExpense(Expense expense) =>
      migrated.updateExpense(expense);

  @override
  Stream<List<Expense>> watchExpenses() => migrated.watchExpenses();

  @override
  Stream<ExpensePage> watchRecentExpensePage({int limit = 20}) {
    return migrated.watchRecentExpensePage(limit: limit);
  }
}

void _ignoreMismatch(String message) {}
