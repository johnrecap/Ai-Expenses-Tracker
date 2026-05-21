import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/services/finance/finance.dart';

enum CategoryBudgetProgressStatus {
  normal,
  nearLimit,
  exceeded,
  archived,
}

class CategoryBudgetProgress {
  final CategoryBudget budget;
  final double spent;
  final double remaining;
  final double percentUsed;
  final int ignoredCurrencyCount;
  final List<String> convertedCurrencies;
  final List<String> unconvertedCurrencies;
  final CategoryBudgetProgressStatus status;

  const CategoryBudgetProgress({
    required this.budget,
    required this.spent,
    required this.remaining,
    required this.percentUsed,
    required this.ignoredCurrencyCount,
    this.convertedCurrencies = const [],
    this.unconvertedCurrencies = const [],
    required this.status,
  });

  bool get hasConvertedCurrencies => convertedCurrencies.isNotEmpty;
  bool get hasUnconvertedCurrencies => ignoredCurrencyCount > 0;
  bool get hasMixedCurrencyWarning =>
      hasConvertedCurrencies || hasUnconvertedCurrencies;
  bool get isNearLimit => status == CategoryBudgetProgressStatus.nearLimit;
  bool get isExceeded => status == CategoryBudgetProgressStatus.exceeded;
}

class CategoryBudgetCalculator {
  const CategoryBudgetCalculator({
    FinancialCalculationService calculationService =
        const FinancialCalculationService(),
  }) : _calculationService = calculationService;

  final FinancialCalculationService _calculationService;

  CategoryBudgetProgress calculate({
    required CategoryBudget budget,
    required List<Expense> expenses,
    required String selectedMonth,
    Category? category,
    UserSettings? settings,
  }) {
    if (budget.isArchived || category?.isArchived == true) {
      return CategoryBudgetProgress(
        budget: budget,
        spent: 0,
        remaining: budget.limitAmount,
        percentUsed: 0,
        ignoredCurrencyCount: 0,
        convertedCurrencies: const [],
        unconvertedCurrencies: const [],
        status: CategoryBudgetProgressStatus.archived,
      );
    }

    final budgetCurrency = budget.currency.toUpperCase();
    bool matchesBudget(Expense expense) {
      if (CategoryBudget.monthKeyFor(expense.date) != selectedMonth) {
        return false;
      }
      return expense.categoryId == budget.categoryId;
    }

    final canConvertToBudgetCurrency =
        settings != null &&
        settings.baseCurrency.trim().toUpperCase() == budgetCurrency;
    final breakdown = canConvertToBudgetCurrency
        ? _calculationService.calculateExpenses(
            expenses: expenses,
            settings: settings,
            where: matchesBudget,
          )
        : null;
    final spent = breakdown?.total ??
        expenses.where(matchesBudget).fold<double>(0, (sum, expense) {
          if (expense.currency.toUpperCase() != budgetCurrency) return sum;
          return sum + expense.amount;
        });
    final ignoredCurrencyCount = breakdown?.ignoredCurrencyCount ??
        expenses.where(matchesBudget).where((expense) {
          return expense.currency.toUpperCase() != budgetCurrency;
        }).length;
    final convertedCurrencies = breakdown?.convertedCurrencies ?? const [];
    final unconvertedCurrencies =
        breakdown?.unconvertedCurrencies ?? _fallbackIgnoredCurrencies(
          expenses: expenses,
          where: matchesBudget,
          budgetCurrency: budgetCurrency,
        );

    final remaining = budget.limitAmount - spent;
    final percentUsed =
        budget.limitAmount <= 0 ? 0.0 : spent / budget.limitAmount;
    final threshold = budget.warningThresholdPercent / 100;
    final status = spent > budget.limitAmount
        ? CategoryBudgetProgressStatus.exceeded
        : percentUsed >= threshold
            ? CategoryBudgetProgressStatus.nearLimit
            : CategoryBudgetProgressStatus.normal;

    return CategoryBudgetProgress(
      budget: budget,
      spent: spent,
      remaining: remaining,
      percentUsed: percentUsed,
      ignoredCurrencyCount: ignoredCurrencyCount,
      convertedCurrencies: convertedCurrencies,
      unconvertedCurrencies: unconvertedCurrencies,
      status: status,
    );
  }

  List<CategoryBudgetProgress> calculateAll({
    required List<CategoryBudget> budgets,
    required List<Expense> expenses,
    required List<Category> categories,
    required String selectedMonth,
    UserSettings? settings,
  }) {
    final categoriesById = {
      for (final category in categories) category.categoryId: category,
    };

    return budgets
        .where((budget) => !budget.isArchived)
        .map(
          (budget) => calculate(
            budget: budget,
            expenses: expenses,
            selectedMonth: selectedMonth,
            category: categoriesById[budget.categoryId],
            settings: settings,
          ),
        )
        .where(
          (progress) =>
              progress.status != CategoryBudgetProgressStatus.archived,
        )
        .toList();
  }

  List<String> _fallbackIgnoredCurrencies({
    required List<Expense> expenses,
    required bool Function(Expense expense) where,
    required String budgetCurrency,
  }) {
    final currencies = <String>{};
    for (final expense in expenses.where(where)) {
      final currency = expense.currency.trim().toUpperCase();
      if (currency.isEmpty || currency == budgetCurrency) continue;
      currencies.add(currency);
    }
    return List.unmodifiable(currencies.toList()..sort());
  }
}
