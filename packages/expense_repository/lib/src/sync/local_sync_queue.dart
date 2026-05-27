import 'dart:async';

import 'sync_change.dart';

class LocalSyncQueue {
  final List<SyncChange> _pending;
  final StreamController<List<SyncChange>> _controller =
      StreamController<List<SyncChange>>.broadcast();

  LocalSyncQueue({
    List<SyncChange>? pending,
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
    _pending.removeWhere((change) => ids.contains(change.id));
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
