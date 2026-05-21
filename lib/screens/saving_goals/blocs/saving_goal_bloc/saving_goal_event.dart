part of 'saving_goal_bloc.dart';

sealed class SavingGoalEvent extends Equatable {
  const SavingGoalEvent();

  @override
  List<Object?> get props => [];
}

class SavingGoalsWatchRequested extends SavingGoalEvent {
  final bool includeArchived;

  const SavingGoalsWatchRequested({this.includeArchived = false});

  @override
  List<Object?> get props => [includeArchived];
}

class SavingGoalsUpdated extends SavingGoalEvent {
  final List<SavingGoal> goals;
  final String? message;

  const SavingGoalsUpdated(this.goals, {this.message});

  @override
  List<Object?> get props => [goals, message];
}

class SavingGoalCreateRequested extends SavingGoalEvent {
  final SavingGoal goal;

  const SavingGoalCreateRequested(this.goal);

  @override
  List<Object?> get props => [goal];
}

class SavingGoalUpdateRequested extends SavingGoalEvent {
  final SavingGoal goal;

  const SavingGoalUpdateRequested(this.goal);

  @override
  List<Object?> get props => [goal];
}

class SavingGoalArchiveRequested extends SavingGoalEvent {
  final SavingGoal goal;

  const SavingGoalArchiveRequested(this.goal);

  @override
  List<Object?> get props => [goal];
}

class SavingGoalContributionRequested extends SavingGoalEvent {
  final SavingGoal goal;
  final double amount;

  const SavingGoalContributionRequested({
    required this.goal,
    required this.amount,
  });

  @override
  List<Object?> get props => [goal, amount];
}
