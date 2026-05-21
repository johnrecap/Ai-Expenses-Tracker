import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/ai/services/services.dart';
import 'package:flutter_test/flutter_test.dart';

Expense _expense({
  required String id,
  required String categoryId,
  required String categoryName,
  required int amount,
  required DateTime date,
  required String description,
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
    description: description,
  );
}

void main() {
  test('detects repeated monthly subscriptions', () {
    final suggestions = const RepeatedExpenseDetector().detect([
      _expense(
        id: '1',
        categoryId: 'bills',
        categoryName: 'Bills',
        amount: 300,
        date: DateTime(2026, 1, 1),
        description: 'Internet',
      ),
      _expense(
        id: '2',
        categoryId: 'bills',
        categoryName: 'Bills',
        amount: 305,
        date: DateTime(2026, 2, 1),
        description: 'Internet',
      ),
      _expense(
        id: '3',
        categoryId: 'bills',
        categoryName: 'Bills',
        amount: 295,
        date: DateTime(2026, 3, 1),
        description: 'Internet',
      ),
    ]);

    expect(suggestions, hasLength(1));
    expect(suggestions.single.frequency, RecurringFrequency.monthly);
  });

  test('detects repeated weekly transport expenses', () {
    final suggestions = const RepeatedExpenseDetector().detect([
      _expense(
        id: '1',
        categoryId: 'transport',
        categoryName: 'Transport',
        amount: 100,
        date: DateTime(2026, 5, 1),
        description: 'Metro pass',
      ),
      _expense(
        id: '2',
        categoryId: 'transport',
        categoryName: 'Transport',
        amount: 102,
        date: DateTime(2026, 5, 8),
        description: 'Metro pass',
      ),
      _expense(
        id: '3',
        categoryId: 'transport',
        categoryName: 'Transport',
        amount: 98,
        date: DateTime(2026, 5, 15),
        description: 'Metro pass',
      ),
    ]);

    expect(suggestions.single.frequency, RecurringFrequency.weekly);
  });

  test('ignores random non-repeated expenses', () {
    final suggestions = const RepeatedExpenseDetector().detect([
      _expense(
        id: '1',
        categoryId: 'food',
        categoryName: 'Food',
        amount: 100,
        date: DateTime(2026, 5, 1),
        description: 'Lunch',
      ),
      _expense(
        id: '2',
        categoryId: 'food',
        categoryName: 'Food',
        amount: 450,
        date: DateTime(2026, 5, 3),
        description: 'Dinner',
      ),
      _expense(
        id: '3',
        categoryId: 'shopping',
        categoryName: 'Shopping',
        amount: 900,
        date: DateTime(2026, 5, 20),
        description: 'Shoes',
      ),
    ]);

    expect(suggestions, isEmpty);
  });
}
