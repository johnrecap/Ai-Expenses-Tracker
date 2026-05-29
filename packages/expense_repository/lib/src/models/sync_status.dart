enum SyncStatus {
  pending,
  syncing,
  synced,
  failed;

  static SyncStatus fromFirestoreMetadata({
    required bool hasPendingWrites,
  }) {
    return hasPendingWrites ? SyncStatus.pending : SyncStatus.synced;
  }

  bool get isPending => this == SyncStatus.pending;
  bool get isSyncing => this == SyncStatus.syncing;
  bool get isFailed => this == SyncStatus.failed;
  bool get isUnresolved => isPending || isSyncing || isFailed;
}

enum SyncStatusReason {
  queued,
  syncing,
  offline,
  auth,
  server,
  validation,
  unknown;

  bool get canRetry =>
      this == SyncStatusReason.offline ||
      this == SyncStatusReason.auth ||
      this == SyncStatusReason.server ||
      this == SyncStatusReason.unknown;
}
