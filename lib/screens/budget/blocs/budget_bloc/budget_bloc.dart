import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';

part 'budget_event.dart';
part 'budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final BudgetRepository _budgetRepository;
  StreamSubscription<Budget?>? _budgetSubscription;

  BudgetBloc(this._budgetRepository) : super(BudgetInitial()) {
    on<BudgetLoadRequested>(_onLoadRequested);
    on<BudgetWatchRequested>(_onWatchRequested);
    on<BudgetUpdated>(_onBudgetUpdated);
    on<BudgetSaveRequested>(_onSaveRequested);
  }

  Future<void> _onLoadRequested(
    BudgetLoadRequested event,
    Emitter<BudgetState> emit,
  ) async {
    emit(BudgetLoading());
    try {
      final budget = await _budgetRepository.getCurrentMonthBudget(
        month: event.month,
        year: event.year,
      );
      emit(BudgetLoaded(budget));
    } catch (_) {
      emit(const BudgetFailure('Failed to load budget.'));
    }
  }

  Future<void> _onWatchRequested(
    BudgetWatchRequested event,
    Emitter<BudgetState> emit,
  ) async {
    emit(BudgetLoading());
    await _budgetSubscription?.cancel();
    _budgetSubscription = _budgetRepository
        .watchCurrentMonthBudget(month: event.month, year: event.year)
        .listen(
          (budget) => add(BudgetUpdated(budget)),
          onError: (_) => add(
            const BudgetUpdated(null, message: 'Failed to load budget.'),
          ),
        );
  }

  void _onBudgetUpdated(
    BudgetUpdated event,
    Emitter<BudgetState> emit,
  ) {
    final message = event.message;
    if (message != null) {
      emit(BudgetFailure(message));
      return;
    }
    emit(BudgetLoaded(event.budget));
  }

  Future<void> _onSaveRequested(
    BudgetSaveRequested event,
    Emitter<BudgetState> emit,
  ) async {
    final budget = event.budget;
    if (budget.amount <= 0) {
      emit(const BudgetFailure('Enter a valid budget amount.'));
      return;
    }
    if (budget.warningThresholdPercent < 1 ||
        budget.warningThresholdPercent > 100) {
      emit(const BudgetFailure('Warning threshold must be between 1 and 100.'));
      return;
    }

    emit(BudgetSaving(budget));
    try {
      await _budgetRepository.saveBudget(budget);
      emit(BudgetSaved(budget));
      emit(BudgetLoaded(budget));
    } catch (_) {
      emit(const BudgetFailure('Failed to save budget.'));
    }
  }

  @override
  Future<void> close() {
    _budgetSubscription?.cancel();
    return super.close();
  }
}
