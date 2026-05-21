import 'package:expense_repository/expense_repository.dart';

abstract class ExpenseRepository {
  Future<void> createExpense(Expense expense);
  Future<void> updateExpense(Expense expense);
  Future<void> deleteExpense(String expenseId);
  Future<Expense?> getExpenseById(String expenseId);
  Future<List<Expense>> getExpenses();
  Stream<List<Expense>> watchExpenses();
  Future<ExpensePage> getExpensePage({
    int limit = defaultExpensePageSize,
    ExpensePageCursor? startAfter,
    ExpenseFilter filter = ExpenseFilter.empty,
  });
  Stream<ExpensePage> watchRecentExpensePage({
    int limit = defaultExpensePageSize,
  });
  Future<List<Expense>> getExpensesByFilter(ExpenseFilter filter);
}
