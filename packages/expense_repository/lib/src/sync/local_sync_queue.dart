import 'dart:async';

import '../models/sync_status.dart';
import 'sync_change.dart';

class LocalSyncQueue {
  final List<SyncChange> _pending;
  final void Function(List<SyncChange> changes)? onUploaded;
  final void Function(List<SyncChange> changes)? onChanged;
  final StreamController<List<SyncChange>> _controller =
      StreamController<List<SyncChange>>.broadcast();

  LocalSyncQueue({
    List<SyncChange>? pending,
    this.onUploaded,
    this.onChanged,
  }) : _pending = pending ?? [];

  List<SyncChange> get pending => List.unmodifiable(_pending);

  Stream<List<SyncChange>> watchPending() {
    scheduleMicrotask(_emit);
    return _controller.stream;
  }

  void enqueue(SyncChange change) {
    _pending.add(change);
    _emit();
  }

  void markUploaded(Iterable<String> changeIds) {
    final ids = changeIds.toSet();
    final uploaded = _pending
        .where((change) => ids.contains(change.id))
        .toList(growable: false);
    _pending.removeWhere((change) => ids.contains(change.id));
    if (uploaded.isNotEmpty) {
      onUploaded?.call(uploaded);
    }
    _emit();
  }

  void markSyncing(Iterable<String> changeIds) {
    _updateStatus(
      changeIds,
      status: SyncStatus.syncing,
      reason: SyncStatusReason.syncing,
      lastAttemptAt: DateTime.now(),
    );
  }

  void markFailed(
    Iterable<String> changeIds, {
    required SyncStatusReason reason,
    String? errorCode,
  }) {
    _updateStatus(
      changeIds,
      status: SyncStatus.failed,
      reason: reason,
      lastErrorCode: errorCode,
    );
  }

  void _updateStatus(
    Iterable<String> changeIds, {
    required SyncStatus status,
    required SyncStatusReason reason,
    DateTime? lastAttemptAt,
    String? lastErrorCode,
  }) {
    final ids = changeIds.toSet();
    final changed = <SyncChange>[];
    for (final change in _pending) {
      if (!ids.contains(change.id)) continue;
      change.status = status;
      change.reason = reason;
      if (lastAttemptAt != null) change.lastAttemptAt = lastAttemptAt;
      change.lastErrorCode = lastErrorCode;
      changed.add(change);
    }
    if (changed.isNotEmpty) {
      onChanged?.call(changed);
    }
    _emit();
  }

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(pending);
    }
  }

  void dispose() {
    _controller.close();
  }
}
