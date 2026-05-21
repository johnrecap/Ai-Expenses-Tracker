import 'package:expense_repository/expense_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('notification settings preserve backward-compatible defaults', () {
    final settings = NotificationSettings.fromDocument(const {
      'dailyReminderEnabled': true,
      'reminderTime': '7:05',
    });

    expect(settings.dailyReminderEnabled, isTrue);
    expect(settings.reminderTime, '07:05');
    expect(settings.weeklyDigestEnabled, isFalse);
    expect(settings.weeklyDigestTime,
        NotificationSettings.defaultWeeklyDigestTime);
  });

  test('notification settings serialize weekly digest preference', () {
    final settings = const NotificationSettings.defaults().copyWith(
      weeklyDigestEnabled: true,
      weeklyDigestTime: '10:30',
    );

    final document = settings.toDocument();

    expect(document['weeklyDigestEnabled'], isTrue);
    expect(document['weeklyDigestTime'], '10:30');
  });
}
