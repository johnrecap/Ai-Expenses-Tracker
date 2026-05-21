import 'package:expense_repository/expense_repository.dart';

abstract class RecurringExpenseRepository {
  Future<void> createRecurringExpense(RecurringExpense recurringExpense);
  Future<void> updateRecurringExpense(RecurringExpense recurringExpense);
  Future<void> archiveRecurringExpense(String recurringExpenseId);
  Future<List<RecurringExpense>> getDueRecurringExpenses(DateTime now);
  Stream<List<RecurringExpense>> watchRecurringExpenses({
    bool includeArchived = false,
  });
}
