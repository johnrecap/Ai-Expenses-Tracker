import 'package:expense_repository/expense_repository.dart';

enum MonthlyStoryTrend { empty, increase, decrease, flat, newSpending }

class MonthlyFinancialStory {
  const MonthlyFinancialStory({
    required this.trend,
    required this.currentTotal,
    required this.previousTotal,
    required this.deltaPercent,
    required this.currency,
    required this.drivers,
    required this.outliers,
    required this.unconvertedCurrencies,
    required this.ignoredCurrencyCount,
  });

  final MonthlyStoryTrend trend;
  final double currentTotal;
  final double previousTotal;
  final double deltaPercent;
  final String currency;
  final List<MonthlyStoryDriver> drivers;
  final List<MonthlyStoryOutlier> outliers;
  final List<String> unconvertedCurrencies;
  final int ignoredCurrencyCount;

  bool get hasMissingRateCaveat =>
      ignoredCurrencyCount > 0 && unconvertedCurrencies.isNotEmpty;
}

class MonthlyStoryDriver {
  const MonthlyStoryDriver({
    required this.category,
    required this.amount,
    required this.sharePercent,
  });

  final CategoryReportTotal category;
  final double amount;
  final double sharePercent;
}

class MonthlyStoryOutlier {
  const MonthlyStoryOutlier({
    required this.expense,
    required this.convertedAmount,
    required this.sharePercent,
  });

  final Expense expense;
  final double convertedAmount;
  final double sharePercent;
}
