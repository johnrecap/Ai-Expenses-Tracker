import 'package:expense_repository/expense_repository.dart';

class WeeklyDigest {
  final ExpenseReport report;
  final String insight;

  const WeeklyDigest({
    required this.report,
    required this.insight,
  });

  double get currentTotal => report.total;

  double get previousTotal => report.previousTotal;

  double get deltaPercent => report.deltaPercent;

  CategoryReportTotal? get topCategory => report.topCategory;

  int get ignoredCurrencyCount => report.ignoredCurrencyCount;

  List<String> get convertedCurrencies => report.convertedCurrencies;

  List<String> get unconvertedCurrencies => report.unconvertedCurrencies;

  bool get isEmpty => currentTotal == 0 && previousTotal == 0;
}
