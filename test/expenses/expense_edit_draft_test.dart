import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/expenses/models/expense_edit_draft.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final category = Category(
    categoryId: 'food',
    name: 'Food',
    totalExpenses: 0,
    icon: 'food',
    color: 0xFFFF7043,
  );

  Expense expense({double amount = 100, String currency = 'EGP'}) {
    return Expense(
      expenseId: 'expense-1',
      userId: 'user-1',
      category: category,
      date: DateTime(2026, 5, 20),
      amount: amount,
      description: 'lunch',
      paymentMethod: PaymentMethod.cash,
      currency: currency,
      createdAt: DateTime(2026, 5, 20),
      updatedAt: DateTime(2026, 5, 20),
    );
  }

  test('validates invalid amount and missing category', () {
    final draft = ExpenseEditDraft(
      amount: 0,
      category: Category.empty,
      date: DateTime(2026, 5, 20),
      description: '',
      merchant: null,
      tags: const [],
      paymentMethod: PaymentMethod.cash,
      currency: 'EGP',
    );

    expect(
      draft.validate(),
      containsAll([
        ExpenseEditValidationError.invalidAmount,
        ExpenseEditValidationError.missingCategory,
      ]),
    );
  });

  test('adjusts amount with positive and negative deltas', () {
    final draft = ExpenseEditDraft.fromExpense(expense(amount: 300));

    expect(draft.adjustAmount(25).amount, 325);
    expect(draft.adjustAmount(-75).amount, 225);
    expect(
      draft.adjustAmount(-300).validate(),
      contains(ExpenseEditValidationError.invalidAmount),
    );
  });

  test('detects money input changes separately from text changes', () {
    final original = expense(amount: 100, currency: 'USD');

    expect(
      ExpenseEditDraft.fromExpense(
        original,
      ).copyWith(description: 'changed').moneyInputsChanged(original),
      isFalse,
    );
    expect(
      ExpenseEditDraft.fromExpense(
        original,
      ).copyWith(amount: 125).moneyInputsChanged(original),
      isTrue,
    );
    expect(
      ExpenseEditDraft.fromExpense(
        original,
      ).copyWith(currency: 'EGP').moneyInputsChanged(original),
      isTrue,
    );
  });
}
