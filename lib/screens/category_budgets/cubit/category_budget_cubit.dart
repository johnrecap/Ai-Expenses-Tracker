import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/category_budgets/services/category_budget_calculator.dart';

part 'category_budget_state.dart';

class CategoryBudgetCubit extends Cubit<CategoryBudgetState> {
  final CategoryBudgetRepository _categoryBudgetRepository;
  final CategoryRepository _categoryRepository;
  final SettingsRepository? _settingsRepository;
  final CategoryBudgetCalculator _calculator;
  StreamSubscription<List<CategoryBudget>>? _subscription;

  CategoryBudgetCubit({
    required CategoryBudgetRepository categoryBudgetRepository,
    required CategoryRepository categoryRepository,
    SettingsRepository? settingsRepository,
    CategoryBudgetCalculator calculator = const CategoryBudgetCalculator(),
  })  : _categoryBudgetRepository = categoryBudgetRepository,
        _categoryRepository = categoryRepository,
        _settingsRepository = settingsRepository,
        _calculator = calculator,
        super(CategoryBudgetInitial());

  Future<void> watchMonth({
    required String month,
    required List<Expense> expenses,
  }) async {
    emit(CategoryBudgetLoading());
    await _subscription?.cancel();

    try {
      final categories = await _categoryRepository.getCategories();
      final settings = await _settingsRepository?.getSettings();
      _subscription = _categoryBudgetRepository
          .watchCategoryBudgetsForMonth(month: month)
          .listen(
        (budgets) {
          _emitReady(
            month: month,
            budgets: budgets,
            categories: categories,
            expenses: expenses,
            settings: settings,
          );
        },
        onError: (_) {
          emit(const CategoryBudgetFailure('Failed to load category budgets.'));
        },
      );
    } catch (_) {
      emit(const CategoryBudgetFailure('Failed to load category budgets.'));
    }
  }

  Future<void> saveBudget(CategoryBudget budget) async {
    final validationMessage = _validationMessage(budget);
    if (validationMessage != null) {
      emit(CategoryBudgetFailure(validationMessage));
      return;
    }

    emit(CategoryBudgetSaving(state.readyOrNull));
    try {
      await _categoryBudgetRepository.saveCategoryBudget(budget);
      emit(const CategoryBudgetActionSuccess('Category budget saved.'));
    } catch (_) {
      emit(const CategoryBudgetFailure('Failed to save category budget.'));
    }
  }

  Future<void> archiveBudget(CategoryBudget budget) async {
    if (budget.categoryBudgetId.isEmpty) {
      emit(const CategoryBudgetFailure('Select a category budget to archive.'));
      return;
    }

    emit(CategoryBudgetSaving(state.readyOrNull));
    try {
      await _categoryBudgetRepository.archiveCategoryBudget(
        budget.categoryBudgetId,
      );
      emit(const CategoryBudgetActionSuccess('Category budget archived.'));
    } catch (_) {
      emit(const CategoryBudgetFailure('Failed to archive category budget.'));
    }
  }

  void _emitReady({
    required String month,
    required List<CategoryBudget> budgets,
    required List<Category> categories,
    required List<Expense> expenses,
    UserSettings? settings,
  }) {
    final activeCategories =
        categories.where((category) => !category.isArchived).toList();
    final progress = _calculator.calculateAll(
      budgets: budgets,
      expenses: expenses,
      categories: activeCategories,
      selectedMonth: month,
      settings: settings,
    );
    emit(CategoryBudgetReady(
      month: month,
      budgets: budgets,
      categories: activeCategories,
      expenses: expenses,
      progress: progress,
      settings: settings,
    ));
  }

  String? _validationMessage(CategoryBudget budget) {
    if (budget.categoryId.trim().isEmpty) return 'Select a category.';
    if (budget.month.trim().isEmpty) return 'Select a month.';
    if (budget.currency.trim().isEmpty) return 'Select a currency.';
    if (budget.limitAmount <= 0) return 'Enter a valid budget limit.';
    if (budget.warningThresholdPercent < 1 ||
        budget.warningThresholdPercent > 100) {
      return 'Warning threshold must be between 1 and 100.';
    }
    return null;
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
