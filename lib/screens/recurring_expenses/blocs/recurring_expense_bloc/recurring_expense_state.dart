part of 'recurring_expense_bloc.dart';

sealed class RecurringExpenseState extends Equatable {
  const RecurringExpenseState();

  @override
  List<Object?> get props => [];
}

final class RecurringExpenseInitial extends RecurringExpenseState {}

final class RecurringExpenseLoading extends RecurringExpenseState {}

final class RecurringExpenseSaving extends RecurringExpenseState {}

final class RecurringExpenseSuccess extends RecurringExpenseState {
  final List<RecurringExpense> rules;

  const RecurringExpenseSuccess(this.rules);

  @override
  List<Object?> get props => [rules];
}

final class RecurringExpenseActionSuccess extends RecurringExpenseState {
  final String message;

  const RecurringExpenseActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

final class RecurringExpenseFailure extends RecurringExpenseState {
  final String message;

  const RecurringExpenseFailure(this.message);

  @override
  List<Object?> get props => [message];
}
