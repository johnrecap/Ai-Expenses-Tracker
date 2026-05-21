import 'package:expense_repository/expense_repository.dart';

class RepeatedExpenseSuggestion {
  const RepeatedExpenseSuggestion({
    required this.categoryName,
    required this.description,
    required this.averageAmount,
    required this.currency,
    required this.frequency,
    required this.sampleCount,
    required this.lastDate,
    required this.confidence,
  });

  final String categoryName;
  final String description;
  final double averageAmount;
  final String currency;
  final RecurringFrequency frequency;
  final int sampleCount;
  final DateTime lastDate;
  final double confidence;
}

class RepeatedExpenseDetector {
  const RepeatedExpenseDetector({
    this.amountTolerancePercent = 0.12,
    this.minimumSamples = 3,
  });

  final double amountTolerancePercent;
  final int minimumSamples;

  List<RepeatedExpenseSuggestion> detect(List<Expense> expenses) {
    final groups = <String, List<Expense>>{};
    for (final expense in expenses) {
      if (expense.amount <= 0) continue;
      final key = [
        expense.currency.toUpperCase(),
        expense.categoryId.isNotEmpty
            ? expense.categoryId
            : expense.categoryName,
        _normalizeDescription(expense.description),
      ].join('|');
      groups.putIfAbsent(key, () => []).add(expense);
    }

    final suggestions = <RepeatedExpenseSuggestion>[];
    for (final group in groups.values) {
      if (group.length < minimumSamples) continue;
      group.sort((a, b) => a.date.compareTo(b.date));
      if (!_hasStableAmounts(group)) continue;
      final frequency = _detectFrequency(group);
      if (frequency == null) continue;
      final average =
          group.fold<double>(0, (sum, expense) => sum + expense.amount) /
              group.length;
      final latest = group.last;
      suggestions.add(
        RepeatedExpenseSuggestion(
          categoryName: latest.categoryName,
          description: latest.description.trim().isEmpty
              ? latest.categoryName
              : latest.description.trim(),
          averageAmount: average,
          currency: latest.currency,
          frequency: frequency,
          sampleCount: group.length,
          lastDate: latest.date,
          confidence: _confidence(group.length),
        ),
      );
    }
    suggestions.sort((a, b) => b.confidence.compareTo(a.confidence));
    return suggestions;
  }

  bool _hasStableAmounts(List<Expense> expenses) {
    final average =
        expenses.fold<double>(0, (sum, expense) => sum + expense.amount) /
            expenses.length;
    if (average == 0) return false;
    return expenses.every(
      (expense) =>
          ((expense.amount - average).abs() / average) <=
          amountTolerancePercent,
    );
  }

  RecurringFrequency? _detectFrequency(List<Expense> expenses) {
    final gaps = <int>[];
    for (var i = 1; i < expenses.length; i++) {
      gaps.add(expenses[i].date.difference(expenses[i - 1].date).inDays.abs());
    }
    if (gaps.isEmpty) return null;
    final averageGap = gaps.reduce((a, b) => a + b) / gaps.length;
    final stable = gaps.every((gap) => (gap - averageGap).abs() <= 3);
    if (!stable) return null;
    if (averageGap >= 27 && averageGap <= 33) return RecurringFrequency.monthly;
    if (averageGap >= 6 && averageGap <= 8) return RecurringFrequency.weekly;
    if (averageGap >= 1 && averageGap <= 2) return RecurringFrequency.daily;
    return null;
  }

  double _confidence(int sampleCount) {
    return (0.55 + (sampleCount.clamp(0, 6) * 0.07)).clamp(0.0, 0.95);
  }

  String _normalizeDescription(String value) {
    final normalized = value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\u0600-\u06ff ]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (normalized.isEmpty) return 'no-description';
    return normalized;
  }
}
