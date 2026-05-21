import 'models/ai_action_log.dart';

abstract class AiActionLogRepository {
  Future<void> createActionLog(AiActionLog log);

  Future<void> updateActionLogStatus({
    required String actionId,
    required AiActionLogStatus status,
    DateTime? confirmedAt,
    String? targetExpenseId,
    String? errorMessage,
  });

  Future<List<AiActionLog>> getRecentActionLogs({int limit = 50});
}
