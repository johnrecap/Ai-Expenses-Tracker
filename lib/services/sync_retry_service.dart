import 'package:expense_repository/expense_repository.dart';

class SyncRetryService {
  final SyncCoordinator coordinator;
  final String deviceId;

  const SyncRetryService({
    required this.coordinator,
    required this.deviceId,
  });

  Future<void> retry() {
    return coordinator.syncNow(deviceId: deviceId);
  }
}
