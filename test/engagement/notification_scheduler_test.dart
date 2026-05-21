import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/services/notifications/notification_scheduler.dart';
import 'package:expenses_tracker/services/notifications/notification_service.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeNotificationService implements AppNotificationService {
  int? scheduledDailyId;
  int? scheduledWeeklyId;
  final canceledIds = <int>[];

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermissions() async => true;

  @override
  Future<bool> showImmediate({
    required int id,
    required String title,
    required String body,
    required AppNotificationChannel channel,
  }) async {
    return true;
  }

  @override
  Future<bool> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    scheduledDailyId = id;
    return true;
  }

  @override
  Future<bool> scheduleWeekly({
    required int id,
    required String title,
    required String body,
    required int weekday,
    required int hour,
    required int minute,
  }) async {
    scheduledWeeklyId = id;
    return true;
  }

  @override
  Future<void> cancel(int id) async {
    canceledIds.add(id);
  }
}

UserSettings _settings(NotificationSettings notificationSettings) {
  return UserSettings.defaults(
    userId: 'user-1',
    updatedAt: DateTime(2026, 5, 17),
  ).copyWith(notificationSettings: notificationSettings);
}

void main() {
  test('daily check-in schedules when enabled and no expense exists today',
      () async {
    final service = FakeNotificationService();
    final scheduler = NotificationScheduler(notificationService: service);

    await scheduler.syncDailyReminder(
      settings: _settings(
        const NotificationSettings.defaults().copyWith(
          dailyReminderEnabled: true,
        ),
      ),
      expenses: const [],
      now: DateTime(2026, 5, 17),
    );

    expect(
        service.scheduledDailyId, NotificationService.reminderNotificationId);
  });

  test('daily check-in cancels when disabled', () async {
    final service = FakeNotificationService();
    final scheduler = NotificationScheduler(notificationService: service);

    await scheduler.syncDailyReminder(
      settings: _settings(const NotificationSettings.defaults()),
      expenses: const [],
      now: DateTime(2026, 5, 17),
    );

    expect(service.canceledIds,
        contains(NotificationService.reminderNotificationId));
  });

  test('weekly digest schedules and cancels from settings', () async {
    final service = FakeNotificationService();
    final scheduler = NotificationScheduler(notificationService: service);

    await scheduler.syncWeeklyDigest(
      settings: _settings(
        const NotificationSettings.defaults().copyWith(
          weeklyDigestEnabled: true,
        ),
      ),
    );
    await scheduler.syncWeeklyDigest(
      settings: _settings(const NotificationSettings.defaults()),
    );

    expect(
      service.scheduledWeeklyId,
      NotificationService.weeklyDigestNotificationId,
    );
    expect(
      service.canceledIds,
      contains(NotificationService.weeklyDigestNotificationId),
    );
  });
}
