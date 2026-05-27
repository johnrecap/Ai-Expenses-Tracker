import 'package:expense_repository/expense_repository.dart';

class LocalAiActionLogRepository implements AiActionLogRepository {
  final LocalRepositoryStore store;

  const LocalAiActionLogRepository({required this.store});

  @override
  Future<void> createActionLog(AiActionLog log) async {
    final normalized = log.copyWith(
      userId: log.userId.isEmpty ? store.userId : log.userId,
    );
    store.aiActionLogs[normalized.actionId] = normalized;
    store.enqueue(
      store.change(
        entityType: SyncEntityType.aiActionLog,
        entityId: normalized.actionId,
        operation: SyncOperation.upsert,
        data: normalized.toEntity().toDocument(),
      ),
    );
  }

  @override
  Future<List<AiActionLog>> getRecentActionLogs({int limit = 50}) async {
    return store.orderedAiActionLogs(limit: limit);
  }

  @override
  Future<void> updateActionLogStatus({
    required String actionId,
    required AiActionLogStatus status,
    DateTime? confirmedAt,
    String? targetExpenseId,
    String? errorMessage,
  }) async {
    final current = store.aiActionLogs[actionId];
    if (current == null) return;
    final updated = current.copyWith(
      status: status,
      confirmedAt: confirmedAt,
      targetExpenseId: targetExpenseId,
      errorMessage: errorMessage,
    );
    store.aiActionLogs[actionId] = updated;
    store.enqueue(
      store.change(
        entityType: SyncEntityType.aiActionLog,
        entityId: actionId,
        operation: SyncOperation.upsert,
        data: updated.toEntity().toDocument(),
      ),
    );
  }
}
