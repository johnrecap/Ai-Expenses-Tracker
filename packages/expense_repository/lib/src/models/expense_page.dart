import 'expense.dart';

const int defaultExpensePageSize = 30;

class ExpensePageCursor {
  final DateTime date;
  final String expenseId;

  const ExpensePageCursor({
    required this.date,
    required this.expenseId,
  });

  factory ExpensePageCursor.fromExpense(Expense expense) {
    return ExpensePageCursor(
      date: expense.date,
      expenseId: expense.expenseId,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ExpensePageCursor &&
            other.date == date &&
            other.expenseId == expenseId;
  }

  @override
  int get hashCode => Object.hash(date, expenseId);
}

class ExpensePage {
  final List<Expense> expenses;
  final ExpensePageCursor? nextCursor;
  final bool hasMore;

  const ExpensePage({
    required this.expenses,
    required this.nextCursor,
    required this.hasMore,
  });

  factory ExpensePage.fromOrderedExpenses(
    List<Expense> orderedExpenses, {
    required int limit,
  }) {
    final safeLimit = limit <= 0 ? defaultExpensePageSize : limit;
    final hasMore = orderedExpenses.length > safeLimit;
    final visibleExpenses = List<Expense>.unmodifiable(
      hasMore ? orderedExpenses.take(safeLimit) : orderedExpenses,
    );
    return ExpensePage(
      expenses: visibleExpenses,
      nextCursor: visibleExpenses.isEmpty
          ? null
          : ExpensePageCursor.fromExpense(visibleExpenses.last),
      hasMore: hasMore,
    );
  }
}
