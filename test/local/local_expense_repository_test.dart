import 'package:expense_repository/expense_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalExpenseRepository', () {
    test('creates expenses locally with pending sync status', () async {
      final store = LocalRepositoryStore(userId: 'user-1');
      final repository = LocalExpenseRepository(store: store);
      final expense = _expense('expense-1', amount: 100);

      await repository.createExpense(expense);

      final saved = await repository.getExpenseById('expense-1');
      expect(saved, isNotNull);
      expect(saved!.userId, 'user-1');
      expect(saved.syncStatus, SyncStatus.pending);
      expect(store.pendingChanges, hasLength(1));
      expect(store.pendingChanges.single.operation, SyncOperation.upsert);
    });

    test('updates and deletes expenses through the sync queue', () async {
      final store = LocalRepositoryStore(userId: 'user-1');
      final repository = LocalExpenseRepository(store: store);
      await repository.createExpense(_expense('expense-1', amount: 100));

      await repository.updateExpense(_expense('expense-1', amount: 250));
      expect((await repository.getExpenseById('expense-1'))!.amount, 250);

      await repository.deleteExpense('expense-1');

      expect(await repository.getExpenseById('expense-1'), isNull);
      expect(store.pendingChanges.last.operation, SyncOperation.delete);
    });

    test('filters local expenses by currency and query', () async {
      final store = LocalRepositoryStore(userId: 'user-1');
      final repository = LocalExpenseRepository(store: store);
      await repository.createExpense(
        _expense('expense-1',
            amount: 100, description: 'Coffee', currency: 'EGP'),
      );
      await repository.createExpense(
        _expense('expense-2', amount: 50, description: 'Taxi', currency: 'USD'),
      );

      final filtered = await repository.getExpensesByFilter(
        const ExpenseFilter(query: 'taxi', currency: 'USD'),
      );

      expect(filtered.map((expense) => expense.expenseId), ['expense-2']);
    });
  });
}

Expense _expense(
  String id, {
  required num amount,
  String description = 'Test expense',
  String currency = 'EGP',
}) {
  return Expense(
    expenseId: id,
    category: Category(
      categoryId: 'category-1',
      name: 'Food',
      totalExpenses: 0,
      icon: 'restaurant',
      color: 0xFF000000,
    ),
    date: DateTime(2026, 5, 26),
    amount: amount,
    description: description,
    currency: currency,
  );
}
