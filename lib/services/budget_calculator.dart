import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/services/finance/finance.dart';

enum BudgetProgressStatus {
  none,
  normal,
  nearLimit,
  exceeded,
}

class BudgetProgress {
  final Budget? budget;
  final double spent;
  final double remaining;
  final double percentUsed;
  final int ignoredCurrencyCount;
  final BudgetProgressStatus status;

  const BudgetProgress({
    required this.budget,
    required this.spent,
    required this.remaining,
    required this.percentUsed,
    required this.ignoredCurrencyCount,
    required this.status,
  });

  static const empty = BudgetProgress(
    budget: null,
    spent: 0,
    remaining: 0,
    percentUsed: 0,
    ignoredCurrencyCount: 0,
    status: BudgetProgressStatus.none,
  );
}

class BudgetCalculator {
  const BudgetCalculator._();

  static BudgetProgress calculate({
    required Budget? budget,
    required List<Expense> expenses,
    UserSettings? settings,
    FinancialCalculationService calculationService =
        const FinancialCalculationService(),
  }) {
    if (budget == null || budget.amount <= 0) {
      return BudgetProgress.empty;
    }

    final budgetCurrency = budget.currency.trim().toUpperCase();
    bool budgetMonth(Expense expense) =>
        expense.date.month == budget.month && expense.date.year == budget.year;
    final canConvertToBudgetCurrency =
        settings != null &&
        settings.baseCurrency.trim().toUpperCase() == budgetCurrency;
    final breakdown = canConvertToBudgetCurrency
        ? calculationService.calculateExpenses(
            expenses: expenses,
            settings: settings,
            where: budgetMonth,
          )
        : null;
    final spent = breakdown?.total ??
        expenses.where(budgetMonth).fold<double>(0, (sum, expense) {
          if (expense.currency.trim().toUpperCase() != budgetCurrency) {
            return sum;
          }
          return sum + expense.amount;
        });
    final ignoredCurrencyCount = breakdown?.ignoredCurrencyCount ??
        expenses.where(budgetMonth).where((expense) {
          return expense.currency.trim().toUpperCase() != budgetCurrency;
        }).length;

    final remaining = budget.amount - spent;
    final percentUsed = budget.amount == 0 ? 0.0 : spent / budget.amount;
    final threshold = budget.warningThresholdPercent / 100;
    final status = spent > budget.amount
        ? BudgetProgressStatus.exceeded
        : percentUsed >= threshold
            ? BudgetProgressStatus.nearLimit
            : BudgetProgressStatus.normal;

    return BudgetProgress(
      budget: budget,
      spent: spent,
      remaining: remaining,
      percentUsed: percentUsed,
      ignoredCurrencyCount: ignoredCurrencyCount,
      status: status,
    );
  }
}
