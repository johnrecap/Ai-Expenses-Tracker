import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/categories/category_icon_view.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/screens/category_budgets/cubit/category_budget_cubit.dart';
import 'package:expenses_tracker/screens/category_budgets/services/category_budget_calculator.dart';
import 'package:expenses_tracker/screens/settings/utils/currency_formatter.dart';
import 'package:expenses_tracker/services/finance/finance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class CategoryBudgetsScreen extends StatefulWidget {
  final List<Expense> expenses;

  const CategoryBudgetsScreen({
    required this.expenses,
    super.key,
  });

  @override
  State<CategoryBudgetsScreen> createState() => _CategoryBudgetsScreenState();
}

class _CategoryBudgetsScreenState extends State<CategoryBudgetsScreen> {
  late DateTime _selectedMonth;
  CategoryBudgetReady? _lastReadyState;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
    WidgetsBinding.instance.addPostFrameCallback((_) => _watchMonth());
  }

  void _watchMonth() {
    context.read<CategoryBudgetCubit>().watchMonth(
          month: CategoryBudget.monthKeyFor(_selectedMonth),
          expenses: widget.expenses,
        );
  }

  void _shiftMonth(int delta) {
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month + delta);
    });
    _watchMonth();
  }

  Future<void> _showForm({
    CategoryBudget? initialBudget,
    required List<Category> categories,
    bool isRecommendation = false,
  }) async {
    if (categories.isEmpty) {
      _showMessage(context.l10n.categoryBudgetsCreateCategoryFirst);
      return;
    }

    final budget = await showDialog<CategoryBudget>(
      context: context,
      builder: (_) => _CategoryBudgetFormDialog(
        categories: categories,
        month: CategoryBudget.monthKeyFor(_selectedMonth),
        initialBudget: initialBudget,
        isRecommendation: isRecommendation,
      ),
    );
    if (budget == null || !mounted) return;
    await context.read<CategoryBudgetCubit>().saveBudget(budget);
  }

  Future<void> _confirmArchive(CategoryBudget budget) async {
    final shouldArchive = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(context.l10n.archiveCategoryBudget),
          content: Text(
            context.l10n.archiveCategoryBudgetMessage(budget.categoryName),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(context.l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(context.l10n.archive),
            ),
          ],
        );
      },
    );

    if (shouldArchive != true || !mounted) return;
    await context.read<CategoryBudgetCubit>().archiveBudget(budget);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CategoryBudgetCubit, CategoryBudgetState>(
      listener: (context, state) {
        if (state is CategoryBudgetReady) {
          _lastReadyState = state;
        } else if (state is CategoryBudgetFailure) {
          _showMessage(_localizedCategoryBudgetMessage(context, state.message));
        } else if (state is CategoryBudgetActionSuccess) {
          _showMessage(_localizedCategoryBudgetMessage(context, state.message));
        }
      },
      builder: (context, state) {
        final readyState = state is CategoryBudgetReady
            ? state
            : state is CategoryBudgetSaving
                ? state.previousState
                : _lastReadyState;
        final isLoading = state is CategoryBudgetLoading ||
            (state is CategoryBudgetSaving && readyState == null);

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(context.l10n.categoryBudgets),
          ),
          floatingActionButton: readyState == null
              ? null
              : FloatingActionButton(
                  onPressed: () => _showForm(categories: readyState.categories),
                  child: const Icon(Icons.add),
                ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : readyState == null
                  ? _CategoryBudgetError(onRetry: _watchMonth)
                  : _CategoryBudgetContent(
                      state: readyState,
                      selectedMonth: _selectedMonth,
                      onPreviousMonth: () => _shiftMonth(-1),
                      onNextMonth: () => _shiftMonth(1),
                      onCreate: () => _showForm(
                        categories: readyState.categories,
                      ),
                      onEdit: (budget) => _showForm(
                        initialBudget: budget,
                        categories: readyState.categories,
                      ),
                      onUseRecommendation: (recommendation) => _showForm(
                        initialBudget: _categoryBudgetFromRecommendation(
                          recommendation,
                          readyState,
                          _selectedMonth,
                        ),
                        categories: readyState.categories,
                        isRecommendation: true,
                      ),
                      onArchive: _confirmArchive,
                    ),
        );
      },
    );
  }
}

String _localizedCategoryBudgetMessage(BuildContext context, String message) {
  final l10n = context.l10n;
  switch (message) {
    case 'Failed to load category budgets.':
      return l10n.categoryBudgetsLoadFailed;
    case 'Category budget saved.':
      return l10n.categoryBudgetSaved;
    case 'Failed to save category budget.':
      return l10n.categoryBudgetSaveFailed;
    case 'Select a category budget to archive.':
      return l10n.selectCategoryBudgetToArchive;
    case 'Category budget archived.':
      return l10n.categoryBudgetArchived;
    case 'Failed to archive category budget.':
      return l10n.categoryBudgetArchiveFailed;
    case 'Select a category.':
      return l10n.selectCategory;
    case 'Select a month.':
      return l10n.selectMonth;
    case 'Select a currency.':
      return l10n.selectCurrency;
    case 'Enter a valid budget limit.':
      return l10n.enterValidBudgetLimit;
    case 'Warning threshold must be between 1 and 100.':
      return l10n.warningThresholdRange;
    default:
      return message;
  }
}

CategoryBudget _categoryBudgetFromRecommendation(
  BudgetRecommendation recommendation,
  CategoryBudgetReady state,
  DateTime selectedMonth,
) {
  final month = CategoryBudget.monthKeyFor(selectedMonth);
  final categoryId = recommendation.categoryId ?? '';
  CategoryBudget? existing;
  for (final budget in state.budgets) {
    if (!budget.isArchived &&
        budget.month == month &&
        budget.categoryId == categoryId) {
      existing = budget;
      break;
    }
  }
  final now = DateTime.now();
  return (existing ?? CategoryBudget.empty).copyWith(
    categoryBudgetId: CategoryBudget.categoryBudgetIdFor(
      month: month,
      categoryId: categoryId,
      currency: recommendation.currency,
    ),
    categoryId: categoryId,
    categoryName: recommendation.categoryName ?? '',
    month: month,
    currency: recommendation.currency,
    limitAmount: recommendation.suggestedAmount,
    warningThresholdPercent: recommendation.warningThresholdPercent,
    isArchived: false,
    createdAt: existing?.createdAt ?? now,
    updatedAt: now,
  );
}

class _CategoryBudgetContent extends StatelessWidget {
  final CategoryBudgetReady state;
  final DateTime selectedMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onCreate;
  final ValueChanged<CategoryBudget> onEdit;
  final ValueChanged<BudgetRecommendation> onUseRecommendation;
  final ValueChanged<CategoryBudget> onArchive;

  const _CategoryBudgetContent({
    required this.state,
    required this.selectedMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onCreate,
    required this.onEdit,
    required this.onUseRecommendation,
    required this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat(
      'MMMM yyyy',
      Localizations.localeOf(context).toLanguageTag(),
    ).format(selectedMonth);
    final recommendations = state.settings == null
        ? const <BudgetRecommendation>[]
        : const BudgetRecommendationService().recommendCategoryBudgets(
            BudgetRecommendationInput(
              expenses: state.expenses,
              settings: state.settings!,
              existingCategoryBudgets: state.budgets,
              categories: state.categories,
            ),
          );

    return RefreshIndicator(
      onRefresh: () async {},
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              IconButton(
                tooltip: context.l10n.previousMonth,
                onPressed: onPreviousMonth,
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  monthLabel,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              IconButton(
                tooltip: context.l10n.nextMonth,
                onPressed: onNextMonth,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _CategoryBudgetRecommendations(
            recommendations: recommendations,
            onUseRecommendation: onUseRecommendation,
          ),
          if (recommendations.isNotEmpty) const SizedBox(height: 16),
          if (state.progress.isEmpty)
            _EmptyCategoryBudgets(onCreate: onCreate)
          else
            ...state.progress.map(
              (progress) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CategoryBudgetTile(
                  progress: progress,
                  category: state.categories.firstWhere(
                    (category) =>
                        category.categoryId == progress.budget.categoryId,
                    orElse: () => Category.empty,
                  ),
                  onEdit: () => onEdit(progress.budget),
                  onArchive: () => onArchive(progress.budget),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

String _localizedConfidence(
  BuildContext context,
  BudgetRecommendationConfidence confidence,
) {
  switch (confidence) {
    case BudgetRecommendationConfidence.high:
      return context.l10n.recommendationConfidenceHigh;
    case BudgetRecommendationConfidence.medium:
      return context.l10n.recommendationConfidenceMedium;
    case BudgetRecommendationConfidence.low:
      return context.l10n.recommendationConfidenceLow;
  }
}

class _CategoryBudgetRecommendations extends StatelessWidget {
  const _CategoryBudgetRecommendations({
    required this.recommendations,
    required this.onUseRecommendation,
  });

  final List<BudgetRecommendation> recommendations;
  final ValueChanged<BudgetRecommendation> onUseRecommendation;

  @override
  Widget build(BuildContext context) {
    if (recommendations.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.categoryBudgetRecommendationsTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        ...recommendations.map(
          (recommendation) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                title: Text(recommendation.categoryName ?? ''),
                subtitle: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.categoryBudgetRecommendationSubtitle(
                        formatAmountWithCurrency(
                          recommendation.suggestedAmount,
                          recommendation.currency,
                        ),
                        _localizedConfidence(
                          context,
                          recommendation.confidence,
                        ),
                      ),
                    ),
                    Text(
                      context.l10n.budgetRecommendationCategoryExplanation(
                        recommendation.categoryName ?? '',
                      ),
                    ),
                    ...recommendation.caveats.map(
                      (caveat) => Text(
                        _localizedCaveat(context, caveat),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ),
                  ],
                ),
                trailing: TextButton(
                  onPressed: recommendation.suggestedAmount > 0
                      ? () => onUseRecommendation(recommendation)
                      : null,
                  child: Text(context.l10n.edit),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

String _localizedCaveat(
  BuildContext context,
  BudgetRecommendationCaveat caveat,
) {
  switch (caveat) {
    case BudgetRecommendationCaveat.sparseHistory:
      return context.l10n.recommendationCaveatSparseHistory;
    case BudgetRecommendationCaveat.outlierMonth:
      return context.l10n.recommendationCaveatOutlierMonth;
    case BudgetRecommendationCaveat.missingRates:
      return context.l10n.recommendationCaveatMissingRates;
    case BudgetRecommendationCaveat.existingBudget:
      return context.l10n.recommendationCaveatExistingBudget;
  }
}

class _CategoryBudgetTile extends StatelessWidget {
  final CategoryBudgetProgress progress;
  final Category category;
  final VoidCallback onEdit;
  final VoidCallback onArchive;

  const _CategoryBudgetTile({
    required this.progress,
    required this.category,
    required this.onEdit,
    required this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    final budget = progress.budget;
    final usedPercent = (progress.percentUsed.clamp(0, 1) * 100).round();
    final progressValue = progress.percentUsed.clamp(0, 1).toDouble();
    final progressColor = progress.isExceeded
        ? Colors.red
        : progress.isNearLimit
            ? Colors.orange
            : Theme.of(context).colorScheme.primary;
    final iconKey = category.icon.isNotEmpty ? category.icon : 'other';
    final color = category.color != 0
        ? Color(category.color)
        : Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CategoryIconView(
                  iconKey: iconKey,
                  backgroundColor: color,
                  size: 44,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        budget.categoryName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        context.l10n.budgetSpentOfLimit(
                          formatAmountWithCurrency(
                            progress.spent,
                            budget.currency,
                          ),
                          formatAmountWithCurrency(
                            budget.limitAmount,
                            budget.currency,
                          ),
                        ),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$usedPercent%',
                  style: TextStyle(
                    color: progressColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progressValue,
                minHeight: 8,
                color: progressColor,
                backgroundColor: Colors.grey.shade200,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _categoryBudgetMetaLines(
                      context,
                      progress,
                    )
                        .map(
                          (line) => Text(
                            line.text,
                            style: TextStyle(color: line.color),
                          ),
                        )
                        .toList(),
                  ),
                ),
                IconButton(
                  tooltip: context.l10n.edit,
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: context.l10n.archive,
                  onPressed: onArchive,
                  icon: const Icon(Icons.archive_outlined),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

List<_BudgetMetaLine> _categoryBudgetMetaLines(
  BuildContext context,
  CategoryBudgetProgress progress,
) {
  final outline = Theme.of(context).colorScheme.outline;
  final warning = Colors.orange.shade800;
  final lines = <_BudgetMetaLine>[
    _BudgetMetaLine(
      context.l10n.budgetRemainingAmount(
        formatAmountWithCurrency(
          progress.remaining,
          progress.budget.currency,
        ),
      ),
      outline,
    ),
  ];
  if (progress.hasConvertedCurrencies) {
    lines.add(
      _BudgetMetaLine(
        context.l10n.convertedCurrenciesStatus(
          progress.convertedCurrencies.join(', '),
        ),
        outline,
      ),
    );
  }
  if (progress.hasUnconvertedCurrencies) {
    final currencies = progress.unconvertedCurrencies.isEmpty
        ? progress.budget.currency
        : progress.unconvertedCurrencies.join(', ');
    lines.add(
      _BudgetMetaLine(
        context.l10n.unconvertedCurrenciesStatus(
          progress.ignoredCurrencyCount,
          currencies,
        ),
        warning,
      ),
    );
  }
  return lines;
}

class _BudgetMetaLine {
  const _BudgetMetaLine(this.text, this.color);

  final String text;
  final Color color;
}

class _EmptyCategoryBudgets extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyCategoryBudgets({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 64),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.pie_chart_outline, size: 42),
            const SizedBox(height: 12),
            Text(
              context.l10n.noCategoryBudgetsYet,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onCreate,
              style: TextButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: Text(context.l10n.addCategoryBudget),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBudgetError extends StatelessWidget {
  final VoidCallback onRetry;

  const _CategoryBudgetError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: onRetry,
        style: TextButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        child: Text(context.l10n.retry),
      ),
    );
  }
}

class _CategoryBudgetFormDialog extends StatefulWidget {
  final List<Category> categories;
  final String month;
  final CategoryBudget? initialBudget;
  final bool isRecommendation;

  const _CategoryBudgetFormDialog({
    required this.categories,
    required this.month,
    this.initialBudget,
    this.isRecommendation = false,
  });

  @override
  State<_CategoryBudgetFormDialog> createState() =>
      _CategoryBudgetFormDialogState();
}

class _CategoryBudgetFormDialogState extends State<_CategoryBudgetFormDialog> {
  final _amountController = TextEditingController();
  final _thresholdController = TextEditingController(text: '80');
  late List<String> _currencies;
  late Category _category;
  late String _currency;

  @override
  void initState() {
    super.initState();
    final initialBudget = widget.initialBudget;
    _category = widget.categories.firstWhere(
      (category) => category.categoryId == initialBudget?.categoryId,
      orElse: () => widget.categories.first,
    );
    _currency = initialBudget?.currency ?? 'EGP';
    _currencies = _categoryBudgetCurrencyChoices(_currency);
    _amountController.text = initialBudget == null
        ? ''
        : initialBudget.limitAmount.toStringAsFixed(0);
    _thresholdController.text =
        (initialBudget?.warningThresholdPercent ?? 80).toString();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  void _submit() {
    final amount = double.tryParse(_amountController.text.trim());
    final threshold = int.tryParse(_thresholdController.text.trim());

    if (amount == null || amount <= 0) return;
    if (threshold == null || threshold < 1 || threshold > 100) return;

    final now = DateTime.now();
    final id = CategoryBudget.categoryBudgetIdFor(
      month: widget.month,
      categoryId: _category.categoryId,
      currency: _currency,
    );

    Navigator.pop(
      context,
      CategoryBudget(
        categoryBudgetId: id,
        userId: widget.initialBudget?.userId ?? '',
        categoryId: _category.categoryId,
        categoryName: _category.name,
        month: widget.month,
        currency: _currency,
        limitAmount: amount,
        warningThresholdPercent: threshold,
        isArchived: false,
        createdAt: widget.initialBudget?.createdAt ?? now,
        updatedAt: now,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initialBudget == null || widget.isRecommendation
            ? context.l10n.addCategoryBudget
            : context.l10n.editCategoryBudget,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<Category>(
              initialValue: _category,
              decoration: InputDecoration(labelText: context.l10n.category),
              items: widget.categories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _category = value);
              },
            ),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: context.l10n.limitAmount),
            ),
            DropdownButtonFormField<String>(
              initialValue: _currency,
              decoration: InputDecoration(labelText: context.l10n.currency),
              items: _currencies
                  .map(
                    (currency) => DropdownMenuItem(
                      value: currency,
                      child: Text(currency),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _currency = value);
              },
            ),
            TextField(
              controller: _thresholdController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: context.l10n.warningThresholdPercent,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        TextButton(
          onPressed: _submit,
          child: Text(context.l10n.save),
        ),
      ],
    );
  }
}

List<String> _categoryBudgetCurrencyChoices(String selected) {
  final values = <String>{
    'EGP',
    'USD',
    'EUR',
    'SAR',
    'AED',
    selected.trim().toUpperCase(),
  }..remove('');
  return values.toList(growable: false)..sort();
}
