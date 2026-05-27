import '../api/vps_api_client.dart';
import 'local_sync_queue.dart';
import 'sync_change.dart';
import 'sync_cursor.dart';

class SyncCoordinator {
  final VpsApiClient apiClient;
  final LocalSyncQueue queue;
  SyncCursor cursor;

  SyncCoordinator({
    required this.apiClient,
    required this.queue,
    SyncCursor? cursor,
  }) : cursor = cursor ?? SyncCursor.empty();

  Future<void> pushPending({
    required String deviceId,
  }) async {
    final pending = queue.pending;
    if (pending.isEmpty) return;

    final response = await apiClient.postJson('/v1/sync/push', {
      'deviceId': deviceId,
      'changes': pending.map(_changeToEnvelope).toList(growable: false),
    });
    final accepted = (response['accepted'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((entry) => entry['entityId']?.toString())
        .whereType<String>()
        .toSet();
    queue.markUploaded(
      pending
          .where((change) => accepted.contains(change.entityId))
          .map((change) => change.id),
    );
    cursor = SyncCursor(
      value: response['nextCursor']?.toString() ?? cursor.value,
      updatedAt: DateTime.now(),
    );
  }

  Future<List<Map<String, Object?>>> syncNow({
    required String deviceId,
    int limit = 500,
  }) async {
    await pushPending(deviceId: deviceId);
    return pullChanges(limit: limit);
  }

  Future<List<Map<String, Object?>>> pullChanges({
    int limit = 500,
  }) async {
    final path = '/v1/sync/pull?cursor=${cursor.value ?? '0'}&limit=$limit';
    final response = await apiClient.getJson(path);
    cursor = SyncCursor(
      value: response['nextCursor']?.toString() ?? cursor.value,
      updatedAt: DateTime.now(),
    );
    return (response['changes'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((entry) => Map<String, Object?>.from(entry))
        .toList(growable: false);
  }

  Map<String, Object?> _changeToEnvelope(SyncChange change) {
    return {
      'entityType': change.entityType.name,
      'entityId': change.entityId,
      'operation': change.operation.name,
      'data': change.data,
      'clientUpdatedAt': change.clientUpdatedAt.toIso8601String(),
      if (change.baseRevision != null) 'baseRevision': change.baseRevision,
    };
  }
}
