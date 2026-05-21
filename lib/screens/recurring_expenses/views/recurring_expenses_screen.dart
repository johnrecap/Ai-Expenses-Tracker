import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/categories/category_icon_view.dart';
import 'package:expenses_tracker/screens/recurring_expenses/blocs/recurring_expense_bloc/recurring_expense_bloc.dart';
import 'package:expenses_tracker/screens/recurring_expenses/widgets/recurring_expense_form.dart';
import 'package:expenses_tracker/screens/settings/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class RecurringExpensesScreen extends StatefulWidget {
  const RecurringExpensesScreen({super.key});

  @override
  State<RecurringExpensesScreen> createState() =>
      _RecurringExpensesScreenState();
}

class _RecurringExpensesScreenState extends State<RecurringExpensesScreen> {
  List<Category> _categories = const [];
  List<String> _currencies = const ['EGP', 'USD'];

  @override
  void initState() {
    super.initState();
    _loadFormDependencies();
  }

  Future<void> _loadFormDependencies() async {
    final categoryRepository = context.read<CategoryRepository>();
    SettingsRepository? settingsRepository;
    try {
      settingsRepository = context.read<SettingsRepository>();
    } catch (_) {
      settingsRepository = null;
    }

    List<Category> categories;
    try {
      categories = await categoryRepository.getCategories();
    } catch (_) {
      categories = const [];
    }
    if (!mounted) return;
    var currencies = _currencies;
    if (settingsRepository != null) {
      try {
        final settings = await settingsRepository.getSettings();
        currencies = settings.supportedCurrencies.isEmpty
            ? currencies
            : settings.supportedCurrencies;
      } catch (_) {
        currencies = _currencies;
      }
    }

    setState(() {
      _categories =
          categories.where((category) => !category.isArchived).toList();
      _currencies = currencies;
    });
  }

  Future<void> _showForm({RecurringExpense? initialRule}) async {
    if (_categories.isEmpty) {
      _showMessage(context.l10n.createActiveCategoryBeforeRecurring);
      return;
    }

    final rule = await showDialog<RecurringExpense>(
      context: context,
      builder: (_) => RecurringExpenseForm(
        categories: _categories,
        currencies: _currencies,
        initialRule: initialRule,
      ),
    );
    if (rule == null || !mounted) return;

    final bloc = context.read<RecurringExpenseBloc>();
    if (initialRule == null) {
      bloc.add(RecurringExpenseCreateRequested(rule));
    } else {
      bloc.add(RecurringExpenseUpdateRequested(rule));
    }
  }

  Future<void> _confirmArchive(RecurringExpense rule) async {
    final shouldArchive = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(dialogContext.l10n.archiveRecurringExpense),
          content: Text(
            dialogContext.l10n.archiveRecurringExpenseMessage(
              rule.description.isEmpty ? rule.categoryName : rule.description,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(dialogContext.l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(dialogContext.l10n.archive),
            ),
          ],
        );
      },
    );

    if (shouldArchive != true || !mounted) return;
    context.read<RecurringExpenseBloc>().add(
          RecurringExpenseArchiveRequested(rule),
        );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RecurringExpenseBloc, RecurringExpenseState>(
      listener: (context, state) {
        if (state is RecurringExpenseFailure) {
          _showMessage(state.message);
        } else if (state is RecurringExpenseActionSuccess) {
          _showMessage(state.message);
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(context.l10n.recurringExpenses),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showForm(),
          child: const Icon(Icons.add),
        ),
        body: BlocBuilder<RecurringExpenseBloc, RecurringExpenseState>(
          builder: (context, state) {
            if (state is RecurringExpenseLoading ||
                state is RecurringExpenseSaving) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is RecurringExpenseFailure) {
              return _RecurringError(
                message: state.message,
                onRetry: () => context.read<RecurringExpenseBloc>().add(
                      const RecurringExpensesWatchRequested(),
                    ),
              );
            }

            final rules = state is RecurringExpenseSuccess
                ? state.rules
                    .where((rule) => !rule.isArchived && rule.isActive)
                    .toList()
                : <RecurringExpense>[];

            if (rules.isEmpty) {
              return Center(
                child: Text(
                  context.l10n.noActiveRecurringExpensesYet,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _loadFormDependencies,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: rules.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final rule = rules[index];
                  return _RecurringTile(
                    rule: rule,
                    onEdit: () => _showForm(initialRule: rule),
                    onArchive: () => _confirmArchive(rule),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RecurringTile extends StatelessWidget {
  final RecurringExpense rule;
  final VoidCallback onEdit;
  final VoidCallback onArchive;

  const _RecurringTile({
    required this.rule,
    required this.onEdit,
    required this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final title =
        rule.description.isEmpty ? rule.categoryName : rule.description;
    final frequency = localizedRecurringFrequency(context.l10n, rule.frequency);
    final nextDate =
        context.l10n.nextDateLabel(dateFormat.format(rule.nextRunDate));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CategoryIconView(
          iconKey: rule.categoryIcon,
          backgroundColor: Color(rule.categoryColor),
          size: 44,
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '$frequency - $nextDate',
        ),
        trailing: Wrap(
          spacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              formatAmountWithCurrency(rule.amount, rule.currency),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            IconButton(
              tooltip: context.l10n.edit,
              icon: const Icon(Icons.edit_outlined),
              onPressed: onEdit,
            ),
            IconButton(
              tooltip: context.l10n.archive,
              icon: const Icon(Icons.archive_outlined),
              onPressed: onArchive,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecurringError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _RecurringError({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: Text(context.l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
