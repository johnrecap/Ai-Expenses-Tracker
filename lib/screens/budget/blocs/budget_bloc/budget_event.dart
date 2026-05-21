part of 'budget_bloc.dart';

sealed class BudgetEvent extends Equatable {
  const BudgetEvent();

  @override
  List<Object?> get props => [];
}

class BudgetLoadRequested extends BudgetEvent {
  final int month;
  final int year;

  const BudgetLoadRequested({
    required this.month,
    required this.year,
  });

  @override
  List<Object?> get props => [month, year];
}

class BudgetWatchRequested extends BudgetEvent {
  final int month;
  final int year;

  const BudgetWatchRequested({
    required this.month,
    required this.year,
  });

  @override
  List<Object?> get props => [month, year];
}

class BudgetUpdated extends BudgetEvent {
  final Budget? budget;
  final String? message;

  const BudgetUpdated(this.budget, {this.message});

  @override
  List<Object?> get props => [budget?.budgetId, message];
}

class BudgetSaveRequested extends BudgetEvent {
  final Budget budget;

  const BudgetSaveRequested(this.budget);

  @override
  List<Object?> get props => [budget.budgetId, budget.amount];
}
