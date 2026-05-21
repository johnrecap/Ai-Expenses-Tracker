part of 'category_budget_cubit.dart';

sealed class CategoryBudgetState extends Equatable {
  const CategoryBudgetState();

  CategoryBudgetReady? get readyOrNull =>
      this is CategoryBudgetReady ? this as CategoryBudgetReady : null;

  @override
  List<Object?> get props => [];
}

final class CategoryBudgetInitial extends CategoryBudgetState {}

final class CategoryBudgetLoading extends CategoryBudgetState {}

final class CategoryBudgetReady extends CategoryBudgetState {
  final String month;
  final List<CategoryBudget> budgets;
  final List<Category> categories;
  final List<Expense> expenses;
  final List<CategoryBudgetProgress> progress;
  final UserSettings? settings;

  const CategoryBudgetReady({
    required this.month,
    required this.budgets,
    required this.categories,
    required this.expenses,
    required this.progress,
    this.settings,
  });

  @override
  List<Object?> get props =>
      [month, budgets, categories, expenses, progress, settings];
}

final class CategoryBudgetSaving extends CategoryBudgetState {
  final CategoryBudgetReady? previousState;

  const CategoryBudgetSaving(this.previousState);

  @override
  List<Object?> get props => [previousState];
}

final class CategoryBudgetActionSuccess extends CategoryBudgetState {
  final String message;

  const CategoryBudgetActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

final class CategoryBudgetFailure extends CategoryBudgetState {
  final String message;

  const CategoryBudgetFailure(this.message);

  @override
  List<Object?> get props => [message];
}
