import 'dart:async';

import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/category_budgets/cubit/category_budget_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('loads active budgets with calculated progress', () async {
    final budget = _budget();
    final budgetRepository = _FakeCategoryBudgetRepository([budget]);
    final categoryRepository = _FakeCategoryRepository([_category()]);
    final cubit = CategoryBudgetCubit(
      categoryBudgetRepository: budgetRepository,
      categoryRepository: categoryRepository,
    );

    await cubit.watchMonth(
      month: '2026-05',
      expenses: [
        _expense(amount: 500),
      ],
    );
    await Future<void>.delayed(Duration.zero);

    final state = cubit.state as CategoryBudgetReady;
    expect(state.progress.single.spent, 500);

    await cubit.close();
    await budgetRepository.close();
  });

  test('validates budget before saving', () async {
    final budgetRepository = _FakeCategoryBudgetRepository([]);
    final categoryRepository = _FakeCategoryRepository([_category()]);
    final cubit = CategoryBudgetCubit(
      categoryBudgetRepository: budgetRepository,
      categoryRepository: categoryRepository,
    );

    await cubit.saveBudget(_budget(limitAmount: 0));

    expect(cubit.state, isA<CategoryBudgetFailure>());
    expect(budgetRepository.savedBudgets, isEmpty);

    await cubit.close();
    await budgetRepository.close();
  });
}

class _FakeCategoryBudgetRepository implements CategoryBudgetRepository {
  final _controller = StreamController<List<CategoryBudget>>.broadcast();
  final List<CategoryBudget> savedBudgets = [];
  List<CategoryBudget> budgets;

  _FakeCategoryBudgetRepository(this.budgets);

  @override
  Future<void> archiveCategoryBudget(String categoryBudgetId) async {
    budgets = budgets
        .map(
          (budget) => budget.categoryBudgetId == categoryBudgetId
              ? budget.copyWith(isArchived: true)
              : budget,
        )
        .toList();
    _controller.add(budgets);
  }

  @override
  Future<List<CategoryBudget>> getCategoryBudgetsForMonth({
    required String month,
    bool includeArchived = false,
  }) async {
    return budgets
        .where(
          (budget) =>
              budget.month == month && (includeArchived || !budget.isArchived),
        )
        .toList();
  }

  @override
  Future<void> saveCategoryBudget(CategoryBudget categoryBudget) async {
    savedBudgets.add(categoryBudget);
    budgets = [...budgets, categoryBudget];
    _controller.add(budgets);
  }

  @override
  Stream<List<CategoryBudget>> watchCategoryBudgetsForMonth({
    required String month,
    bool includeArchived = false,
  }) {
    Future<void>.microtask(() {
      _controller.add(
        budgets
            .where(
              (budget) =>
                  budget.month == month &&
                  (includeArchived || !budget.isArchived),
            )
            .toList(),
      );
    });
    return _controller.stream;
  }

  Future<void> close() => _controller.close();
}

class _FakeCategoryRepository implements CategoryRepository {
  final List<Category> categories;

  const _FakeCategoryRepository(this.categories);

  @override
  Future<void> archiveCategory(Category category) async {}

  @override
  Future<void> createCategory(Category category) async {}

  @override
  Future<List<Category>> getCategories({bool includeArchived = false}) async {
    return categories
        .where((category) => includeArchived || !category.isArchived)
        .toList();
  }

  @override
  Future<void> updateCategory(Category category) async {}

  @override
  Stream<List<Category>> watchCategories({bool includeArchived = false}) {
    return Stream.value(categories);
  }
}

CategoryBudget _budget({double limitAmount = 1000}) {
  return CategoryBudget(
    categoryBudgetId: '2026-05_food_EGP',
    userId: 'user-1',
    categoryId: 'food',
    categoryName: 'Food',
    month: '2026-05',
    currency: 'EGP',
    limitAmount: limitAmount,
    warningThresholdPercent: 80,
    isArchived: false,
    createdAt: DateTime(2026, 5),
    updatedAt: DateTime(2026, 5),
  );
}

Category _category() {
  return Category(
    categoryId: 'food',
    name: 'Food',
    totalExpenses: 0,
    icon: 'restaurant',
    color: 0xffff0000,
  );
}

Expense _expense({required int amount}) {
  return Expense(
    expenseId: 'expense-$amount',
    category: _category(),
    categoryId: 'food',
    categoryName: 'Food',
    date: DateTime(2026, 5, 10),
    amount: amount,
    currency: 'EGP',
  );
}
