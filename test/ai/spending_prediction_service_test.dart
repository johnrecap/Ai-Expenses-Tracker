import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/ai/services/services.dart';
import 'package:flutter_test/flutter_test.dart';

Expense _expense({
  required String id,
  required String categoryId,
  required String categoryName,
  required int amount,
  required DateTime date,
  String currency = 'EGP',
}) {
  final category = Category(
    categoryId: categoryId,
    name: categoryName,
    totalExpenses: 0,
    icon: 'icon',
    color: 0,
  );
  return Expense(
    expenseId: id,
    category: category,
    categoryId: categoryId,
    categoryName: categoryName,
    date: date,
    amount: amount,
    currency: currency,
  );
}

void main() {
  test('averages historical monthly totals', () {
    final prediction = const SpendingPredictionService().predictMonth(
      expenses: [
        _expense(
          id: '1',
          categoryId: 'food',
          categoryName: 'Food',
          amount: 1000,
          date: DateTime(2026, 3, 10),
        ),
        _expense(
          id: '2',
          categoryId: 'bills',
          categoryName: 'Bills',
          amount: 2000,
          date: DateTime(2026, 3, 20),
        ),
        _expense(
          id: '3',
          categoryId: 'food',
          categoryName: 'Food',
          amount: 1500,
          date: DateTime(2026, 4, 10),
        ),
      ],
      now: DateTime(2026, 5, 16),
      currency: 'EGP',
    );

    expect(prediction.expectedTotal, 2250);
    expect(prediction.categoryDrivers.first.category, 'Food');
  });

  test('returns guidance note for empty history', () {
    final prediction = const SpendingPredictionService().predictMonth(
      expenses: const [],
      now: DateTime(2026, 5, 16),
      currency: 'EGP',
    );

    expect(prediction.expectedTotal, 0);
    expect(prediction.categoryDrivers, isEmpty);
    expect(prediction.qualityNote, contains('not enough'));
  });

  test('ignores expenses in other currencies', () {
    final prediction = const SpendingPredictionService().predictMonth(
      expenses: [
        _expense(
          id: '1',
          categoryId: 'food',
          categoryName: 'Food',
          amount: 1000,
          date: DateTime(2026, 4, 10),
          currency: 'USD',
        ),
      ],
      now: DateTime(2026, 5, 16),
      currency: 'EGP',
    );

    expect(prediction.expectedTotal, 0);
  });
}
