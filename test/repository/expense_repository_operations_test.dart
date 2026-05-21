import 'package:expense_repository/expense_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeExpenseRepository implements ExpenseRepository {
  final Map<String, Expense> expenses = {};

  @override
  Future<void> createExpense(Expense expense) async {
    expenses[expense.expenseId] = expense;
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    expenses[expense.expenseId] = expense;
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    expenses.remove(expenseId);
  }

  @override
  Future<Expense?> getExpenseById(String expenseId) async {
    return expenses[expenseId];
  }

  @override
  Future<List<Expense>> getExpenses() async => expenses.values.toList();

  @override
  Future<ExpensePage> getExpensePage({
    int limit = defaultExpensePageSize,
    ExpensePageCursor? startAfter,
    ExpenseFilter filter = ExpenseFilter.empty,
  }) async {
    final ordered = expenses.values.toList()
      ..sort((a, b) {
        final dateCompare = b.date.compareTo(a.date);
        if (dateCompare != 0) return dateCompare;
        return b.expenseId.compareTo(a.expenseId);
      });
    final startIndex = startAfter == null
        ? 0
        : ordered.indexWhere(
              (expense) =>
                  expense.date == startAfter.date &&
                  expense.expenseId == startAfter.expenseId,
            ) +
            1;
    return ExpensePage.fromOrderedExpenses(
      startIndex <= 0 ? ordered : ordered.skip(startIndex).toList(),
      limit: limit,
    );
  }

  @override
  Stream<List<Expense>> watchExpenses() async* {
    yield expenses.values.toList();
  }

  @override
  Stream<ExpensePage> watchRecentExpensePage({
    int limit = defaultExpensePageSize,
  }) async* {
    yield await getExpensePage(limit: limit);
  }

  @override
  Future<List<Expense>> getExpensesByFilter(ExpenseFilter filter) async {
    return expenses.values
        .where((expense) =>
            filter.paymentMethods.isEmpty ||
            filter.paymentMethods.contains(expense.paymentMethod))
        .toList();
  }
}

void main() {
  test('repository contract supports create update get and delete', () async {
    final repository = FakeExpenseRepository();
    final expense = Expense(
      expenseId: 'expense-1',
      category: Category.empty,
      date: DateTime(2026, 5, 15),
      amount: 100,
      paymentMethod: PaymentMethod.cash,
    );

    await repository.createExpense(expense);
    expect(await repository.getExpenseById('expense-1'), isNotNull);

    expense.amount = 125;
    expense.paymentMethod = PaymentMethod.visa;
    await repository.updateExpense(expense);

    final updated = await repository.getExpenseById('expense-1');
    expect(updated?.amount, 125);
    expect(updated?.paymentMethod, PaymentMethod.visa);

    await repository.deleteExpense('expense-1');
    expect(await repository.getExpenseById('expense-1'), isNull);
  });

  test('created expenses persist payment method and currency fields', () async {
    final repository = FakeExpenseRepository();
    final expense = Expense(
      expenseId: 'expense-2',
      category: Category.empty,
      date: DateTime(2026, 5, 15),
      amount: 250,
      paymentMethod: PaymentMethod.wallet,
      currency: 'USD',
    );

    await repository.createExpense(expense);

    final saved = await repository.getExpenseById('expense-2');
    expect(saved?.paymentMethod, PaymentMethod.wallet);
    expect(saved?.currency, 'USD');
  });

  test('expense pages are bounded and newest first', () async {
    final repository = FakeExpenseRepository()
      ..expenses['older'] = Expense(
        expenseId: 'older',
        category: Category.empty,
        date: DateTime(2026, 5, 14),
        amount: 100,
      )
      ..expenses['newest-b'] = Expense(
        expenseId: 'newest-b',
        category: Category.empty,
        date: DateTime(2026, 5, 16),
        amount: 100,
      )
      ..expenses['newest-a'] = Expense(
        expenseId: 'newest-a',
        category: Category.empty,
        date: DateTime(2026, 5, 16),
        amount: 100,
      );

    final page = await repository.getExpensePage(limit: 2);

    expect(page.expenses.map((expense) => expense.expenseId), [
      'newest-b',
      'newest-a',
    ]);
    expect(page.hasMore, isTrue);
    expect(page.nextCursor, ExpensePageCursor.fromExpense(page.expenses.last));
  });

  test('second expense page continues after cursor without duplicate ids',
      () async {
    final repository = FakeExpenseRepository();
    for (var i = 0; i < 5; i++) {
      repository.expenses['expense-$i'] = Expense(
        expenseId: 'expense-$i',
        category: Category.empty,
        date: DateTime(2026, 5, 10 + i),
        amount: 100,
      );
    }

    final firstPage = await repository.getExpensePage(limit: 2);
    final secondPage = await repository.getExpensePage(
      limit: 2,
      startAfter: firstPage.nextCursor,
    );

    expect(firstPage.expenses, hasLength(2));
    expect(secondPage.expenses, hasLength(2));
    expect(
      firstPage.expenses
          .map((expense) => expense.expenseId)
          .toSet()
          .intersection(
            secondPage.expenses.map((expense) => expense.expenseId).toSet(),
          ),
      isEmpty,
    );
  });
}
