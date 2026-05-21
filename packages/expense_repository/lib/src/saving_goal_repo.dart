import 'package:expense_repository/expense_repository.dart';

abstract class SavingGoalRepository {
  Future<void> createSavingGoal(SavingGoal goal);
  Future<void> updateSavingGoal(SavingGoal goal);
  Future<void> archiveSavingGoal(String goalId);
  Future<void> contributeToSavingGoal({
    required String goalId,
    required double amount,
  });
  Stream<List<SavingGoal>> watchSavingGoals({bool includeArchived = false});
}
