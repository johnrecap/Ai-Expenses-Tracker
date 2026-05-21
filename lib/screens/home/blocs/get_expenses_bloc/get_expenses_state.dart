part of 'get_expenses_bloc.dart';

sealed class GetExpensesState extends Equatable {
  const GetExpensesState();

  @override
  List<Object?> get props => [];
}

final class GetExpensesInitial extends GetExpensesState {}

final class GetExpensesFailure extends GetExpensesState {}

final class GetExpensesLoading extends GetExpensesState {}

final class GetExpensesSuccess extends GetExpensesState {
  final List<Expense> expenses;
  final ExpensePageCursor? nextCursor;
  final bool hasMore;
  final int pageSize;

  GetExpensesSuccess(
    ExpensePage page, {
    this.pageSize = defaultExpensePageSize,
  })  : expenses = page.expenses,
        nextCursor = page.nextCursor,
        hasMore = page.hasMore;

  @override
  List<Object?> get props => [expenses, nextCursor, hasMore, pageSize];
}
