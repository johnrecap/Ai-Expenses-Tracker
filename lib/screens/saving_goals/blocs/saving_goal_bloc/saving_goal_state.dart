part of 'saving_goal_bloc.dart';

sealed class SavingGoalState extends Equatable {
  const SavingGoalState();

  @override
  List<Object?> get props => [];
}

final class SavingGoalInitial extends SavingGoalState {}

final class SavingGoalLoading extends SavingGoalState {}

final class SavingGoalSaving extends SavingGoalState {}

final class SavingGoalSuccess extends SavingGoalState {
  final List<SavingGoal> goals;

  const SavingGoalSuccess(this.goals);

  @override
  List<Object?> get props => [goals];
}

final class SavingGoalActionSuccess extends SavingGoalState {
  final String message;

  const SavingGoalActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

final class SavingGoalFailure extends SavingGoalState {
  final String message;

  const SavingGoalFailure(this.message);

  @override
  List<Object?> get props => [message];
}
