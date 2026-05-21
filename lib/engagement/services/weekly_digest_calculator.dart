import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/engagement/models/weekly_digest.dart';
import 'package:expenses_tracker/services/report_calculator.dart';

class WeeklyDigestCalculator {
  const WeeklyDigestCalculator();

  WeeklyDigest calculate({
    required List<Expense> expenses,
    required UserSettings settings,
    DateTime? now,
  }) {
    final report = ReportCalculator.calculate(
      expenses: expenses,
      range: ReportRange.weekly(anchorDate: now ?? DateTime.now()),
      settings: settings,
    );

    return WeeklyDigest(
      report: report,
      insight: _insight(report),
    );
  }

  String _insight(ExpenseReport report) {
    if (report.total == 0 && report.previousTotal == 0) {
      return 'Start by logging one expense this week.';
    }

    final topCategory = report.topCategory;
    if (topCategory != null && report.total > 0) {
      final share = topCategory.total / report.total;
      if (share >= 0.5) {
        return '${topCategory.categoryName} is your largest category this week.';
      }
    }

    if (report.previousTotal == 0 && report.total > 0) {
      return 'This is your first tracked week in this comparison.';
    }

    if (report.deltaPercent > 0) {
      return 'Spending is higher than last week.';
    }

    if (report.deltaPercent < 0) {
      return 'Spending is lower than last week.';
    }

    return 'Spending is unchanged from last week.';
  }
}
