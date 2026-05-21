import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';

part 'get_expenses_event.dart';
part 'get_expenses_state.dart';

class GetExpensesBloc extends Bloc<GetExpensesEvent, GetExpensesState> {
  ExpenseRepository expenseRepository;
  StreamSubscription<ExpensePage>? _expensesSubscription;

  GetExpensesBloc(this.expenseRepository) : super(GetExpensesInitial()) {
    on<GetExpenses>((event, emit) async {
      await _expensesSubscription?.cancel();
      emit(GetExpensesLoading());
      _expensesSubscription = expenseRepository
          .watchRecentExpensePage(limit: event.limit)
          .listen(
            (page) => add(_ExpensesUpdated(page)),
            onError: (_, __) => add(_ExpensesWatchFailed(limit: event.limit)),
          );
    });

    on<_ExpensesUpdated>((event, emit) {
      emit(GetExpensesSuccess(event.page));
    });

    on<_ExpensesWatchFailed>((event, emit) async {
      try {
        final expenses = await expenseRepository.getExpenses();
        final ordered = List<Expense>.from(expenses)
          ..sort((first, second) {
            final dateCompare = second.date.compareTo(first.date);
            if (dateCompare != 0) return dateCompare;
            return second.expenseId.compareTo(first.expenseId);
          });
        emit(
          GetExpensesSuccess(
            ExpensePage.fromOrderedExpenses(ordered, limit: event.limit),
            pageSize: event.limit,
          ),
        );
      } catch (_) {
        emit(GetExpensesFailure());
      }
    });
  }

  @override
  Future<void> close() async {
    await _expensesSubscription?.cancel();
    return super.close();
  }
}
