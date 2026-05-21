import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/services/finance/finance.dart';
import 'package:intl/intl.dart';

class ReportCalculator {
  const ReportCalculator._();

  static ExpenseReport calculate({
    required List<Expense> expenses,
    required ReportRange range,
    required UserSettings settings,
    FinancialCalculationService calculationService =
        const FinancialCalculationService(),
  }) {
    final currentBreakdown = calculationService.calculateExpenses(
      expenses: expenses,
      settings: settings,
      where: (expense) => _within(expense.date, range.startDate, range.endDate),
    );
    final currentExpenses = currentBreakdown.convertedRows;

    final previousRange = _previousRange(range);
    final previousBreakdown = calculationService.calculateExpenses(
      expenses: expenses,
      settings: settings,
      where: (expense) => _within(
        expense.date,
        previousRange.startDate,
        previousRange.endDate,
      ),
    );
    final previousTotal = previousBreakdown.total;
    final total = currentBreakdown.total;
    final deltaPercent = previousTotal == 0
        ? total == 0
            ? 0.0
            : 100.0
        : ((total - previousTotal) / previousTotal) * 100;

    final categoryTotals = _categoryTotals(currentExpenses);
    return ExpenseReport(
      range: range,
      currency: currentBreakdown.baseCurrency,
      total: total,
      buckets: _buckets(currentExpenses, range),
      categoryTotals: categoryTotals,
      topCategory: categoryTotals.isEmpty ? null : categoryTotals.first,
      previousTotal: previousTotal,
      deltaPercent: deltaPercent,
      ignoredCurrencyCount: currentBreakdown.ignoredCurrencyCount,
      convertedCurrencies: currentBreakdown.convertedCurrencies,
      unconvertedCurrencies: currentBreakdown.unconvertedCurrencies,
    );
  }

  static bool _within(DateTime date, DateTime start, DateTime end) {
    return !date.isBefore(start) && !date.isAfter(end);
  }

  static ReportRange _previousRange(ReportRange range) {
    switch (range.type) {
      case ReportRangeType.weekly:
        return ReportRange.custom(
          startDate: range.startDate.subtract(const Duration(days: 7)),
          endDate: range.endDate.subtract(const Duration(days: 7)),
        );
      case ReportRangeType.monthly:
        final previousMonth =
            DateTime(range.startDate.year, range.startDate.month - 1);
        return ReportRange.monthly(anchorDate: previousMonth);
      case ReportRangeType.custom:
        final days = range.endDate.difference(range.startDate).inDays + 1;
        return ReportRange.custom(
          startDate: range.startDate.subtract(Duration(days: days)),
          endDate: range.endDate.subtract(Duration(days: days)),
        );
    }
  }

  static List<ReportBucket> _buckets(
    List<ConvertedMoneyRow> expenses,
    ReportRange range,
  ) {
    switch (range.type) {
      case ReportRangeType.weekly:
      case ReportRangeType.custom:
        return List.generate(7, (index) {
          final start = DateTime(
            range.startDate.year,
            range.startDate.month,
            range.startDate.day + index,
          );
          final end =
              DateTime(start.year, start.month, start.day, 23, 59, 59, 999);
          return ReportBucket(
            label: DateFormat('E').format(start),
            startDate: start,
            endDate: end,
            total: _sumInRange(expenses, start, end),
          );
        });
      case ReportRangeType.monthly:
        final buckets = <ReportBucket>[];
        var start = DateTime(range.startDate.year, range.startDate.month);
        while (!start.isAfter(range.endDate)) {
          final end = DateTime(
            start.year,
            start.month,
            start.day + 6,
            23,
            59,
            59,
            999,
          ).isAfter(range.endDate)
              ? range.endDate
              : DateTime(
                  start.year, start.month, start.day + 6, 23, 59, 59, 999);
          buckets.add(
            ReportBucket(
              label: '${start.day}/${start.month}',
              startDate: start,
              endDate: end,
              total: _sumInRange(expenses, start, end),
            ),
          );
          start = DateTime(start.year, start.month, start.day + 7);
        }
        return buckets;
    }
  }

  static double _sumInRange(
    List<ConvertedMoneyRow> expenses,
    DateTime start,
    DateTime end,
  ) {
    return expenses
        .where((expense) => _within(expense.expense.date, start, end))
        .fold<double>(0, (sum, expense) => sum + expense.convertedAmount);
  }

  static List<CategoryReportTotal> _categoryTotals(
    List<ConvertedMoneyRow> expenses,
  ) {
    final totals = <String, CategoryReportTotal>{};
    for (final convertedExpense in expenses) {
      final expense = convertedExpense.expense;
      final id = expense.categoryId.isNotEmpty
          ? expense.categoryId
          : expense.categoryName;
      final name = expense.categoryName.isNotEmpty
          ? expense.categoryName
          : expense.category.name;
      final current = totals[id];
      totals[id] = CategoryReportTotal(
        categoryId: id,
        categoryName: name,
        categoryIcon: expense.categoryIcon.isNotEmpty
            ? expense.categoryIcon
            : expense.category.icon,
        categoryColor: expense.categoryColor != 0
            ? expense.categoryColor
            : expense.category.color,
        total: (current?.total ?? 0) + convertedExpense.convertedAmount,
      );
    }
    final values = totals.values.toList()
      ..sort((a, b) {
        final totalCompare = b.total.compareTo(a.total);
        if (totalCompare != 0) return totalCompare;
        return a.categoryName
            .toLowerCase()
            .compareTo(b.categoryName.toLowerCase());
    });
    return values;
  }
}
