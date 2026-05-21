enum SyncStatus {
  pending,
  synced,
  failed;

  static SyncStatus fromFirestoreMetadata({
    required bool hasPendingWrites,
  }) {
    return hasPendingWrites ? SyncStatus.pending : SyncStatus.synced;
  }

  bool get isPending => this == SyncStatus.pending;
}
