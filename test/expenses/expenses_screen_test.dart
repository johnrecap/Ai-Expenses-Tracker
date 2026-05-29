import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/expenses/views/expenses_screen.dart';
import 'package:flutter/material.dart'
    show Size, TextField, TextFormField, Widget;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_repositories.dart';
import '../helpers/localized_test_app.dart';
import '../helpers/ui_fixture_data.dart';

Expense _expense({required String id, required String description}) {
  final category = Category(
    categoryId: 'food',
    name: 'Food',
    totalExpenses: 0,
    icon: 'food',
    color: 1,
  );
  return Expense(
    expenseId: id,
    userId: 'user-1',
    category: category,
    categoryId: 'food',
    categoryName: 'Food',
    date: DateTime(2026, 5, 15),
    amount: 250,
    description: description,
    paymentMethod: PaymentMethod.cash,
    currency: 'EGP',
    createdAt: DateTime(2026, 5, 1),
    updatedAt: DateTime(2026, 5, 1),
    source: ExpenseSource.recurring,
    recurringExpenseId: 'recurring-1',
    aiActionId: 'ai-action-1',
  );
}

Widget _repositoryApp({
  required FakeExpenseRepository repository,
  required List<Expense> expenses,
  ExpenseFilter initialFilter = ExpenseFilter.empty,
  ExpensePageCursor? initialCursor,
  bool initialHasMore = false,
}) {
  return MultiRepositoryProvider(
    providers: [
      RepositoryProvider<ExpenseRepository>.value(value: repository),
      RepositoryProvider<SettingsRepository>.value(
        value: FakeSettingsRepository(
          UserSettings.defaults(
            userId: 'user-1',
            updatedAt: DateTime(2026, 5, 1),
          ),
        ),
      ),
    ],
    child: localizedTestApp(
      home: ExpensesScreen(
        expenses: expenses,
        initialFilter: initialFilter,
        initialCursor: initialCursor,
        initialHasMore: initialHasMore,
      ),
    ),
  );
}

Future<void> _openExpenseAction(WidgetTester tester, String actionLabel) async {
  await tester.tap(find.byTooltip('Expense actions'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(actionLabel).last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows empty state when no expenses match', (tester) async {
    await tester.pumpWidget(
      localizedTestApp(home: const ExpensesScreen(expenses: [])),
    );

    expect(find.text('No expenses match your filters'), findsOneWidget);
  });

  testWidgets('search text filters expense results', (tester) async {
    await tester.pumpWidget(
      localizedTestApp(
        home: ExpensesScreen(
          expenses: [
            _expense(id: '1', description: 'lunch restaurant'),
            _expense(id: '2', description: 'internet bill'),
          ],
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'internet');
    await tester.pump();

    expect(find.text('internet bill'), findsOneWidget);
    expect(find.text('lunch restaurant'), findsNothing);
  });

  testWidgets('initial report drilldown filter is active and clearable', (
    tester,
  ) async {
    await tester.pumpWidget(
      localizedTestApp(
        home: ExpensesScreen(
          expenses: [
            _expense(id: '1', description: 'lunch restaurant'),
            _expense(id: '2', description: 'internet bill'),
          ],
          initialFilter: const ExpenseFilter(query: 'internet'),
        ),
      ),
    );

    expect(find.text('Report drilldown filter active'), findsOneWidget);
    expect(find.text('internet bill'), findsOneWidget);
    expect(find.text('lunch restaurant'), findsNothing);

    await tester.tap(find.text('Reset'));
    await tester.pump();

    expect(find.text('Report drilldown filter active'), findsNothing);
    expect(find.text('internet bill'), findsOneWidget);
    expect(find.text('lunch restaurant'), findsOneWidget);
  });

  testWidgets('load more appends the next expense page without duplicates', (
    tester,
  ) async {
    final first = _expense(id: '2', description: 'newer lunch')
      ..date = DateTime(2026, 5, 16);
    final second = _expense(id: '1', description: 'older dinner')
      ..date = DateTime(2026, 5, 15);
    final repository = FakeExpenseRepository([first, second]);
    addTearDown(repository.close);

    await tester.pumpWidget(
      _repositoryApp(
        repository: repository,
        expenses: [first],
        initialCursor: ExpensePageCursor.fromExpense(first),
        initialHasMore: true,
      ),
    );

    expect(find.text('newer lunch'), findsOneWidget);
    expect(find.text('older dinner'), findsNothing);
    expect(find.text('Load more'), findsOneWidget);

    await tester.tap(find.text('Load more'));
    await tester.pumpAndSettle();

    expect(find.text('newer lunch'), findsOneWidget);
    expect(find.text('older dinner'), findsOneWidget);
  });

  testWidgets('opens edit form with existing values', (tester) async {
    final expense = _expense(id: '1', description: 'lunch restaurant');
    final repository = FakeExpenseRepository([expense]);
    addTearDown(repository.close);

    await tester.pumpWidget(
      _repositoryApp(repository: repository, expenses: [expense]),
    );

    await _openExpenseAction(tester, 'Edit');

    expect(find.text('Edit expense'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '250'), findsOneWidget);
    expect(
      find.widgetWithText(TextFormField, 'lunch restaurant'),
      findsOneWidget,
    );
    expect(find.text('Food'), findsWidgets);
    expect(find.text('Cash'), findsOneWidget);
    expect(find.text('EGP'), findsOneWidget);
    expect(find.text('15/05/2026'), findsOneWidget);
  });

  testWidgets('saving edit updates expense and preserves references', (
    tester,
  ) async {
    final expense = _expense(id: '1', description: 'lunch restaurant');
    final repository = FakeExpenseRepository([expense]);
    addTearDown(repository.close);

    await tester.pumpWidget(
      _repositoryApp(repository: repository, expenses: [expense]),
    );

    await _openExpenseAction(tester, 'Edit');
    await tester.enterText(find.widgetWithText(TextFormField, '250'), '325');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'lunch restaurant'),
      'team lunch',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(repository.updatedExpenses, hasLength(1));
    final updated = repository.updatedExpenses.single;
    expect(updated.expenseId, expense.expenseId);
    expect(updated.userId, expense.userId);
    expect(updated.createdAt, expense.createdAt);
    expect(updated.source, expense.source);
    expect(updated.recurringExpenseId, expense.recurringExpenseId);
    expect(updated.aiActionId, expense.aiActionId);
    expect(updated.amount, 325);
    expect(updated.description, 'team lunch');
  });

  testWidgets('invalid edit amount does not update expense', (tester) async {
    final expense = _expense(id: '1', description: 'lunch restaurant');
    final repository = FakeExpenseRepository([expense]);
    addTearDown(repository.close);

    await tester.pumpWidget(
      _repositoryApp(repository: repository, expenses: [expense]),
    );

    await _openExpenseAction(tester, 'Edit');
    await tester.enterText(find.widgetWithText(TextFormField, '250'), '0');
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(repository.updatedExpenses, isEmpty);
    expect(find.text('Enter a valid expense amount'), findsOneWidget);
  });

  testWidgets('canceling delete does not call repository delete', (
    tester,
  ) async {
    final expense = _expense(id: '1', description: 'lunch restaurant');
    final repository = FakeExpenseRepository([expense]);
    addTearDown(repository.close);

    await tester.pumpWidget(
      _repositoryApp(repository: repository, expenses: [expense]),
    );

    await _openExpenseAction(tester, 'Delete');
    expect(find.text('Delete expense?'), findsOneWidget);
    expect(find.textContaining('Food'), findsWidgets);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(repository.deletedExpenseIds, isEmpty);
  });

  testWidgets('confirming delete calls repository delete once', (tester) async {
    final expense = _expense(id: '1', description: 'lunch restaurant');
    final repository = FakeExpenseRepository([expense]);
    addTearDown(repository.close);

    await tester.pumpWidget(
      _repositoryApp(repository: repository, expenses: [expense]),
    );

    await _openExpenseAction(tester, 'Delete');
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(repository.deletedExpenseIds, ['1']);
    expect(find.text('Expense deleted'), findsOneWidget);
  });

  testWidgets('compact transaction rows fit long bilingual finance data', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      localizedTestApp(
        home: ExpensesScreen(expenses: UiFixtureData.expenses()),
      ),
    );

    expect(find.textContaining('987,654,321'), findsOneWidget);
    expect(find.textContaining('وصف عربي طويل'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
