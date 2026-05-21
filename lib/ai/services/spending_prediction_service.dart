import 'package:expense_repository/expense_repository.dart';

import '../models/models.dart';

class SpendingPredictionService {
  const SpendingPredictionService();

  AiPredictionPayload predictMonth({
    required List<Expense> expenses,
    required DateTime now,
    required String currency,
  }) {
    final normalizedCurrency = currency.trim().toUpperCase();
    final historical = expenses
        .where((expense) =>
            expense.currency.toUpperCase() == normalizedCurrency &&
            expense.date.isBefore(DateTime(now.year, now.month)))
        .toList();
    if (historical.isEmpty) {
      return AiPredictionPayload(
        period: 'month',
        expectedTotal: 0,
        currency: normalizedCurrency,
        categoryDrivers: const [],
        qualityNote:
            'Guidance only: not enough same-currency history for a prediction.',
        generatedAt: now,
      );
    }

    final monthTotals = <String, double>{};
    final categoryTotals = <String, _CategoryPredictionBucket>{};
    for (final expense in historical) {
      final monthKey = '${expense.date.year}-${expense.date.month}';
      monthTotals[monthKey] = (monthTotals[monthKey] ?? 0) + expense.amount;
      final categoryName = expense.categoryName.isNotEmpty
          ? expense.categoryName
          : expense.category.name;
      final bucket = categoryTotals.putIfAbsent(
        categoryName,
        () => _CategoryPredictionBucket(),
      );
      bucket.total += expense.amount;
      bucket.count++;
    }

    final expectedTotal =
        monthTotals.values.fold<double>(0, (sum, value) => sum + value) /
            monthTotals.length;
    final monthCount = monthTotals.length;
    final drivers = categoryTotals.entries
        .map(
          (entry) => AiPredictionCategoryDriver(
            category: entry.key,
            expectedAmount: entry.value.total / monthCount,
            historyCount: entry.value.count,
          ),
        )
        .toList()
      ..sort((a, b) => b.expectedAmount.compareTo(a.expectedAmount));

    return AiPredictionPayload(
      period: 'month',
      expectedTotal: expectedTotal,
      currency: normalizedCurrency,
      categoryDrivers: drivers.take(5).toList(),
      qualityNote:
          'Guidance based on ${monthTotals.length} historical month(s), not a financial guarantee.',
      generatedAt: now,
    );
  }
}

class _CategoryPredictionBucket {
  double total = 0;
  int count = 0;
}
