import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/home/services/home_summary_calculator.dart';
import 'package:expenses_tracker/services/budget_calculator.dart';
import 'package:expenses_tracker/services/report_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('migrated local data gives matching Home Report and Budget totals',
      () async {
    final store = LocalRepositoryStore(
      userId: 'user-1',
      settings: UserSettings.defaults(userId: 'user-1').copyWith(
        baseCurrency: 'EGP',
        supportedCurrencies: const ['EGP', 'USD'],
        conversionRates: const {'USD': 50},
      ),
    );
    final expenses = LocalExpenseRepository(store: store);
    final budgets = LocalBudgetRepository(store: store);
    final budget = Budget(
      budgetId: '2026-05',
      userId: 'user-1',
      month: 5,
      year: 2026,
      amount: 10000,
      currency: 'EGP',
      warningThresholdPercent: 80,
      createdAt: DateTime(2026, 5),
      updatedAt: DateTime(2026, 5),
    );

    await expenses.createExpense(_expense('egp-1', 100, 'EGP'));
    await expenses.createExpense(_expense('usd-1', 50, 'USD'));
    await budgets.saveBudget(budget);

    final loadedExpenses = await expenses.getExpenses();
    final loadedBudget =
        await budgets.getCurrentMonthBudget(month: 5, year: 2026);
    final report = ReportCalculator.calculate(
      expenses: loadedExpenses,
      range: ReportRange.monthly(anchorDate: DateTime(2026, 5, 20)),
      settings: store.settings,
    );
    final summary = const HomeSummaryCalculator().calculate(
      expenses: loadedExpenses,
      settings: store.settings,
      user: AppUser(
        userId: 'user-1',
        email: null,
        displayName: null,
        photoUrl: null,
        createdAt: DateTime(2026, 5),
      ),
      budget: loadedBudget,
      now: DateTime(2026, 5, 20),
    );
    final progress = BudgetCalculator.calculate(
      budget: loadedBudget,
      expenses: loadedExpenses,
      settings: store.settings,
    );

    expect(report.total, 2600);
    expect(summary.spendingTotal, report.total);
    expect(progress.spent, report.total);
    expect(report.convertedCurrencies, ['USD']);
    expect(report.ignoredCurrencyCount, 0);
  });
}

Expense _expense(String id, num amount, String currency) {
  final category = Category(
    categoryId: 'food',
    name: 'Food',
    totalExpenses: 0,
    icon: 'restaurant',
    color: 0,
  );
  return Expense(
    expenseId: id,
    userId: 'user-1',
    category: category,
    categoryId: category.categoryId,
    categoryName: category.name,
    date: DateTime(2026, 5, 20),
    amount: amount,
    currency: currency,
  );
}
