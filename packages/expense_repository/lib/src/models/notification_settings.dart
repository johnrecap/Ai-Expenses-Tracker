class NotificationSettings {
  static const defaultReminderTime = '20:00';
  static const defaultWeeklyDigestTime = '09:00';

  final bool budgetAlertsEnabled;
  final bool dailyReminderEnabled;
  final String reminderTime;
  final bool weeklyDigestEnabled;
  final String weeklyDigestTime;
  final String? lastExceededAlertMonth;

  const NotificationSettings({
    required this.budgetAlertsEnabled,
    required this.dailyReminderEnabled,
    required this.reminderTime,
    required this.weeklyDigestEnabled,
    required this.weeklyDigestTime,
    this.lastExceededAlertMonth,
  });

  const NotificationSettings.defaults()
      : budgetAlertsEnabled = true,
        dailyReminderEnabled = false,
        reminderTime = defaultReminderTime,
        weeklyDigestEnabled = false,
        weeklyDigestTime = defaultWeeklyDigestTime,
        lastExceededAlertMonth = null;

  int get reminderHour => _parseReminderPart(0, 20);

  int get reminderMinute => _parseReminderPart(1, 0);

  int get weeklyDigestHour => _parseWeeklyDigestPart(0, 9);

  int get weeklyDigestMinute => _parseWeeklyDigestPart(1, 0);

  NotificationSettings copyWith({
    bool? budgetAlertsEnabled,
    bool? dailyReminderEnabled,
    String? reminderTime,
    bool? weeklyDigestEnabled,
    String? weeklyDigestTime,
    Object? lastExceededAlertMonth = _sentinel,
  }) {
    return NotificationSettings(
      budgetAlertsEnabled: budgetAlertsEnabled ?? this.budgetAlertsEnabled,
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      weeklyDigestEnabled: weeklyDigestEnabled ?? this.weeklyDigestEnabled,
      weeklyDigestTime: weeklyDigestTime ?? this.weeklyDigestTime,
      lastExceededAlertMonth: identical(lastExceededAlertMonth, _sentinel)
          ? this.lastExceededAlertMonth
          : lastExceededAlertMonth as String?,
    );
  }

  Map<String, Object?> toDocument() {
    return {
      'budgetAlertsEnabled': budgetAlertsEnabled,
      'dailyReminderEnabled': dailyReminderEnabled,
      'reminderTime': reminderTime,
      'weeklyDigestEnabled': weeklyDigestEnabled,
      'weeklyDigestTime': weeklyDigestTime,
      'lastExceededAlertMonth': lastExceededAlertMonth,
    };
  }

  static NotificationSettings fromDocument(Object? value) {
    if (value is! Map) return const NotificationSettings.defaults();

    final parsedReminderTime =
        _normalizeReminderTime(value['reminderTime'] as String?);
    return NotificationSettings(
      budgetAlertsEnabled: value['budgetAlertsEnabled'] as bool? ?? true,
      dailyReminderEnabled: value['dailyReminderEnabled'] as bool? ?? false,
      reminderTime: parsedReminderTime,
      weeklyDigestEnabled: value['weeklyDigestEnabled'] as bool? ?? false,
      weeklyDigestTime: _normalizeReminderTime(
        value['weeklyDigestTime'] as String?,
        fallback: defaultWeeklyDigestTime,
      ),
      lastExceededAlertMonth: value['lastExceededAlertMonth'] as String?,
    );
  }

  static String monthKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    return '${date.year}-$month';
  }

  static String timeString({
    required int hour,
    required int minute,
  }) {
    final normalizedHour = hour.clamp(0, 23).toString().padLeft(2, '0');
    final normalizedMinute = minute.clamp(0, 59).toString().padLeft(2, '0');
    return '$normalizedHour:$normalizedMinute';
  }

  int _parseReminderPart(int index, int fallback) {
    return _parseTimePart(reminderTime, index, fallback);
  }

  int _parseWeeklyDigestPart(int index, int fallback) {
    return _parseTimePart(weeklyDigestTime, index, fallback);
  }

  static int _parseTimePart(String time, int index, int fallback) {
    final parts = time.split(':');
    if (parts.length != 2) return fallback;
    final value = int.tryParse(parts[index]);
    if (value == null) return fallback;
    if (index == 0 && (value < 0 || value > 23)) return fallback;
    if (index == 1 && (value < 0 || value > 59)) return fallback;
    return value;
  }

  static String _normalizeReminderTime(
    String? value, {
    String fallback = defaultReminderTime,
  }) {
    if (value == null) return fallback;
    final parts = value.split(':');
    if (parts.length != 2) return fallback;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return fallback;
    return timeString(hour: hour, minute: minute);
  }
}

const Object _sentinel = Object();
