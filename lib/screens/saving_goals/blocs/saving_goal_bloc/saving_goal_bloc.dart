import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';

part 'saving_goal_event.dart';
part 'saving_goal_state.dart';

class SavingGoalBloc extends Bloc<SavingGoalEvent, SavingGoalState> {
  final SavingGoalRepository _savingGoalRepository;
  StreamSubscription<List<SavingGoal>>? _subscription;

  SavingGoalBloc(this._savingGoalRepository) : super(SavingGoalInitial()) {
    on<SavingGoalsWatchRequested>(_onWatchRequested);
    on<SavingGoalsUpdated>(_onUpdated);
    on<SavingGoalCreateRequested>(_onCreateRequested);
    on<SavingGoalUpdateRequested>(_onUpdateRequested);
    on<SavingGoalArchiveRequested>(_onArchiveRequested);
    on<SavingGoalContributionRequested>(_onContributionRequested);
  }

  Future<void> _onWatchRequested(
    SavingGoalsWatchRequested event,
    Emitter<SavingGoalState> emit,
  ) async {
    emit(SavingGoalLoading());
    await _subscription?.cancel();
    _subscription = _savingGoalRepository
        .watchSavingGoals(includeArchived: event.includeArchived)
        .listen(
          (goals) => add(SavingGoalsUpdated(goals)),
          onError: (_) => add(
            const SavingGoalsUpdated(
              [],
              message: 'Failed to load saving goals.',
            ),
          ),
        );
  }

  void _onUpdated(
    SavingGoalsUpdated event,
    Emitter<SavingGoalState> emit,
  ) {
    if (event.message != null) {
      emit(SavingGoalFailure(event.message!));
      return;
    }
    emit(SavingGoalSuccess(event.goals));
  }

  Future<void> _onCreateRequested(
    SavingGoalCreateRequested event,
    Emitter<SavingGoalState> emit,
  ) async {
    final validationMessage = _validationMessage(event.goal);
    if (validationMessage != null) {
      emit(SavingGoalFailure(validationMessage));
      return;
    }

    emit(SavingGoalSaving());
    try {
      await _savingGoalRepository.createSavingGoal(event.goal);
      emit(const SavingGoalActionSuccess('Saving goal created.'));
      add(const SavingGoalsWatchRequested());
    } catch (_) {
      emit(const SavingGoalFailure('Failed to create saving goal.'));
    }
  }

  Future<void> _onUpdateRequested(
    SavingGoalUpdateRequested event,
    Emitter<SavingGoalState> emit,
  ) async {
    final validationMessage = _validationMessage(event.goal);
    if (event.goal.goalId.isEmpty || validationMessage != null) {
      emit(SavingGoalFailure(
        validationMessage ?? 'Select a saving goal to update.',
      ));
      return;
    }

    emit(SavingGoalSaving());
    try {
      await _savingGoalRepository.updateSavingGoal(event.goal);
      emit(const SavingGoalActionSuccess('Saving goal updated.'));
      add(const SavingGoalsWatchRequested());
    } catch (_) {
      emit(const SavingGoalFailure('Failed to update saving goal.'));
    }
  }

  Future<void> _onArchiveRequested(
    SavingGoalArchiveRequested event,
    Emitter<SavingGoalState> emit,
  ) async {
    if (event.goal.goalId.isEmpty) {
      emit(const SavingGoalFailure('Select a saving goal to archive.'));
      return;
    }

    emit(SavingGoalSaving());
    try {
      await _savingGoalRepository.archiveSavingGoal(event.goal.goalId);
      emit(const SavingGoalActionSuccess('Saving goal archived.'));
      add(const SavingGoalsWatchRequested());
    } catch (_) {
      emit(const SavingGoalFailure('Failed to archive saving goal.'));
    }
  }

  Future<void> _onContributionRequested(
    SavingGoalContributionRequested event,
    Emitter<SavingGoalState> emit,
  ) async {
    if (event.goal.goalId.isEmpty) {
      emit(const SavingGoalFailure('Select a saving goal to update.'));
      return;
    }
    if (event.amount <= 0) {
      emit(const SavingGoalFailure('Enter a positive contribution amount.'));
      return;
    }

    emit(SavingGoalSaving());
    try {
      await _savingGoalRepository.contributeToSavingGoal(
        goalId: event.goal.goalId,
        amount: event.amount,
      );
      emit(const SavingGoalActionSuccess('Contribution added.'));
      add(const SavingGoalsWatchRequested());
    } catch (_) {
      emit(const SavingGoalFailure('Failed to add contribution.'));
    }
  }

  String? _validationMessage(SavingGoal goal) {
    if (goal.name.trim().isEmpty) return 'Enter a goal name.';
    if (goal.targetAmount <= 0) return 'Enter a positive target amount.';
    if (goal.currentAmount < 0) return 'Current amount cannot be negative.';
    if (goal.currency.trim().isEmpty) return 'Select a currency.';
    return null;
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
