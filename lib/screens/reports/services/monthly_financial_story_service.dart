import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/reports/models/monthly_financial_story.dart';
import 'package:expenses_tracker/services/finance/finance.dart';

class MonthlyFinancialStoryService {
  const MonthlyFinancialStoryService({
    FinancialCalculationService calculationService =
        const FinancialCalculationService(),
  }) : _calculationService = calculationService;

  final FinancialCalculationService _calculationService;

  MonthlyFinancialStory build({
    required ExpenseReport report,
    required List<Expense> expenses,
    required UserSettings settings,
  }) {
    final currentRows = _calculationService
        .calculateExpenses(
          expenses: expenses,
          settings: settings,
          where: (expense) => _within(
            expense.date,
            report.range.startDate,
            report.range.endDate,
          ),
        )
        .convertedRows;

    final drivers = report.categoryTotals
        .where((category) => category.total > 0)
        .take(3)
        .map(
          (category) => MonthlyStoryDriver(
            category: category,
            amount: category.total,
            sharePercent: _percent(category.total, report.total),
          ),
        )
        .toList(growable: false);

    final outliers = currentRows.where((row) {
      if (report.total <= 0) return false;
      final share = row.convertedAmount / report.total;
      return share >= 0.25 || row.convertedAmount >= report.total * 0.2;
    }).toList()..sort((a, b) => b.convertedAmount.compareTo(a.convertedAmount));

    return MonthlyFinancialStory(
      trend: _trend(report),
      currentTotal: report.total,
      previousTotal: report.previousTotal,
      deltaPercent: report.deltaPercent,
      currency: report.currency,
      drivers: drivers,
      outliers: outliers
          .take(3)
          .map(
            (row) => MonthlyStoryOutlier(
              expense: row.expense,
              convertedAmount: row.convertedAmount,
              sharePercent: _percent(row.convertedAmount, report.total),
            ),
          )
          .toList(growable: false),
      unconvertedCurrencies: report.unconvertedCurrencies,
      ignoredCurrencyCount: report.ignoredCurrencyCount,
    );
  }

  MonthlyStoryTrend _trend(ExpenseReport report) {
    if (report.total == 0 && report.previousTotal == 0) {
      return MonthlyStoryTrend.empty;
    }
    if (report.previousTotal == 0 && report.total > 0) {
      return MonthlyStoryTrend.newSpending;
    }
    if (report.deltaPercent >= 10) return MonthlyStoryTrend.increase;
    if (report.deltaPercent <= -10) return MonthlyStoryTrend.decrease;
    return MonthlyStoryTrend.flat;
  }

  bool _within(DateTime date, DateTime start, DateTime end) {
    return !date.isBefore(start) && !date.isAfter(end);
  }

  double _percent(double value, double total) {
    if (total <= 0) return 0;
    return (value / total) * 100;
  }
}
