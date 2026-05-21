import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/categories/category_icon_view.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/monetization/monetization.dart';
import 'package:expenses_tracker/screens/expenses/blocs/expense_filter_cubit/expense_filter_cubit.dart';
import 'package:expenses_tracker/screens/expenses/widgets/expense_edit_sheet.dart';
import 'package:expenses_tracker/screens/expenses/widgets/expense_filter_sheet.dart';
import 'package:expenses_tracker/screens/expenses/widgets/expense_search_bar.dart';
import 'package:expenses_tracker/screens/home/blocs/get_expenses_bloc/get_expenses_bloc.dart';
import 'package:expenses_tracker/screens/settings/utils/currency_formatter.dart';
import 'package:expenses_tracker/widgets/sync_status_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ExpensesScreen extends StatefulWidget {
  final List<Expense> expenses;
  final ExpenseFilter initialFilter;
  final ExpensePageCursor? initialCursor;
  final bool initialHasMore;

  const ExpensesScreen({
    super.key,
    required this.expenses,
    this.initialFilter = ExpenseFilter.empty,
    this.initialCursor,
    this.initialHasMore = false,
  });

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  ExpensePageCursor? _nextCursor;
  bool _hasMore = false;
  bool _isLoadingMore = false;
  bool _loadMoreFailed = false;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialFilter.query;
    _nextCursor = widget.initialCursor ?? _cursorFor(widget.expenses);
    _hasMore = widget.initialHasMore;
    _scrollController.addListener(_maybeLoadMoreFromScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ExpenseFilterCubit(
        widget.expenses,
        initialFilter: widget.initialFilter,
        hasMoreLoadedScope: widget.initialHasMore,
      ),
      child: Builder(
        builder: (context) {
          final scaffold = _buildScaffold(context);
          try {
            context.read<GetExpensesBloc>();
          } catch (_) {
            return scaffold;
          }

          return BlocListener<GetExpensesBloc, GetExpensesState>(
            listener: (context, state) {
              if (state is GetExpensesSuccess) {
                final cubit = context.read<ExpenseFilterCubit>()
                  ..mergeRecentExpenses(
                    state.expenses,
                    hasMoreLoadedScope: state.hasMore || _hasMore,
                  );
                _nextCursor = _cursorFor(cubit.state.allExpenses);
                _hasMore = state.hasMore || _hasMore;
              }
            },
            child: scaffold,
          );
        },
      ),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: Text(context.l10n.expenses),
        actions: [
          IconButton(
            onPressed: () => _openFilterSheet(context),
            icon: const Icon(Icons.filter_list),
            tooltip: context.l10n.filters,
          ),
        ],
      ),
      body: BlocBuilder<ExpenseFilterCubit, ExpenseFilterState>(
        builder: (context, state) {
          return Column(
            children: [
              SyncStatusBanner(expenses: state.allExpenses),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ExpenseSearchBar(
                        controller: _searchController,
                        onChanged:
                            context.read<ExpenseFilterCubit>().updateQuery,
                        onClear: () {
                          _searchController.clear();
                          context.read<ExpenseFilterCubit>().updateQuery('');
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.l10n
                                .resultsCount(state.filteredExpenses.length),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.outline,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              _searchController.clear();
                              await _refreshPageForFilter(
                                context,
                                ExpenseFilter.empty,
                              );
                              if (!context.mounted) return;
                              setState(() {});
                            },
                            child: Text(context.l10n.reset),
                          ),
                        ],
                      ),
                      if (!state.filter.isEmpty) ...[
                        const SizedBox(height: 6),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            context.l10n.activeReportDrilldownFilter,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                      if (state.isLimitedScope) ...[
                        const SizedBox(height: 6),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            state.filter.startDate == null &&
                                    state.filter.endDate == null
                                ? context.l10n
                                    .expenseResultsLimitedToLoadedHistory
                                : context.l10n
                                    .expenseResultsLimitedToDateRange,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.outline,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      const MonetizationBannerAdSlot(
                        placementKey: AdPlacementKey.expensesBanner,
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: state.filteredExpenses.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      context.l10n.noExpensesMatchFilters,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (_hasMore)
                                      _LoadMoreFooter(
                                        hasMore: _hasMore,
                                        isLoading: _isLoadingMore,
                                        hasError: _loadMoreFailed,
                                        onLoadMore: () => _loadMore(context),
                                      ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                controller: _scrollController,
                                itemCount:
                                    state.filteredExpenses.length + 1,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  if (index ==
                                      state.filteredExpenses.length) {
                                    return _LoadMoreFooter(
                                      hasMore: _hasMore,
                                      isLoading: _isLoadingMore,
                                      hasError: _loadMoreFailed,
                                      onLoadMore: () => _loadMore(context),
                                    );
                                  }
                                  return _ExpenseTile(
                                    expense: state.filteredExpenses[index],
                                    onEdit: () => _editExpense(
                                      context,
                                      state.filteredExpenses[index],
                                    ),
                                    onDelete: () => _deleteExpense(
                                      context,
                                      state.filteredExpenses[index],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openFilterSheet(BuildContext context) async {
    final cubit = context.read<ExpenseFilterCubit>();
    final filter = cubit.state.filter;
    final categories = _categoriesFromExpenses(cubit.state.allExpenses);
    final updatedFilter = await showModalBottomSheet<ExpenseFilter>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ExpenseFilterSheet(
        initialFilter: filter,
        categories: categories,
      ),
    );

    if (updatedFilter == null || !context.mounted) return;
    if (updatedFilter == ExpenseFilter.empty) {
      _searchController.clear();
      await _refreshPageForFilter(context, ExpenseFilter.empty);
      setState(() {});
      return;
    }
    _searchController.text = updatedFilter.query;
    await _refreshPageForFilter(context, updatedFilter);
    setState(() {});
  }

  Future<void> _refreshPageForFilter(
    BuildContext context,
    ExpenseFilter filter,
  ) async {
    final cubit = context.read<ExpenseFilterCubit>();
    try {
      final page = await context.read<ExpenseRepository>().getExpensePage(
            filter: filter,
          );
      if (!context.mounted) return;
      _nextCursor = page.nextCursor;
      _hasMore = page.hasMore;
      _loadMoreFailed = false;
      cubit
        ..replaceExpenses(
          page.expenses,
          hasMoreLoadedScope: page.hasMore,
        )
        ..updateFilter(filter);
    } catch (_) {
      cubit.updateFilter(filter);
      _showSnackBar(context, context.l10n.failedToLoadExpenses);
    }
  }

  void _maybeLoadMoreFromScroll() {
    if (!_scrollController.hasClients || !_hasMore || _isLoadingMore) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      _loadMore(context);
    }
  }

  Future<void> _loadMore(BuildContext context) async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() {
      _isLoadingMore = true;
      _loadMoreFailed = false;
    });

    final cubit = context.read<ExpenseFilterCubit>();
    try {
      final page = await context.read<ExpenseRepository>().getExpensePage(
            startAfter: _nextCursor,
            filter: cubit.state.filter,
          );
      if (!context.mounted) return;
      setState(() {
        _nextCursor = page.nextCursor;
        _hasMore = page.hasMore;
        _isLoadingMore = false;
      });
      cubit.appendExpenses(
        page.expenses,
        hasMoreLoadedScope: page.hasMore,
      );
    } catch (_) {
      if (!context.mounted) return;
      setState(() {
        _isLoadingMore = false;
        _loadMoreFailed = true;
      });
      _showSnackBar(context, context.l10n.failedToLoadExpenses);
    }
  }

  ExpensePageCursor? _cursorFor(List<Expense> expenses) {
    if (expenses.isEmpty) return null;
    final ordered = List<Expense>.from(expenses)
      ..sort((a, b) {
        final dateCompare = b.date.compareTo(a.date);
        if (dateCompare != 0) return dateCompare;
        return b.expenseId.compareTo(a.expenseId);
      });
    return ExpensePageCursor.fromExpense(ordered.last);
  }

  List<Category> _categoriesFromExpenses(List<Expense> expenses) {
    final categoriesById = <String, Category>{};
    for (final expense in expenses) {
      final category = expense.category;
      final id = expense.categoryId.isNotEmpty
          ? expense.categoryId
          : category.categoryId.isNotEmpty
              ? category.categoryId
              : expense.categoryName;
      if (id.isEmpty || categoriesById.containsKey(id)) continue;
      categoriesById[id] = Category(
        categoryId: id,
        name: expense.categoryName.isNotEmpty
            ? expense.categoryName
            : category.name,
        totalExpenses: category.totalExpenses,
        icon: expense.categoryIcon.isNotEmpty
            ? expense.categoryIcon
            : category.icon,
        color:
            expense.categoryColor != 0 ? expense.categoryColor : category.color,
      );
    }
    return categoriesById.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  Future<void> _editExpense(BuildContext context, Expense expense) async {
    final cubit = context.read<ExpenseFilterCubit>();
    final updated = await showExpenseEditSheet(
      context: context,
      expense: expense,
      categories: _categoriesFromExpenses(cubit.state.allExpenses),
    );
    if (updated == null || !context.mounted) return;

    try {
      await context.read<ExpenseRepository>().updateExpense(updated);
      if (!context.mounted) return;
      final refreshed = cubit.state.allExpenses
          .map((item) => item.expenseId == updated.expenseId ? updated : item)
          .toList();
      cubit.replaceExpenses(refreshed);
      _showSnackBar(context, context.l10n.expenseUpdated);
    } catch (_) {
      if (!context.mounted) return;
      _showSnackBar(context, context.l10n.failedToUpdateExpense);
    }
  }

  Future<void> _deleteExpense(BuildContext context, Expense expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.deleteExpenseTitle),
        content: Text(expenseDeleteContext(context, expense)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final cubit = context.read<ExpenseFilterCubit>();
    try {
      await context.read<ExpenseRepository>().deleteExpense(expense.expenseId);
      if (!context.mounted) return;
      cubit.replaceExpenses(
        cubit.state.allExpenses
            .where((item) => item.expenseId != expense.expenseId)
            .toList(),
      );
      _showSnackBar(context, context.l10n.expenseDeleted);
    } catch (_) {
      if (!context.mounted) return;
      _showSnackBar(context, context.l10n.failedToDeleteExpense);
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _LoadMoreFooter extends StatelessWidget {
  final bool hasMore;
  final bool isLoading;
  final bool hasError;
  final VoidCallback onLoadMore;

  const _LoadMoreFooter({
    required this.hasMore,
    required this.isLoading,
    required this.hasError,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Text(
            context.l10n.allLoadedExpensesShown,
            style: TextStyle(
              color: Theme.of(context).colorScheme.outline,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: OutlinedButton.icon(
          onPressed: isLoading ? null : onLoadMore,
          icon: isLoading
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(hasError ? Icons.refresh : Icons.expand_more),
          label: Text(
            hasError
                ? context.l10n.retry
                : isLoading
                    ? context.l10n.loadingMoreExpenses
                    : context.l10n.loadMoreExpenses,
          ),
        ),
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExpenseTile({
    required this.expense,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final categoryName = expense.categoryName.isNotEmpty
        ? expense.categoryName
        : expense.category.name;
    final categoryIcon = expense.categoryIcon.isNotEmpty
        ? expense.categoryIcon
        : expense.category.icon;
    final categoryColor = expense.categoryColor != 0
        ? expense.categoryColor
        : expense.category.color;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CategoryIconView(
            iconKey: categoryIcon,
            backgroundColor: Color(categoryColor),
            size: 44,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoryName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                if (expense.description.isNotEmpty)
                  Text(
                    expense.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                if (expense.merchant?.isNotEmpty == true)
                  Text(
                    expense.merchant!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                      fontSize: 12,
                    ),
                  ),
                if (expense.tags.isNotEmpty)
                  Text(
                    expense.tags.map((tag) => '#$tag').join(' '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                      fontSize: 12,
                    ),
                  ),
                Text(
                  '${localizedPaymentMethod(context.l10n, expense.paymentMethod)} '
                  '${context.l10n.expenseDetailsSeparator} '
                  '${DateFormat('dd/MM/yyyy', Localizations.localeOf(context).toLanguageTag()).format(expense.date)}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                ExpenseSyncBadge(expense: expense),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 112),
            child: Text(
              formatAmountWithCurrency(expense.amount, expense.currency),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          PopupMenuButton<_ExpenseAction>(
            tooltip: context.l10n.expenseActions,
            onSelected: (action) {
              switch (action) {
                case _ExpenseAction.edit:
                  onEdit();
                  break;
                case _ExpenseAction.delete:
                  onDelete();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _ExpenseAction.edit,
                child: ListTile(
                  leading: const Icon(Icons.edit),
                  title: Text(context.l10n.edit),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: _ExpenseAction.delete,
                child: ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: Text(context.l10n.delete),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _ExpenseAction { edit, delete }
