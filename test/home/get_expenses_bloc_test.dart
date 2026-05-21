import 'dart:async';

import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/home/blocs/get_expenses_bloc/get_expenses_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('falls back to one-shot expenses when watch stream fails', () async {
    final expenses = [
      Expense(
        expenseId: 'older',
        category: Category.empty,
        date: DateTime(2026, 5, 17),
        amount: 10,
      ),
      Expense(
        expenseId: 'newer',
        category: Category.empty,
        date: DateTime(2026, 5, 18),
        amount: 20,
      ),
    ];
    final bloc = GetExpensesBloc(_WatchFailsExpenseRepository(expenses));

    final expectation = expectLater(
      bloc.stream,
      emitsInOrder([
        isA<GetExpensesLoading>(),
        isA<GetExpensesSuccess>().having(
          (state) => state.expenses.map((expense) => expense.expenseId),
          'expense ids',
          ['newer', 'older'],
        ),
      ]),
    );

    bloc.add(const GetExpenses(limit: 5));

    await expectation;
    await bloc.close();
  });
}

class _WatchFailsExpenseRepository implements ExpenseRepository {
  _WatchFailsExpenseRepository(this.expenses);

  final List<Expense> expenses;

  @override
  Future<void> createExpense(Expense expense) async {}

  @override
  Future<void> deleteExpense(String expenseId) async {}

  @override
  Future<Expense?> getExpenseById(String expenseId) async => null;

  @override
  Future<ExpensePage> getExpensePage({
    int limit = defaultExpensePageSize,
    ExpensePageCursor? startAfter,
    ExpenseFilter filter = ExpenseFilter.empty,
  }) async {
    return ExpensePage.fromOrderedExpenses(expenses, limit: limit);
  }

  @override
  Future<List<Expense>> getExpenses() async => expenses;

  @override
  Future<List<Expense>> getExpensesByFilter(ExpenseFilter filter) async {
    return expenses;
  }

  @override
  Future<void> updateExpense(Expense expense) async {}

  @override
  Stream<List<Expense>> watchExpenses() => Stream.value(expenses);

  @override
  Stream<ExpensePage> watchRecentExpensePage({
    int limit = defaultExpensePageSize,
  }) {
    return Stream<ExpensePage>.error(Exception('missing index'));
  }
}
