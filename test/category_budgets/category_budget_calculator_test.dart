import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/category_budgets/services/category_budget_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CategoryBudgetCalculator', () {
    test('calculates same-currency category progress', () {
      final progress = const CategoryBudgetCalculator().calculate(
        budget: _budget(limitAmount: 3000),
        selectedMonth: '2026-05',
        expenses: [
          _expense(amount: 1000, categoryId: 'food'),
          _expense(amount: 1400, categoryId: 'food'),
          _expense(amount: 900, categoryId: 'transport'),
        ],
      );

      expect(progress.spent, 2400);
      expect(progress.remaining, 600);
      expect(progress.percentUsed, 0.8);
      expect(progress.status, CategoryBudgetProgressStatus.nearLimit);
    });

    test('marks exceeded budgets', () {
      final progress = const CategoryBudgetCalculator().calculate(
        budget: _budget(limitAmount: 1000),
        selectedMonth: '2026-05',
        expenses: [
          _expense(amount: 1200, categoryId: 'food'),
        ],
      );

      expect(progress.status, CategoryBudgetProgressStatus.exceeded);
      expect(progress.remaining, -200);
    });

    test('converts mixed-currency expenses for base-currency budgets', () {
      final progress = const CategoryBudgetCalculator().calculate(
        budget: _budget(limitAmount: 1000, currency: 'EGP'),
        selectedMonth: '2026-05',
        expenses: [
          _expense(amount: 500, categoryId: 'food', currency: 'EGP'),
          _expense(amount: 40, categoryId: 'food', currency: 'USD'),
        ],
        settings: UserSettings.defaults(userId: 'user-1').copyWith(
          baseCurrency: 'EGP',
          supportedCurrencies: const ['EGP', 'USD'],
          conversionRates: const {'USD': 50},
        ),
      );

      expect(progress.spent, 2500);
      expect(progress.ignoredCurrencyCount, 0);
      expect(progress.convertedCurrencies, ['USD']);
      expect(progress.unconvertedCurrencies, isEmpty);
      expect(progress.status, CategoryBudgetProgressStatus.exceeded);
    });

    test('excludes missing-rate expenses for base-currency budgets', () {
      final progress = const CategoryBudgetCalculator().calculate(
        budget: _budget(limitAmount: 1000, currency: 'EGP'),
        selectedMonth: '2026-05',
        expenses: [
          _expense(amount: 500, categoryId: 'food', currency: 'EGP'),
          _expense(amount: 40, categoryId: 'food', currency: 'USD'),
        ],
        settings: UserSettings.defaults(userId: 'user-1').copyWith(
          baseCurrency: 'EGP',
          supportedCurrencies: const ['EGP', 'USD'],
        ),
      );

      expect(progress.spent, 500);
      expect(progress.ignoredCurrencyCount, 1);
      expect(progress.convertedCurrencies, isEmpty);
      expect(progress.unconvertedCurrencies, ['USD']);
      expect(progress.hasMixedCurrencyWarning, isTrue);
    });

    test('ignores archived budgets for active progress', () {
      final progress = const CategoryBudgetCalculator().calculate(
        budget: _budget(limitAmount: 1000, isArchived: true),
        selectedMonth: '2026-05',
        expenses: [
          _expense(amount: 900, categoryId: 'food'),
        ],
      );

      expect(progress.spent, 0);
      expect(progress.status, CategoryBudgetProgressStatus.archived);
    });
  });
}

CategoryBudget _budget({
  double limitAmount = 1000,
  String currency = 'EGP',
  bool isArchived = false,
}) {
  return CategoryBudget(
    categoryBudgetId: '2026-05_food_$currency',
    userId: 'user-1',
    categoryId: 'food',
    categoryName: 'Food',
    month: '2026-05',
    currency: currency,
    limitAmount: limitAmount,
    warningThresholdPercent: 80,
    isArchived: isArchived,
    createdAt: DateTime(2026, 5),
    updatedAt: DateTime(2026, 5),
  );
}

Expense _expense({
  required int amount,
  required String categoryId,
  String currency = 'EGP',
}) {
  return Expense(
    expenseId: '$categoryId-$amount-$currency',
    category: Category(
      categoryId: categoryId,
      name: categoryId,
      totalExpenses: 0,
      icon: 'other',
      color: 0xff000000,
    ),
    categoryId: categoryId,
    categoryName: categoryId,
    date: DateTime(2026, 5, 12),
    amount: amount,
    currency: currency,
  );
}
