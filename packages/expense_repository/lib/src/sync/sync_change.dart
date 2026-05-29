import '../models/sync_status.dart';

enum SyncEntityType {
  settings,
  expense,
  category,
  categoryAlias,
  budget,
  categoryBudget,
  recurringExpense,
  savingGoal,
  walletAccount,
  transfer,
  aiActionLog;
}

enum SyncOperation {
  upsert,
  delete;
}

class SyncChange {
  final String id;
  final String userId;
  final SyncEntityType entityType;
  final String entityId;
  final SyncOperation operation;
  final Map<String, Object?> data;
  final DateTime clientUpdatedAt;
  final int? baseRevision;
  SyncStatus status;
  SyncStatusReason reason;
  DateTime? lastAttemptAt;
  String? lastErrorCode;

  SyncChange({
    required this.id,
    required this.userId,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.data,
    required this.clientUpdatedAt,
    this.baseRevision,
    SyncStatus? status,
    SyncStatusReason? reason,
    this.lastAttemptAt,
    this.lastErrorCode,
  })  : status = status ?? SyncStatus.pending,
        reason = reason ?? SyncStatusReason.queued;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'userId': userId,
      'entityType': entityType.name,
      'entityId': entityId,
      'operation': operation.name,
      'data': data,
      'clientUpdatedAt': clientUpdatedAt.toIso8601String(),
      if (baseRevision != null) 'baseRevision': baseRevision,
      'status': status.name,
      'reason': reason.name,
      if (lastAttemptAt != null) 'lastAttemptAt': lastAttemptAt!.toIso8601String(),
      if (lastErrorCode != null) 'lastErrorCode': lastErrorCode,
    };
  }
}
