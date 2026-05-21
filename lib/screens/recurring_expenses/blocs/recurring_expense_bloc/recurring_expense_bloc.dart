import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';

part 'recurring_expense_event.dart';
part 'recurring_expense_state.dart';

class RecurringExpenseBloc
    extends Bloc<RecurringExpenseEvent, RecurringExpenseState> {
  final RecurringExpenseRepository _recurringExpenseRepository;
  StreamSubscription<List<RecurringExpense>>? _subscription;

  RecurringExpenseBloc(this._recurringExpenseRepository)
      : super(RecurringExpenseInitial()) {
    on<RecurringExpensesWatchRequested>(_onWatchRequested);
    on<RecurringExpensesUpdated>(_onUpdated);
    on<RecurringExpenseCreateRequested>(_onCreateRequested);
    on<RecurringExpenseUpdateRequested>(_onUpdateRequested);
    on<RecurringExpenseArchiveRequested>(_onArchiveRequested);
  }

  Future<void> _onWatchRequested(
    RecurringExpensesWatchRequested event,
    Emitter<RecurringExpenseState> emit,
  ) async {
    emit(RecurringExpenseLoading());
    await _subscription?.cancel();
    _subscription = _recurringExpenseRepository
        .watchRecurringExpenses(includeArchived: event.includeArchived)
        .listen(
          (rules) => add(RecurringExpensesUpdated(rules)),
          onError: (_) => add(
            const RecurringExpensesUpdated(
              [],
              message: 'Failed to load recurring expenses.',
            ),
          ),
        );
  }

  void _onUpdated(
    RecurringExpensesUpdated event,
    Emitter<RecurringExpenseState> emit,
  ) {
    if (event.message != null) {
      emit(RecurringExpenseFailure(event.message!));
      return;
    }
    emit(RecurringExpenseSuccess(event.rules));
  }

  Future<void> _onCreateRequested(
    RecurringExpenseCreateRequested event,
    Emitter<RecurringExpenseState> emit,
  ) async {
    final validationMessage = _validationMessage(event.rule);
    if (validationMessage != null) {
      emit(RecurringExpenseFailure(validationMessage));
      return;
    }

    emit(RecurringExpenseSaving());
    try {
      await _recurringExpenseRepository.createRecurringExpense(event.rule);
      emit(const RecurringExpenseActionSuccess('Recurring expense created.'));
      add(const RecurringExpensesWatchRequested());
    } catch (_) {
      emit(const RecurringExpenseFailure(
        'Failed to create recurring expense.',
      ));
    }
  }

  Future<void> _onUpdateRequested(
    RecurringExpenseUpdateRequested event,
    Emitter<RecurringExpenseState> emit,
  ) async {
    final validationMessage = _validationMessage(event.rule);
    if (event.rule.recurringExpenseId.isEmpty || validationMessage != null) {
      emit(RecurringExpenseFailure(
        validationMessage ?? 'Select a recurring expense to update.',
      ));
      return;
    }

    emit(RecurringExpenseSaving());
    try {
      await _recurringExpenseRepository.updateRecurringExpense(event.rule);
      emit(const RecurringExpenseActionSuccess('Recurring expense updated.'));
      add(const RecurringExpensesWatchRequested());
    } catch (_) {
      emit(const RecurringExpenseFailure(
        'Failed to update recurring expense.',
      ));
    }
  }

  Future<void> _onArchiveRequested(
    RecurringExpenseArchiveRequested event,
    Emitter<RecurringExpenseState> emit,
  ) async {
    if (event.rule.recurringExpenseId.isEmpty) {
      emit(const RecurringExpenseFailure(
        'Select a recurring expense to archive.',
      ));
      return;
    }

    emit(RecurringExpenseSaving());
    try {
      await _recurringExpenseRepository.archiveRecurringExpense(
        event.rule.recurringExpenseId,
      );
      emit(const RecurringExpenseActionSuccess('Recurring expense archived.'));
      add(const RecurringExpensesWatchRequested());
    } catch (_) {
      emit(const RecurringExpenseFailure(
        'Failed to archive recurring expense.',
      ));
    }
  }

  String? _validationMessage(RecurringExpense rule) {
    if (rule.amount <= 0) return 'Enter a valid recurring amount.';
    if (rule.categoryId.isEmpty) return 'Select a category.';
    if (rule.currency.trim().isEmpty) return 'Select a currency.';
    if (rule.endDate != null && rule.endDate!.isBefore(rule.startDate)) {
      return 'End date must be after the start date.';
    }
    return null;
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
