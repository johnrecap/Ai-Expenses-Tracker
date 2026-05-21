part of 'get_expenses_bloc.dart';

sealed class GetExpensesEvent extends Equatable {
  const GetExpensesEvent();

  @override
  List<Object> get props => [];
}

class GetExpenses extends GetExpensesEvent {
  final int limit;

  const GetExpenses({this.limit = defaultExpensePageSize});

  @override
  List<Object> get props => [limit];
}

class _ExpensesUpdated extends GetExpensesEvent {
  final ExpensePage page;

  const _ExpensesUpdated(this.page);

  @override
  List<Object> get props => [page];
}

class _ExpensesWatchFailed extends GetExpensesEvent {
  final int limit;

  const _ExpensesWatchFailed({required this.limit});

  @override
  List<Object> get props => [limit];
}
