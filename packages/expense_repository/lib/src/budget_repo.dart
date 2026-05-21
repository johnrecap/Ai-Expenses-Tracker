import 'models/budget.dart';

abstract class BudgetRepository {
  Future<void> saveBudget(Budget budget);

  Future<Budget?> getCurrentMonthBudget({
    required int month,
    required int year,
  });

  Stream<Budget?> watchCurrentMonthBudget({
    required int month,
    required int year,
  });
}
