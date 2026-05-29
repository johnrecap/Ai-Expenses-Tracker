import 'package:http/http.dart' as http;

import '../api/vps_api_client.dart';
import '../models/sync_status.dart';
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
    final pendingIds = pending.map((change) => change.id).toList();
    queue.markSyncing(pendingIds);

    final Map<String, Object?> response;
    try {
      response = await apiClient.postJson('/v1/sync/push', {
        'deviceId': deviceId,
        'changes': pending.map(_changeToEnvelope).toList(growable: false),
      });
    } catch (error) {
      queue.markFailed(
        pendingIds,
        reason: _reasonForError(error),
        errorCode: error is VpsApiException ? error.code : null,
      );
      rethrow;
    }
    final acceptedEntries = (response['accepted'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .toList(growable: false);
    final acceptedChangeIds = acceptedEntries
        .map((entry) => entry['clientChangeId']?.toString())
        .whereType<String>()
        .toSet();
    final acceptedEntityFallbacks = acceptedEntries
        .where((entry) => entry['clientChangeId'] == null)
        .map((entry) => entry['entityId']?.toString())
        .whereType<String>()
        .toSet();
    final accepted = pending
        .where(
          (change) =>
              acceptedChangeIds.contains(change.id) ||
              acceptedEntityFallbacks.contains(change.entityId),
        )
        .map((change) => change.id)
        .toList(growable: false);
    final rejectedEntries = (response['rejected'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .toList(growable: false);
    final rejectedChangeIds = rejectedEntries
        .map((entry) => entry['clientChangeId']?.toString())
        .whereType<String>()
        .toSet();
    final rejectedEntityFallbacks = rejectedEntries
        .where((entry) => entry['clientChangeId'] == null)
        .map((entry) => entry['entityId']?.toString())
        .whereType<String>()
        .toSet();
    final rejected = pending
        .where(
          (change) =>
              rejectedChangeIds.contains(change.id) ||
              rejectedEntityFallbacks.contains(change.entityId),
        )
        .map((change) => change.id)
        .toList(growable: false);
    queue.markUploaded(accepted);
    if (rejected.isNotEmpty) {
      queue.markFailed(
        rejected,
        reason: SyncStatusReason.validation,
        errorCode: 'sync/rejected',
      );
    }
    final settled = {...accepted, ...rejected};
    final unacknowledged =
        pendingIds.where((changeId) => !settled.contains(changeId)).toList();
    if (unacknowledged.isNotEmpty) {
      queue.markFailed(
        unacknowledged,
        reason: SyncStatusReason.server,
        errorCode: 'sync/unacknowledged',
      );
    }
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
      'clientChangeId': change.id,
      'operation': change.operation.name,
      'data': change.data,
      'clientUpdatedAt': change.clientUpdatedAt.toIso8601String(),
      if (change.baseRevision != null) 'baseRevision': change.baseRevision,
    };
  }

  SyncStatusReason _reasonForError(Object error) {
    if (error is VpsApiException) {
      final statusCode = error.statusCode;
      if (statusCode == 401 || statusCode == 403 || error.code.startsWith('auth/')) {
        return SyncStatusReason.auth;
      }
      if (statusCode == 400 || statusCode == 409 || statusCode == 422) {
        return SyncStatusReason.validation;
      }
      if (statusCode != null && statusCode >= 500) {
        return SyncStatusReason.server;
      }
      return error.retryable ? SyncStatusReason.server : SyncStatusReason.unknown;
    }
    if (error is http.ClientException) {
      return SyncStatusReason.offline;
    }
    return SyncStatusReason.unknown;
  }
}
