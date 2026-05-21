import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/engagement/engagement.dart';
import 'package:expenses_tracker/services/budget_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

Expense _expense({
  required String id,
  required String categoryId,
  required String categoryName,
  required int amount,
  required DateTime date,
}) {
  final category = Category(
    categoryId: categoryId,
    name: categoryName,
    totalExpenses: 0,
    icon: 'food',
    color: categoryName.hashCode,
  );
  return Expense(
    expenseId: id,
    category: category,
    categoryId: categoryId,
    categoryName: categoryName,
    categoryIcon: category.icon,
    categoryColor: category.color,
    date: date,
    amount: amount,
    currency: 'EGP',
  );
}

Budget _budget() {
  return Budget(
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
}

void main() {
  const service = SpendingHealthScoreService();
  final streak = TrackingStreak(
    currentStreakDays: 3,
    hasTrackedToday: true,
    referenceDate: DateTime(2026, 5, 17),
  );

  test('under budget with tracking produces positive state', () {
    final expenses = [
      _expense(
        id: '1',
        categoryId: 'food',
        categoryName: 'Food',
        amount: 300,
        date: DateTime(2026, 5, 17),
      ),
    ];
    final score = service.calculate(
      expenses: expenses,
      budgetProgress: BudgetCalculator.calculate(
        budget: _budget(),
        expenses: expenses,
      ),
      streak: streak,
      currency: 'EGP',
      now: DateTime(2026, 5, 17),
    );

    expect(score.status, SpendingHealthStatus.good);
    expect(score.reasons, contains('Monthly budget is on track.'));
  });

  test('near budget returns watch status', () {
    final expenses = [
      _expense(
        id: '1',
        categoryId: 'food',
        categoryName: 'Food',
        amount: 850,
        date: DateTime(2026, 5, 17),
      ),
    ];
    final score = service.calculate(
      expenses: expenses,
      budgetProgress: BudgetCalculator.calculate(
        budget: _budget(),
        expenses: expenses,
      ),
      streak: streak,
      currency: 'EGP',
      now: DateTime(2026, 5, 17),
    );

    expect(score.status, SpendingHealthStatus.watch);
    expect(score.reasons, contains('Monthly budget is near its limit.'));
  });

  test('over budget returns risk status', () {
    final expenses = [
      _expense(
        id: '1',
        categoryId: 'food',
        categoryName: 'Food',
        amount: 1200,
        date: DateTime(2026, 5, 17),
      ),
    ];
    final score = service.calculate(
      expenses: expenses,
      budgetProgress: BudgetCalculator.calculate(
        budget: _budget(),
        expenses: expenses,
      ),
      streak: streak,
      currency: 'EGP',
      now: DateTime(2026, 5, 17),
    );

    expect(score.status, SpendingHealthStatus.risk);
    expect(score.reasons, contains('Monthly budget is exceeded.'));
  });

  test('high category concentration adds reason', () {
    final expenses = [
      _expense(
        id: '1',
        categoryId: 'food',
        categoryName: 'Food',
        amount: 700,
        date: DateTime(2026, 5, 17),
      ),
      _expense(
        id: '2',
        categoryId: 'bills',
        categoryName: 'Bills',
        amount: 100,
        date: DateTime(2026, 5, 17),
      ),
    ];
    final score = service.calculate(
      expenses: expenses,
      budgetProgress: BudgetCalculator.calculate(
        budget: _budget(),
        expenses: expenses,
      ),
      streak: streak,
      currency: 'EGP',
      now: DateTime(2026, 5, 17),
    );

    expect(
      score.reasons,
      contains('One category is over 60% of this month\'s spending.'),
    );
  });
}
