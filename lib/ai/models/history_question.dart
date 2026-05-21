import 'package:expense_repository/expense_repository.dart';

enum HistoryQuestionIntent {
  search,
  total,
  comparison,
  categoryDriver,
  unsupportedMutation,
  unknown,
}

enum HistoryNavigationTarget {
  none,
  expenses,
  reports,
}

class HistoryComparisonDriver {
  const HistoryComparisonDriver({
    required this.categoryName,
    required this.currentTotal,
    required this.previousTotal,
    required this.difference,
  });

  final String categoryName;
  final double currentTotal;
  final double previousTotal;
  final double difference;
}

class HistoryAnswer {
  const HistoryAnswer({
    required this.intent,
    required this.message,
    required this.confidence,
    this.filter,
    this.report,
    this.matchingExpenses = const [],
    this.navigationTarget = HistoryNavigationTarget.none,
    this.driver,
    this.source = 'local',
  });

  final HistoryQuestionIntent intent;
  final String message;
  final double confidence;
  final ExpenseFilter? filter;
  final ExpenseReport? report;
  final List<Expense> matchingExpenses;
  final HistoryNavigationTarget navigationTarget;
  final HistoryComparisonDriver? driver;
  final String source;

  bool get isKnown => intent != HistoryQuestionIntent.unknown;
  bool get isMutationRefusal =>
      intent == HistoryQuestionIntent.unsupportedMutation;
}
