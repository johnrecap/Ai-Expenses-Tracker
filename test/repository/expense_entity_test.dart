import 'package:expense_repository/expense_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('deserializes old expense documents with safe defaults', () {
    final entity = ExpenseEntity.fromDocument({
      'expenseId': 'old-expense',
      'category': {
        'categoryId': 'food',
        'name': 'Food',
        'totalExpenses': 0,
        'icon': 'food',
        'color': 0xff2ecc71,
      },
      'date': DateTime(2026, 5, 15),
      'amount': 250,
    });

    expect(entity.expenseId, 'old-expense');
    expect(entity.categoryId, 'food');
    expect(entity.categoryName, 'Food');
    expect(entity.description, '');
    expect(entity.merchant, isNull);
    expect(entity.tags, isEmpty);
    expect(entity.paymentMethod, PaymentMethod.cash);
    expect(entity.currency, 'EGP');
    expect(entity.source, ExpenseSource.manual);
    expect(entity.createdAt, DateTime(2026, 5, 15));
    expect(entity.updatedAt, DateTime(2026, 5, 15));
    expect(entity.amount, 250.0);
  });

  test('preserves decimal expense amounts from Firestore documents', () {
    final entity = ExpenseEntity.fromDocument({
      'expenseId': 'decimal-expense',
      'date': DateTime(2026, 5, 15),
      'amount': 120.75,
    });

    expect(entity.amount, 120.75);
  });

  test('serializes and deserializes upgraded expense documents', () {
    final category = Category(
      categoryId: 'transport',
      name: 'Transport',
      totalExpenses: 0,
      icon: 'transport',
      color: 0xff3498db,
    );
    final expense = Expense(
      expenseId: 'new-expense',
      userId: 'user-1',
      category: category,
      date: DateTime(2026, 5, 15),
      amount: 180.25,
      description: 'Uber ride',
      merchant: 'Uber',
      tags: const ['transport', 'work'],
      paymentMethod: PaymentMethod.wallet,
      currency: 'EGP',
      createdAt: DateTime(2026, 5, 15, 10),
      updatedAt: DateTime(2026, 5, 15, 11),
      source: ExpenseSource.ai,
      aiActionId: 'ai-action-1',
    );

    final document = expense.toEntity().toDocument();
    final entity = ExpenseEntity.fromDocument(
      Map<String, dynamic>.from(document),
    );

    expect(document['paymentMethod'], 'wallet');
    expect(document['source'], 'ai');
    expect(document['amount'], 180.25);
    expect(document['categoryId'], 'transport');
    expect(entity.expenseId, expense.expenseId);
    expect(entity.userId, expense.userId);
    expect(entity.categoryName, expense.categoryName);
    expect(entity.description, expense.description);
    expect(entity.merchant, 'Uber');
    expect(entity.tags, ['transport', 'work']);
    expect(entity.paymentMethod, PaymentMethod.wallet);
    expect(entity.currency, 'EGP');
    expect(entity.source, ExpenseSource.ai);
    expect(entity.aiActionId, 'ai-action-1');
    expect(entity.amount, 180.25);
  });
}
