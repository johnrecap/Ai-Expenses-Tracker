import 'package:expense_repository/expense_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('round-trips category budget entity document data', () {
    final budget = CategoryBudget(
      categoryBudgetId: '2026-05_food_EGP',
      userId: 'user-1',
      categoryId: 'food',
      categoryName: 'Food',
      month: '2026-05',
      currency: 'EGP',
      limitAmount: 3000,
      warningThresholdPercent: 90,
      isArchived: false,
      createdAt: DateTime(2026, 5),
      updatedAt: DateTime(2026, 5, 17),
    );

    final doc = budget.toEntity().toDocument();
    final roundTripped = CategoryBudget.fromEntity(
      CategoryBudgetEntity.fromDocument(doc),
    );

    expect(roundTripped.categoryBudgetId, '2026-05_food_EGP');
    expect(roundTripped.categoryId, 'food');
    expect(roundTripped.month, '2026-05');
    expect(roundTripped.limitAmount, 3000);
    expect(roundTripped.warningThresholdPercent, 90);
  });

  test('builds deterministic ids and user-scoped Firebase path', () {
    expect(
      CategoryBudget.categoryBudgetIdFor(
        month: '2026-05',
        categoryId: 'food',
        currency: 'egp',
      ),
      '2026-05_food_EGP',
    );
    expect(
      FirebaseCategoryBudgetRepository.categoryBudgetsPathFor('user-1'),
      'users/user-1/category_budgets',
    );
  });
}
