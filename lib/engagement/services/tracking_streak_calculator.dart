import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/engagement/models/tracking_streak.dart';

class TrackingStreakCalculator {
  const TrackingStreakCalculator();

  TrackingStreak calculate({
    required List<Expense> expenses,
    DateTime? now,
  }) {
    final reference = _dateOnly(now ?? DateTime.now());
    final trackedDays = expenses
        .map((expense) => _dateOnly(expense.date))
        .where((date) => !date.isAfter(reference))
        .toSet();

    if (trackedDays.isEmpty) {
      return TrackingStreak(
        currentStreakDays: 0,
        hasTrackedToday: false,
        referenceDate: reference,
      );
    }

    final hasTrackedToday = trackedDays.contains(reference);
    var cursor = hasTrackedToday
        ? reference
        : reference.subtract(const Duration(days: 1));
    var streak = 0;

    while (trackedDays.contains(cursor)) {
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    final lastTrackedDate = trackedDays.reduce(
      (latest, date) => date.isAfter(latest) ? date : latest,
    );

    return TrackingStreak(
      currentStreakDays: streak,
      hasTrackedToday: hasTrackedToday,
      referenceDate: reference,
      lastTrackedDate: lastTrackedDate,
    );
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
