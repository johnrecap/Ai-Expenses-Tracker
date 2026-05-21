import 'models/category_budget.dart';

abstract class CategoryBudgetRepository {
  Future<void> saveCategoryBudget(CategoryBudget categoryBudget);

  Future<void> archiveCategoryBudget(String categoryBudgetId);

  Future<List<CategoryBudget>> getCategoryBudgetsForMonth({
    required String month,
    bool includeArchived = false,
  });

  Stream<List<CategoryBudget>> watchCategoryBudgetsForMonth({
    required String month,
    bool includeArchived = false,
  });
}
