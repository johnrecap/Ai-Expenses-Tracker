part of 'expense_filter_cubit.dart';

class ExpenseFilterState extends Equatable {
  final List<Expense> allExpenses;
  final List<Expense> filteredExpenses;
  final ExpenseFilter filter;
  final bool hasMoreLoadedScope;

  const ExpenseFilterState({
    required this.allExpenses,
    required this.filteredExpenses,
    required this.filter,
    this.hasMoreLoadedScope = false,
  });

  bool get isLimitedScope => hasMoreLoadedScope;

  @override
  List<Object?> get props => [
        allExpenses,
        filteredExpenses,
        filter,
        hasMoreLoadedScope,
      ];
}
