import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/home/models/home_summary.dart';
import 'package:expenses_tracker/services/finance/finance.dart';

class HomeSummaryCalculator {
  const HomeSummaryCalculator({
    FinancialCalculationService calculationService =
        const FinancialCalculationService(),
  }) : _calculationService = calculationService;

  final FinancialCalculationService _calculationService;

  HomeSummary calculate({
    required List<Expense> expenses,
    required UserSettings settings,
    required AppUser user,
    String? localDisplayName,
    Budget? budget,
    required DateTime now,
  }) {
    final periodStart = DateTime(now.year, now.month);
    final periodEnd = DateTime(now.year, now.month + 1);
    final monthlyExpenses = expenses.where(
      (expense) =>
          !expense.date.isBefore(periodStart) &&
          expense.date.isBefore(periodEnd),
    );
    final breakdown = _calculationService.calculateExpenses(
      expenses: monthlyExpenses,
      settings: settings,
    );
    final currency = breakdown.baseCurrency;
    final spendingTotal = breakdown.total;
    final budgetInBaseCurrency =
        budget?.currency.trim().toUpperCase() == currency ? budget : null;
    final budgetAmount = budgetInBaseCurrency?.amount;
    final budgetRemaining =
        budgetAmount == null ? null : budgetAmount - spendingTotal;

    return HomeSummary(
      displayName: _displayName(user, localDisplayName: localDisplayName),
      periodStart: periodStart,
      periodEnd: periodEnd,
      spendingTotal: spendingTotal,
      currency: currency,
      hasMixedCurrencies: breakdown.hasMixedCurrencies,
      convertedCurrencies: breakdown.convertedCurrencies,
      unconvertedCurrencies: breakdown.unconvertedCurrencies,
      budgetAmount: budgetAmount,
      budgetRemaining: budgetRemaining,
      budgetStatus: _budgetStatus(
        budget: budgetInBaseCurrency,
        spendingTotal: spendingTotal,
      ),
      ignoredCurrencyCount: breakdown.ignoredCurrencyCount,
      topCategoryName: _topCategoryName(breakdown.convertedRows),
      pendingSyncCount: monthlyExpenses
          .where((expense) => expense.syncStatus.isPending)
          .length,
    );
  }

  HomeBudgetStatus _budgetStatus({
    required Budget? budget,
    required double spendingTotal,
  }) {
    if (budget == null || budget.amount <= 0) return HomeBudgetStatus.none;
    if (spendingTotal > budget.amount) return HomeBudgetStatus.exceeded;
    final percent = spendingTotal / budget.amount;
    if (percent >= budget.warningThresholdPercent / 100) {
      return HomeBudgetStatus.nearLimit;
    }
    return HomeBudgetStatus.normal;
  }

  String? _topCategoryName(List<ConvertedMoneyRow> expenses) {
    if (expenses.isEmpty) return null;
    final totals = <String, double>{};
    for (final convertedExpense in expenses) {
      final expense = convertedExpense.expense;
      final name = expense.categoryName.trim().isNotEmpty
          ? expense.categoryName.trim()
          : expense.category.name.trim();
      if (name.isEmpty) continue;
      totals[name] = (totals[name] ?? 0) + convertedExpense.convertedAmount;
    }
    if (totals.isEmpty) return null;
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.first.key;
  }

  String _displayName(AppUser user, {String? localDisplayName}) {
    final localName = localDisplayName?.trim();
    if (localName != null && localName.isNotEmpty) return localName;
    final displayName = user.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;
    final email = user.email?.trim();
    if (email != null && email.isNotEmpty) return email;
    return 'User';
  }
}
