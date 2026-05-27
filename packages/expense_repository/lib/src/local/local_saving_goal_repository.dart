import 'package:expense_repository/expense_repository.dart';

class LocalSavingGoalRepository implements SavingGoalRepository {
  final LocalRepositoryStore store;

  const LocalSavingGoalRepository({required this.store});

  @override
  Future<void> archiveSavingGoal(String goalId) async {
    final current = store.savingGoals[goalId];
    if (current == null) return;
    await updateSavingGoal(
      current.copyWith(isArchived: true, updatedAt: DateTime.now()),
    );
  }

  @override
  Future<void> contributeToSavingGoal({
    required String goalId,
    required double amount,
  }) async {
    final current = store.savingGoals[goalId];
    if (current == null) return;
    await updateSavingGoal(
      current.copyWith(
        currentAmount: current.currentAmount + amount,
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> createSavingGoal(SavingGoal goal) async =>
      updateSavingGoal(goal);

  @override
  Future<void> updateSavingGoal(SavingGoal goal) async {
    final normalized = goal.copyWith(
      userId: goal.userId.isEmpty ? store.userId : goal.userId,
      updatedAt: DateTime.now(),
    );
    store.savingGoals[normalized.goalId] = normalized;
    store.enqueue(
      store.change(
        entityType: SyncEntityType.savingGoal,
        entityId: normalized.goalId,
        operation: SyncOperation.upsert,
        data: normalized.toEntity().toDocument(),
      ),
    );
    store.emitSavingGoals();
  }

  @override
  Stream<List<SavingGoal>> watchSavingGoals({bool includeArchived = false}) {
    return store.watchSavingGoals().map(
          (_) => store.orderedSavingGoals(includeArchived: includeArchived),
        );
  }
}
