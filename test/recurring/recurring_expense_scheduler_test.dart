import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/services/recurring_expense_scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RecurringExpenseScheduler', () {
    test('generates missed daily occurrences through today', () {
      final rule = _rule(
        frequency: RecurringFrequency.daily,
        startDate: DateTime(2026, 5, 10),
        nextRunDate: DateTime(2026, 5, 13),
      );

      final occurrences = RecurringExpenseScheduler.dueOccurrences(
        rule,
        DateTime(2026, 5, 15, 10),
      );

      expect(occurrences, [
        DateTime(2026, 5, 13),
        DateTime(2026, 5, 14),
        DateTime(2026, 5, 15),
      ]);
    });

    test('generates missed weekly occurrences on the same weekday', () {
      final rule = _rule(
        frequency: RecurringFrequency.weekly,
        startDate: DateTime(2026, 5, 1),
        nextRunDate: DateTime(2026, 5, 1),
      );

      final occurrences = RecurringExpenseScheduler.dueOccurrences(
        rule,
        DateTime(2026, 5, 15),
      );

      expect(occurrences, [
        DateTime(2026, 5, 1),
        DateTime(2026, 5, 8),
        DateTime(2026, 5, 15),
      ]);
    });

    test('clamps monthly 31st to February then returns to 31st', () {
      final rule = _rule(
        frequency: RecurringFrequency.monthly,
        startDate: DateTime(2026, 1, 31),
        nextRunDate: DateTime(2026, 1, 31),
      );

      final february = RecurringExpenseScheduler.nextRunAfterOccurrence(
        rule,
        DateTime(2026, 1, 31),
      );
      final march = RecurringExpenseScheduler.nextRunAfterOccurrence(
        rule,
        february,
      );

      expect(february, DateTime(2026, 2, 28));
      expect(march, DateTime(2026, 3, 31));
    });

    test('stops at end date', () {
      final rule = _rule(
        frequency: RecurringFrequency.daily,
        startDate: DateTime(2026, 5, 10),
        nextRunDate: DateTime(2026, 5, 10),
        endDate: DateTime(2026, 5, 11),
      );

      final occurrences = RecurringExpenseScheduler.dueOccurrences(
        rule,
        DateTime(2026, 5, 13),
      );

      expect(occurrences, [
        DateTime(2026, 5, 10),
        DateTime(2026, 5, 11),
      ]);
      expect(
        RecurringExpenseScheduler.nextRunAfterProcessing(
          rule,
          DateTime(2026, 5, 13),
        ),
        isNull,
      );
    });

    test('uses deterministic generated ids and recurring metadata', () {
      final rule = _rule(
        recurringExpenseId: 'rent-rule',
        frequency: RecurringFrequency.monthly,
        startDate: DateTime(2026, 5, 1),
        nextRunDate: DateTime(2026, 5, 1),
      );

      final first = RecurringExpenseScheduler.expenseForOccurrence(
        rule,
        DateTime(2026, 5, 1),
      );
      final second = RecurringExpenseScheduler.expenseForOccurrence(
        rule,
        DateTime(2026, 5, 1),
      );

      expect(first.expenseId, second.expenseId);
      expect(first.expenseId, 'rent-rule_20260501');
      expect(first.source, ExpenseSource.recurring);
      expect(first.recurringExpenseId, 'rent-rule');
    });
  });
}

RecurringExpense _rule({
  String recurringExpenseId = 'rule-1',
  required RecurringFrequency frequency,
  required DateTime startDate,
  required DateTime nextRunDate,
  DateTime? endDate,
}) {
  final category = Category(
    categoryId: 'category-1',
    name: 'Bills',
    totalExpenses: 0,
    icon: 'home',
    color: 0xff0000ff,
  );
  return RecurringExpense(
    recurringExpenseId: recurringExpenseId,
    userId: 'user-1',
    amount: 500,
    category: category,
    description: 'Recurring bill',
    paymentMethod: PaymentMethod.cash,
    currency: 'EGP',
    startDate: startDate,
    nextRunDate: nextRunDate,
    endDate: endDate,
    frequency: frequency,
    createdAt: startDate,
    updatedAt: startDate,
  );
}
