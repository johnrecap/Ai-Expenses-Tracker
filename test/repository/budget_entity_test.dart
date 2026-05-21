import 'package:expense_repository/expense_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('round-trips budget entity document data', () {
    final budget = Budget(
      budgetId: '2026-05',
      userId: 'user-1',
      month: 5,
      year: 2026,
      amount: 1500,
      currency: 'EGP',
      warningThresholdPercent: 75,
      createdAt: DateTime(2026, 5),
      updatedAt: DateTime(2026, 5, 15),
    );

    final doc = budget.toEntity().toDocument();
    final roundTripped = Budget.fromEntity(BudgetEntity.fromDocument(doc));

    expect(roundTripped.budgetId, '2026-05');
    expect(roundTripped.month, 5);
    expect(roundTripped.year, 2026);
    expect(roundTripped.amount, 1500);
    expect(roundTripped.warningThresholdPercent, 75);
  });

  test('defaults missing warning threshold and validates month', () {
    final entity = BudgetEntity.fromDocument({
      'budgetId': '2026-13',
      'userId': 'user-1',
      'month': 13,
      'year': 2026,
      'amount': 1000,
      'currency': 'EGP',
    });

    expect(entity.month, 1);
    expect(entity.warningThresholdPercent, 80);
  });

  test('builds deterministic budget ids', () {
    expect(Budget.budgetIdFor(month: 5, year: 2026), '2026-05');
    expect(FirebaseBudgetRepository.budgetPathFor('user-1'),
        'users/user-1/budgets');
  });
}
