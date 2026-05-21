import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/engagement/models/spending_health_score.dart';
import 'package:expenses_tracker/engagement/models/tracking_streak.dart';
import 'package:expenses_tracker/services/budget_calculator.dart';

class SpendingHealthScoreService {
  const SpendingHealthScoreService();

  SpendingHealthScore calculate({
    required List<Expense> expenses,
    required BudgetProgress budgetProgress,
    required TrackingStreak streak,
    required String currency,
    DateTime? now,
  }) {
    final normalizedCurrency = currency.trim().toUpperCase();
    final currentMonthExpenses = _currentMonthExpenses(
      expenses: expenses,
      budget: budgetProgress.budget,
      currency: normalizedCurrency,
      now: now ?? DateTime.now(),
    );

    if (budgetProgress.status == BudgetProgressStatus.none &&
        currentMonthExpenses.isEmpty &&
        streak.isEmpty) {
      return const SpendingHealthScore(
        score: 0,
        status: SpendingHealthStatus.insufficientData,
        label: 'Add a few expenses',
        reasons: ['Log expenses or set a monthly budget to see a score.'],
      );
    }

    var score = 70;
    final reasons = <String>[];

    switch (budgetProgress.status) {
      case BudgetProgressStatus.exceeded:
        score -= 35;
        reasons.add('Monthly budget is exceeded.');
        break;
      case BudgetProgressStatus.nearLimit:
        score -= 18;
        reasons.add('Monthly budget is near its limit.');
        break;
      case BudgetProgressStatus.normal:
        score += 12;
        reasons.add('Monthly budget is on track.');
        break;
      case BudgetProgressStatus.none:
        score -= 8;
        reasons.add('No monthly budget is set.');
        break;
    }

    final concentration = _largestCategoryShare(currentMonthExpenses);
    if (concentration >= 0.6 && currentMonthExpenses.length >= 2) {
      score -= 12;
      reasons.add('One category is over 60% of this month\'s spending.');
    } else if (currentMonthExpenses.length >= 2) {
      score += 6;
      reasons.add('Spending is spread across categories.');
    }

    if (streak.hasTrackedToday) {
      score += 8;
      reasons.add('Today has at least one logged expense.');
    } else if (streak.currentStreakDays > 0) {
      score += 2;
      reasons.add('Recent tracking activity is active.');
    } else {
      score -= 8;
      reasons.add('No recent tracking streak yet.');
    }

    final clampedScore = score.clamp(0, 100).toInt();
    final status = _statusForScore(clampedScore);

    return SpendingHealthScore(
      score: clampedScore,
      status: status,
      label: _labelForStatus(status),
      reasons: reasons.take(3).toList(),
    );
  }

  List<Expense> _currentMonthExpenses({
    required List<Expense> expenses,
    required Budget? budget,
    required String currency,
    required DateTime now,
  }) {
    final month = budget?.month ?? now.month;
    final year = budget?.year ?? now.year;
    return expenses
        .where((expense) =>
            expense.date.month == month &&
            expense.date.year == year &&
            expense.currency.toUpperCase() == currency)
        .toList();
  }

  double _largestCategoryShare(List<Expense> expenses) {
    final total = expenses.fold<double>(
      0,
      (sum, expense) => sum + expense.amount,
    );
    if (total <= 0) return 0;

    final categoryTotals = <String, double>{};
    for (final expense in expenses) {
      final key = expense.categoryId.isNotEmpty
          ? expense.categoryId
          : expense.categoryName;
      categoryTotals[key] = (categoryTotals[key] ?? 0) + expense.amount;
    }
    final largest = categoryTotals.values.fold<double>(
      0,
      (max, total) => total > max ? total : max,
    );
    return largest / total;
  }

  SpendingHealthStatus _statusForScore(int score) {
    if (score >= 80) return SpendingHealthStatus.good;
    if (score >= 55) return SpendingHealthStatus.watch;
    return SpendingHealthStatus.risk;
  }

  String _labelForStatus(SpendingHealthStatus status) {
    switch (status) {
      case SpendingHealthStatus.good:
        return 'On track';
      case SpendingHealthStatus.watch:
        return 'Worth watching';
      case SpendingHealthStatus.risk:
        return 'Needs review';
      case SpendingHealthStatus.insufficientData:
        return 'Add a few expenses';
    }
  }
}
