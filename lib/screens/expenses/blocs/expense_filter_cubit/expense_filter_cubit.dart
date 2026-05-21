import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/services/expense_filter_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'expense_filter_state.dart';

class ExpenseFilterCubit extends Cubit<ExpenseFilterState> {
  List<Expense> _allExpenses;
  bool _hasMoreLoadedScope;

  ExpenseFilterCubit(
    List<Expense> expenses, {
    ExpenseFilter initialFilter = ExpenseFilter.empty,
    bool hasMoreLoadedScope = false,
  })  : _allExpenses = List.unmodifiable(expenses),
        _hasMoreLoadedScope = hasMoreLoadedScope,
        super(
          ExpenseFilterState(
            allExpenses: List.unmodifiable(expenses),
            filteredExpenses: ExpenseFilterService.apply(
              expenses,
              initialFilter,
            ),
            filter: initialFilter,
            hasMoreLoadedScope: hasMoreLoadedScope,
          ),
        );

  void updateQuery(String query) {
    _apply(state.filter.copyWith(query: query));
  }

  void updateFilter(ExpenseFilter filter) {
    _apply(filter);
  }

  void reset() {
    _apply(ExpenseFilter.empty);
  }

  void replaceExpenses(
    List<Expense> expenses, {
    bool? hasMoreLoadedScope,
  }) {
    _allExpenses = List.unmodifiable(_orderedUnique(expenses));
    _hasMoreLoadedScope = hasMoreLoadedScope ?? _hasMoreLoadedScope;
    _apply(state.filter);
  }

  void mergeRecentExpenses(
    List<Expense> expenses, {
    bool? hasMoreLoadedScope,
  }) {
    _allExpenses = List.unmodifiable(_orderedUnique([
      ...expenses,
      ..._allExpenses,
    ]));
    _hasMoreLoadedScope = hasMoreLoadedScope ?? _hasMoreLoadedScope;
    _apply(state.filter);
  }

  void appendExpenses(
    List<Expense> expenses, {
    bool? hasMoreLoadedScope,
  }) {
    _allExpenses = List.unmodifiable(_orderedUnique([
      ..._allExpenses,
      ...expenses,
    ]));
    _hasMoreLoadedScope = hasMoreLoadedScope ?? _hasMoreLoadedScope;
    _apply(state.filter);
  }

  void _apply(ExpenseFilter filter) {
    emit(
      ExpenseFilterState(
        allExpenses: _allExpenses,
        filteredExpenses: ExpenseFilterService.apply(_allExpenses, filter),
        filter: filter,
        hasMoreLoadedScope: _hasMoreLoadedScope,
      ),
    );
  }

  List<Expense> _orderedUnique(List<Expense> expenses) {
    final byId = <String, Expense>{};
    for (final expense in expenses) {
      byId[expense.expenseId] = expense;
    }
    final unique = byId.values.toList()
      ..sort((a, b) {
        final dateCompare = b.date.compareTo(a.date);
        if (dateCompare != 0) return dateCompare;
        return b.expenseId.compareTo(a.expenseId);
      });
    return unique;
  }
}
