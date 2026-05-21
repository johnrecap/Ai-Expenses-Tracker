import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/ai/models/ai_target_match.dart';
import 'package:expenses_tracker/ai/services/ai_action_matcher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const matcher = AiActionMatcher();

  test('returns no match when no deterministic fields match', () {
    final result = matcher.match(
      expenses: [_expense(id: '1', description: 'Groceries')],
      query: 'uber',
    );

    expect(result.resolution, AiTargetMatchResolution.noMatch);
    expect(result.candidates, isEmpty);
  });

  test('returns one strong match when score is high and explainable', () {
    final result = matcher.match(
      expenses: [
        _expense(id: '1', description: 'Uber ride', amount: 180),
        _expense(id: '2', description: 'Restaurant', amount: 180),
      ],
      query: 'uber',
      amount: 180,
      category: 'Transport',
    );

    expect(result.resolution, AiTargetMatchResolution.singleStrongMatch);
    expect(result.selected?.expense.expenseId, '1');
    expect(result.selected?.matchedFields, contains('text'));
    expect(result.selected?.reason, contains('Matched'));
  });

  test('returns multiple candidates when matches are close', () {
    final result = matcher.match(
      expenses: [
        _expense(id: '1', description: 'Uber ride', amount: 180),
        _expense(id: '2', description: 'Uber trip', amount: 180),
      ],
      query: 'uber',
      amount: 180,
    );

    expect(result.resolution, AiTargetMatchResolution.multipleCandidates);
    expect(result.requiresManualSelection, isTrue);
    expect(result.candidates.length, 2);
  });

  test('last expense command prefers recent expenses', () {
    final now = DateTime.now();
    final result = matcher.match(
      expenses: [
        _expense(id: 'old', date: now.subtract(const Duration(days: 10))),
        _expense(id: 'new', date: now),
      ],
      preferLast: true,
    );

    expect(result.candidates.first.expense.expenseId, 'new');
    expect(result.candidates.first.matchedFields, contains('recent'));
  });
}

Expense _expense({
  required String id,
  String description = '',
  String categoryName = 'Transport',
  int amount = 100,
  DateTime? date,
}) {
  final category = Category(
    categoryId: categoryName.toLowerCase(),
    name: categoryName,
    totalExpenses: 0,
    icon: 'transport',
    color: 0xFF000000,
  );
  return Expense(
    expenseId: id,
    userId: 'user-1',
    category: category,
    categoryId: category.categoryId,
    categoryName: category.name,
    categoryIcon: category.icon,
    categoryColor: category.color,
    date: date ?? DateTime(2026, 5, 15),
    amount: amount,
    description: description,
    paymentMethod: PaymentMethod.cash,
    currency: 'EGP',
  );
}
