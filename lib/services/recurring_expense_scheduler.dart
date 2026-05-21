import 'package:expense_repository/expense_repository.dart';

class RecurringExpenseScheduler {
  final ExpenseRepository _expenseRepository;
  final RecurringExpenseRepository _recurringExpenseRepository;

  const RecurringExpenseScheduler({
    required ExpenseRepository expenseRepository,
    required RecurringExpenseRepository recurringExpenseRepository,
  })  : _expenseRepository = expenseRepository,
        _recurringExpenseRepository = recurringExpenseRepository;

  static String generatedExpenseId({
    required String recurringExpenseId,
    required DateTime scheduledDate,
  }) {
    final normalizedDate = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
    );
    final dateKey = [
      normalizedDate.year.toString().padLeft(4, '0'),
      normalizedDate.month.toString().padLeft(2, '0'),
      normalizedDate.day.toString().padLeft(2, '0'),
    ].join();
    return '${recurringExpenseId}_$dateKey';
  }

  static List<DateTime> dueOccurrences(
    RecurringExpense rule,
    DateTime now,
  ) {
    if (!rule.isActive || rule.isArchived || rule.nextRunDate.isAfter(now)) {
      return const [];
    }

    final occurrences = <DateTime>[];
    var scheduledDate = rule.nextRunDate;

    while (!scheduledDate.isAfter(now)) {
      if (_isAfterEndDate(scheduledDate, rule.endDate)) break;
      occurrences.add(scheduledDate);
      scheduledDate = nextRunAfterOccurrence(rule, scheduledDate);
    }

    return occurrences;
  }

  static DateTime nextRunAfterOccurrence(
    RecurringExpense rule,
    DateTime occurrence,
  ) {
    switch (rule.frequency) {
      case RecurringFrequency.daily:
        return occurrence.add(const Duration(days: 1));
      case RecurringFrequency.weekly:
        return occurrence.add(const Duration(days: 7));
      case RecurringFrequency.monthly:
        return _addOneMonthClamped(
          occurrence,
          anchorDay: rule.startDate.day,
        );
    }
  }

  static DateTime? nextRunAfterProcessing(
    RecurringExpense rule,
    DateTime now,
  ) {
    var nextRunDate = rule.nextRunDate;
    while (!nextRunDate.isAfter(now)) {
      if (_isAfterEndDate(nextRunDate, rule.endDate)) return null;
      nextRunDate = nextRunAfterOccurrence(rule, nextRunDate);
    }
    if (_isAfterEndDate(nextRunDate, rule.endDate)) return null;
    return nextRunDate;
  }

  static Expense expenseForOccurrence(
    RecurringExpense rule,
    DateTime scheduledDate,
  ) {
    final normalizedDate = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
    );
    return Expense(
      expenseId: generatedExpenseId(
        recurringExpenseId: rule.recurringExpenseId,
        scheduledDate: normalizedDate,
      ),
      userId: rule.userId,
      category: rule.category,
      categoryId: rule.categoryId,
      categoryName: rule.categoryName,
      categoryIcon: rule.categoryIcon,
      categoryColor: rule.categoryColor,
      date: normalizedDate,
      amount: rule.amount,
      description: rule.description,
      paymentMethod: rule.paymentMethod,
      currency: rule.currency,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      source: ExpenseSource.recurring,
      recurringExpenseId: rule.recurringExpenseId,
    );
  }

  Future<int> processDueRecurringExpenses({DateTime? now}) async {
    final effectiveNow = now ?? DateTime.now();
    final dueRules = await _recurringExpenseRepository.getDueRecurringExpenses(
      effectiveNow,
    );
    var generatedCount = 0;

    for (final rule in dueRules) {
      final occurrences = dueOccurrences(rule, effectiveNow);
      for (final occurrence in occurrences) {
        await _expenseRepository.createExpense(
          expenseForOccurrence(rule, occurrence),
        );
        generatedCount++;
      }

      final nextRunDate = nextRunAfterProcessing(rule, effectiveNow);
      await _recurringExpenseRepository.updateRecurringExpense(
        rule.copyWith(
          nextRunDate: nextRunDate ?? rule.nextRunDate,
          isActive: nextRunDate != null,
        ),
      );
    }

    return generatedCount;
  }

  static bool _isAfterEndDate(DateTime scheduledDate, DateTime? endDate) {
    if (endDate == null) return false;
    final normalizedScheduled = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
    );
    final normalizedEnd = DateTime(endDate.year, endDate.month, endDate.day);
    return normalizedScheduled.isAfter(normalizedEnd);
  }

  static DateTime _addOneMonthClamped(
    DateTime date, {
    required int anchorDay,
  }) {
    final nextMonthBase = DateTime(date.year, date.month + 1);
    final lastDayOfTargetMonth = DateTime(
      nextMonthBase.year,
      nextMonthBase.month + 1,
      0,
    ).day;
    final clampedDay = anchorDay.clamp(1, lastDayOfTargetMonth);
    return DateTime(
      nextMonthBase.year,
      nextMonthBase.month,
      clampedDay,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    );
  }
}
