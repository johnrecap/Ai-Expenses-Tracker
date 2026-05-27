import 'package:expense_repository/expense_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('SyncCoordinator', () {
    test('pushes pending changes and clears accepted local queue entries',
        () async {
      final queue = LocalSyncQueue(
        pending: [
          SyncChange(
            id: 'change-1',
            userId: 'user-1',
            entityType: SyncEntityType.expense,
            entityId: 'expense-1',
            operation: SyncOperation.upsert,
            data: const {'amount': 100},
            clientUpdatedAt: DateTime.utc(2026, 5, 26, 10),
          ),
        ],
      );
      final client = VpsApiClient(
        baseUri: Uri.parse('https://api.saeeddev.com/'),
        tokenProvider: () async => 'token',
        client: MockClient((request) async {
          if (request.url.path == '/v1/sync/push') {
            return http.Response(
              '{"accepted":[{"entityType":"expense","entityId":"expense-1","serverRevision":1}],"rejected":[],"nextCursor":"1"}',
              200,
            );
          }
          return http.Response(
            '{"changes":[],"nextCursor":"1","hasMore":false}',
            200,
          );
        }),
      );
      final coordinator = SyncCoordinator(apiClient: client, queue: queue);

      await coordinator.syncNow(deviceId: 'device-1');

      expect(queue.pending, isEmpty);
      expect(coordinator.cursor.value, '1');
    });

    test('keeps pending changes when push fails', () async {
      final queue = LocalSyncQueue(
        pending: [
          SyncChange(
            id: 'change-1',
            userId: 'user-1',
            entityType: SyncEntityType.expense,
            entityId: 'expense-1',
            operation: SyncOperation.upsert,
            data: const {'amount': 100},
            clientUpdatedAt: DateTime.utc(2026, 5, 26, 10),
          ),
        ],
      );
      final client = VpsApiClient(
        baseUri: Uri.parse('https://api.saeeddev.com/'),
        tokenProvider: () async => 'token',
        client: MockClient(
          (_) async => http.Response(
            '{"code":"sync/unavailable","message":"Try again","retryable":true}',
            503,
          ),
        ),
      );
      final coordinator = SyncCoordinator(apiClient: client, queue: queue);

      await expect(
        () => coordinator.syncNow(deviceId: 'device-1'),
        throwsA(isA<VpsApiException>()),
      );
      expect(queue.pending, hasLength(1));
    });
  });
}
