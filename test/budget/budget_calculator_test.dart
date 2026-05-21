import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/services/budget_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

Expense _expense({
  required int amount,
  required DateTime date,
  String currency = 'EGP',
}) {
  return Expense(
    expenseId: 'expense-$amount-${date.millisecondsSinceEpoch}',
    category: Category.empty,
    date: date,
    amount: amount,
    currency: currency,
  );
}

void main() {
  test('returns empty progress when no budget exists', () {
    final progress = BudgetCalculator.calculate(
      budget: null,
      expenses: [
        _expense(amount: 500, date: DateTime(2026, 5, 10)),
      ],
    );

    expect(progress.spent, 0);
    expect(progress.remaining, 0);
    expect(progress.percentUsed, 0);
    expect(progress.status, BudgetProgressStatus.none);
  });

  test('calculates normal, near limit, exact limit, and exceeded states', () {
    final budget = Budget(
      budgetId: '2026-05',
      userId: 'user-1',
      month: 5,
      year: 2026,
      amount: 1000,
      currency: 'EGP',
      warningThresholdPercent: 80,
      createdAt: DateTime(2026, 5),
      updatedAt: DateTime(2026, 5),
    );

    expect(
      BudgetCalculator.calculate(
        budget: budget,
        expenses: [_expense(amount: 500, date: DateTime(2026, 5, 10))],
      ).status,
      BudgetProgressStatus.normal,
    );

    expect(
      BudgetCalculator.calculate(
        budget: budget,
        expenses: [_expense(amount: 850, date: DateTime(2026, 5, 10))],
      ).status,
      BudgetProgressStatus.nearLimit,
    );

    final exact = BudgetCalculator.calculate(
      budget: budget,
      expenses: [_expense(amount: 1000, date: DateTime(2026, 5, 10))],
    );
    expect(exact.status, BudgetProgressStatus.nearLimit);
    expect(exact.remaining, 0);

    final exceeded = BudgetCalculator.calculate(
      budget: budget,
      expenses: [_expense(amount: 1200, date: DateTime(2026, 5, 10))],
    );
    expect(exceeded.status, BudgetProgressStatus.exceeded);
    expect(exceeded.remaining, -200);
  });

  test('ignores wrong month and wrong currency expenses', () {
    final budget = Budget(
      budgetId: '2026-05',
      userId: 'user-1',
      month: 5,
      year: 2026,
      amount: 1000,
      currency: 'EGP',
      warningThresholdPercent: 80,
      createdAt: DateTime(2026, 5),
      updatedAt: DateTime(2026, 5),
    );

    final progress = BudgetCalculator.calculate(
      budget: budget,
      expenses: [
        _expense(amount: 300, date: DateTime(2026, 5, 10)),
        _expense(amount: 400, date: DateTime(2026, 4, 10)),
        _expense(amount: 500, date: DateTime(2026, 5, 11), currency: 'USD'),
      ],
    );

    expect(progress.spent, 300);
    expect(progress.ignoredCurrencyCount, 1);
  });

  test('converts supported budget currencies when settings are available', () {
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

    final progress = BudgetCalculator.calculate(
      budget: budget,
      settings: UserSettings.defaults(userId: 'user-1').copyWith(
        baseCurrency: 'EGP',
        supportedCurrencies: const ['EGP', 'USD'],
        conversionRates: const {'USD': 50},
      ),
      expenses: [
        _expense(amount: 100, date: DateTime(2026, 5, 10), currency: 'USD'),
      ],
    );

    expect(progress.spent, 5000);
    expect(progress.remaining, 5000);
    expect(progress.ignoredCurrencyCount, 0);
  });
}
