part of 'budget_bloc.dart';

sealed class BudgetState extends Equatable {
  const BudgetState();

  @override
  List<Object?> get props => [];
}

final class BudgetInitial extends BudgetState {}

final class BudgetLoading extends BudgetState {}

final class BudgetSaving extends BudgetState {
  final Budget budget;

  const BudgetSaving(this.budget);

  @override
  List<Object?> get props => [budget.budgetId, budget.amount];
}

final class BudgetLoaded extends BudgetState {
  final Budget? budget;

  const BudgetLoaded(this.budget);

  @override
  List<Object?> get props => [budget?.budgetId, budget?.amount];
}

final class BudgetSaved extends BudgetState {
  final Budget budget;

  const BudgetSaved(this.budget);

  @override
  List<Object?> get props => [budget.budgetId, budget.amount];
}

final class BudgetFailure extends BudgetState {
  final String message;

  const BudgetFailure(this.message);

  @override
  List<Object?> get props => [message];
}
