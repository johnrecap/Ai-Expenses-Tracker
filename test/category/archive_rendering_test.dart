import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/add_expense/blocs/create_categorybloc/create_category_bloc.dart';
import 'package:expenses_tracker/screens/add_expense/blocs/create_expense_bloc/create_expense_bloc.dart';
import 'package:expenses_tracker/screens/add_expense/blocs/get_categories_bloc/get_categories_bloc.dart';
import 'package:expenses_tracker/screens/add_expense/views/add_expense.dart';
import 'package:expenses_tracker/screens/budget/blocs/budget_bloc/budget_bloc.dart';
import 'package:expenses_tracker/screens/home/views/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/localized_test_app.dart';

class FakeCategoryRepository implements CategoryRepository {
  final List<Category> categories;

  FakeCategoryRepository(this.categories);

  @override
  Future<void> archiveCategory(Category category) async {}

  @override
  Future<void> createCategory(Category category) async {}

  @override
  Future<List<Category>> getCategories({bool includeArchived = false}) async {
    if (includeArchived) return categories;
    return categories.where((category) => !category.isArchived).toList();
  }

  @override
  Future<void> updateCategory(Category category) async {}

  @override
  Stream<List<Category>> watchCategories({bool includeArchived = false}) {
    return Stream.value(
      includeArchived
          ? categories
          : categories.where((category) => !category.isArchived).toList(),
    );
  }
}

class FakeExpenseRepository implements ExpenseRepository {
  @override
  Future<void> createExpense(Expense expense) async {}

  @override
  Future<void> deleteExpense(String expenseId) async {}

  @override
  Future<Expense?> getExpenseById(String expenseId) async => null;

  @override
  Future<List<Expense>> getExpenses() async => [];

  @override
  Future<ExpensePage> getExpensePage({
    int limit = defaultExpensePageSize,
    ExpensePageCursor? startAfter,
    ExpenseFilter filter = ExpenseFilter.empty,
  }) async {
    return ExpensePage.fromOrderedExpenses(const [], limit: limit);
  }

  @override
  Future<List<Expense>> getExpensesByFilter(ExpenseFilter filter) async => [];

  @override
  Future<void> updateExpense(Expense expense) async {}

  @override
  Stream<List<Expense>> watchExpenses() => const Stream.empty();

  @override
  Stream<ExpensePage> watchRecentExpensePage({
    int limit = defaultExpensePageSize,
  }) {
    return Stream.value(ExpensePage.fromOrderedExpenses(const [], limit: limit));
  }
}

class FakeBudgetRepository implements BudgetRepository {
  @override
  Future<Budget?> getCurrentMonthBudget({
    required int month,
    required int year,
  }) async {
    return null;
  }

  @override
  Future<void> saveBudget(Budget budget) async {}

  @override
  Stream<Budget?> watchCurrentMonthBudget({
    required int month,
    required int year,
  }) {
    return const Stream.empty();
  }
}

Category _category({
  required String id,
  required String name,
  bool isArchived = false,
}) {
  return Category(
    categoryId: id,
    userId: 'user-1',
    name: name,
    totalExpenses: 0,
    icon: 'food',
    color: 4280391411,
    isArchived: isArchived,
    createdAt: DateTime(2026, 5, 1),
    updatedAt: DateTime(2026, 5, 1),
  );
}

void main() {
  testWidgets('add expense hides archived categories', (tester) async {
    final categoryRepository = FakeCategoryRepository([
      _category(id: 'active', name: 'Active Food'),
      _category(id: 'archived', name: 'Archived Food', isArchived: true),
    ]);
    final expenseRepository = FakeExpenseRepository();

    await tester.pumpWidget(
      localizedTestApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) =>
                  GetCategoriesBloc(categoryRepository)..add(GetCategories()),
            ),
            BlocProvider(
              create: (_) => CreateCategoryBloc(categoryRepository),
            ),
            BlocProvider(
              create: (_) => CreateExpenseBloc(expenseRepository),
            ),
          ],
          child: const AddExpense(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Active Food'), findsOneWidget);
    expect(find.text('Archived Food'), findsNothing);
  });

  testWidgets('old expenses still render archived category snapshots',
      (tester) async {
    final archivedCategory = _category(
      id: 'archived',
      name: 'Archived Food',
      isArchived: true,
    );

    await tester.pumpWidget(
      localizedTestApp(
        home: Scaffold(
          body: BlocProvider(
            create: (_) => BudgetBloc(FakeBudgetRepository()),
            child: MainScreen(
              [
                Expense(
                  expenseId: 'expense-1',
                  category: archivedCategory,
                  date: DateTime(2026, 5, 15),
                  amount: 25,
                ),
              ],
              user: AppUser(
                userId: 'user-1',
                email: 'user@example.com',
                displayName: 'User',
                photoUrl: null,
                createdAt: DateTime(2026, 5, 1),
              ),
              settings: UserSettings.defaults(
                userId: 'user-1',
                updatedAt: DateTime(2026, 5, 1),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Archived Food'), findsWidgets);
  });
}
