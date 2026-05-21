part of 'recurring_expense_bloc.dart';

sealed class RecurringExpenseEvent extends Equatable {
  const RecurringExpenseEvent();

  @override
  List<Object?> get props => [];
}

class RecurringExpensesWatchRequested extends RecurringExpenseEvent {
  final bool includeArchived;

  const RecurringExpensesWatchRequested({this.includeArchived = false});

  @override
  List<Object?> get props => [includeArchived];
}

class RecurringExpensesUpdated extends RecurringExpenseEvent {
  final List<RecurringExpense> rules;
  final String? message;

  const RecurringExpensesUpdated(this.rules, {this.message});

  @override
  List<Object?> get props => [rules, message];
}

class RecurringExpenseCreateRequested extends RecurringExpenseEvent {
  final RecurringExpense rule;

  const RecurringExpenseCreateRequested(this.rule);

  @override
  List<Object?> get props => [rule];
}

class RecurringExpenseUpdateRequested extends RecurringExpenseEvent {
  final RecurringExpense rule;

  const RecurringExpenseUpdateRequested(this.rule);

  @override
  List<Object?> get props => [rule];
}

class RecurringExpenseArchiveRequested extends RecurringExpenseEvent {
  final RecurringExpense rule;

  const RecurringExpenseArchiveRequested(this.rule);

  @override
  List<Object?> get props => [rule];
}
