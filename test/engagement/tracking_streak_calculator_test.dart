import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/engagement/engagement.dart';
import 'package:flutter_test/flutter_test.dart';

Expense _expense(String id, DateTime date) {
  return Expense(
    expenseId: id,
    category: Category.empty,
    date: date,
    amount: 100,
  );
}

void main() {
  const calculator = TrackingStreakCalculator();

  test('counts consecutive tracked days including today', () {
    final streak = calculator.calculate(
      expenses: [
        _expense('1', DateTime(2026, 5, 17, 9)),
        _expense('2', DateTime(2026, 5, 16, 12)),
        _expense('3', DateTime(2026, 5, 15, 18)),
      ],
      now: DateTime(2026, 5, 17, 22),
    );

    expect(streak.currentStreakDays, 3);
    expect(streak.hasTrackedToday, isTrue);
  });

  test('uses yesterday as active streak when today has no expense', () {
    final streak = calculator.calculate(
      expenses: [
        _expense('1', DateTime(2026, 5, 16)),
        _expense('2', DateTime(2026, 5, 15)),
      ],
      now: DateTime(2026, 5, 17),
    );

    expect(streak.currentStreakDays, 2);
    expect(streak.hasTrackedToday, isFalse);
  });

  test('missing yesterday breaks streak', () {
    final streak = calculator.calculate(
      expenses: [
        _expense('1', DateTime(2026, 5, 17)),
        _expense('2', DateTime(2026, 5, 15)),
      ],
      now: DateTime(2026, 5, 17),
    );

    expect(streak.currentStreakDays, 1);
  });

  test('multiple expenses on the same day count once', () {
    final streak = calculator.calculate(
      expenses: [
        _expense('1', DateTime(2026, 5, 17, 9)),
        _expense('2', DateTime(2026, 5, 17, 21)),
      ],
      now: DateTime(2026, 5, 17),
    );

    expect(streak.currentStreakDays, 1);
  });
}
