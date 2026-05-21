import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

enum AppNotificationChannel {
  budget,
  reminder,
}

abstract class AppNotificationService {
  Future<void> initialize();

  Future<bool> requestPermissions();

  Future<bool> showImmediate({
    required int id,
    required String title,
    required String body,
    required AppNotificationChannel channel,
  });

  Future<bool> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  });

  Future<bool> scheduleWeekly({
    required int id,
    required String title,
    required String body,
    required int weekday,
    required int hour,
    required int minute,
  });

  Future<void> cancel(int id);
}

class NotificationService implements AppNotificationService {
  NotificationService._({
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static final NotificationService instance = NotificationService._();

  static const budgetChannelId = 'budget_alerts';
  static const reminderChannelId = 'expense_reminders';
  static const budgetNotificationId = 1001;
  static const reminderNotificationId = 2001;
  static const weeklyDigestNotificationId = 2002;

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
      linux: LinuxInitializationSettings(defaultActionName: 'Open'),
    );

    await _plugin.initialize(initializationSettings);
    await _createAndroidChannels();
    _initialized = true;
  }

  @override
  Future<bool> requestPermissions() async {
    await initialize();

    if (kIsWeb) return false;

    if (defaultTargetPlatform == TargetPlatform.android) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.requestNotificationsPermission() ??
          true;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
              ) ??
          false;
    }

    if (defaultTargetPlatform == TargetPlatform.macOS) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                  MacOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
              ) ??
          false;
    }

    return true;
  }

  @override
  Future<bool> showImmediate({
    required int id,
    required String title,
    required String body,
    required AppNotificationChannel channel,
  }) async {
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.windows) {
      return false;
    }

    final allowed = await requestPermissions();
    if (!allowed) return false;

    await _plugin.show(
      id,
      title,
      body,
      _notificationDetails(channel),
    );
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
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS &&
            defaultTargetPlatform != TargetPlatform.macOS)) {
      return false;
    }

    final allowed = await requestPermissions();
    if (!allowed) return false;

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      _nextDailyOccurrence(hour: hour, minute: minute),
      _notificationDetails(AppNotificationChannel.reminder),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
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
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS &&
            defaultTargetPlatform != TargetPlatform.macOS)) {
      return false;
    }

    final allowed = await requestPermissions();
    if (!allowed) return false;

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      _nextWeeklyOccurrence(
        weekday: weekday,
        hour: hour,
        minute: minute,
      ),
      _notificationDetails(AppNotificationChannel.reminder),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
    return true;
  }

  @override
  Future<void> cancel(int id) async {
    await initialize();
    await _plugin.cancel(id);
  }

  Future<void> _createAndroidChannels() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_budgetChannel);
    await androidPlugin?.createNotificationChannel(_reminderChannel);
  }

  NotificationDetails _notificationDetails(AppNotificationChannel channel) {
    final androidDetails = switch (channel) {
      AppNotificationChannel.budget => const AndroidNotificationDetails(
          budgetChannelId,
          'Budget alerts',
          channelDescription: 'Warnings when spending nears or exceeds budget.',
          importance: Importance.high,
          priority: Priority.high,
        ),
      AppNotificationChannel.reminder => const AndroidNotificationDetails(
          reminderChannelId,
          'Expense reminders',
          channelDescription: 'Daily reminders to log expenses.',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
    };

    return NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(),
      macOS: const DarwinNotificationDetails(),
      linux: const LinuxNotificationDetails(),
    );
  }

  tz.TZDateTime _nextDailyOccurrence({
    required int hour,
    required int minute,
  }) {
    final now = DateTime.now();
    var scheduled = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return tz.TZDateTime.from(scheduled, tz.local);
  }

  tz.TZDateTime _nextWeeklyOccurrence({
    required int weekday,
    required int hour,
    required int minute,
  }) {
    final now = DateTime.now();
    var scheduled = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    final daysUntilTarget = (weekday - scheduled.weekday) % 7;
    scheduled = scheduled.add(Duration(days: daysUntilTarget));
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 7));
    }

    return tz.TZDateTime.from(scheduled, tz.local);
  }

  static const _budgetChannel = AndroidNotificationChannel(
    budgetChannelId,
    'Budget alerts',
    description: 'Warnings when spending nears or exceeds budget.',
    importance: Importance.high,
  );

  static const _reminderChannel = AndroidNotificationChannel(
    reminderChannelId,
    'Expense reminders',
    description: 'Daily reminders to log expenses.',
    importance: Importance.defaultImportance,
  );
}
