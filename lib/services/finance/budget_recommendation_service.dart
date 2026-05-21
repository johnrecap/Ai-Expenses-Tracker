import 'dart:math';

import 'package:expense_repository/expense_repository.dart';

import 'financial_calculation_service.dart';

enum BudgetRecommendationScope { monthly, category }

enum BudgetRecommendationConfidence { low, medium, high }

enum BudgetRecommendationCaveat {
  sparseHistory,
  outlierMonth,
  missingRates,
  existingBudget,
}

class BudgetRecommendationInput {
  const BudgetRecommendationInput({
    required this.expenses,
    required this.settings,
    this.existingMonthlyBudget,
    this.existingCategoryBudgets = const [],
    this.categories = const [],
    this.now,
    this.targetAggressiveness = 1,
  });

  final List<Expense> expenses;
  final UserSettings settings;
  final Budget? existingMonthlyBudget;
  final List<CategoryBudget> existingCategoryBudgets;
  final List<Category> categories;
  final DateTime? now;
  final double targetAggressiveness;
}

class BudgetRecommendation {
  const BudgetRecommendation({
    required this.scope,
    required this.suggestedAmount,
    required this.currency,
    required this.warningThresholdPercent,
    required this.confidence,
    required this.sourcePeriodLabel,
    required this.explanation,
    this.categoryId,
    this.categoryName,
    this.caveats = const [],
  });

  final BudgetRecommendationScope scope;
  final String? categoryId;
  final String? categoryName;
  final double suggestedAmount;
  final String currency;
  final int warningThresholdPercent;
  final BudgetRecommendationConfidence confidence;
  final String sourcePeriodLabel;
  final String explanation;
  final List<BudgetRecommendationCaveat> caveats;

  bool get hasCaveats => caveats.isNotEmpty;
}

class BudgetRecommendationService {
  const BudgetRecommendationService({
    FinancialCalculationService calculationService =
        const FinancialCalculationService(),
  }) : _calculationService = calculationService;

  final FinancialCalculationService _calculationService;

  BudgetRecommendation recommendMonthlyBudget(
    BudgetRecommendationInput input,
  ) {
    final now = input.now ?? DateTime.now();
    final months = _recentCompleteMonths(now);
    final monthTotals = _monthlyTotals(
      expenses: input.expenses,
      settings: input.settings,
      months: months,
    );
    final caveats = <BudgetRecommendationCaveat>{};
    if (monthTotals.any((month) => month.ignoredCurrencyCount > 0)) {
      caveats.add(BudgetRecommendationCaveat.missingRates);
    }
    if (input.existingMonthlyBudget != null) {
      caveats.add(BudgetRecommendationCaveat.existingBudget);
    }

    final nonZeroTotals = monthTotals
        .where((month) => month.total > 0)
        .map((month) => month.total)
        .toList(growable: false);
    if (nonZeroTotals.length < 2) {
      caveats.add(BudgetRecommendationCaveat.sparseHistory);
    }

    final outlierAdjusted = _outlierAdjusted(nonZeroTotals);
    if (outlierAdjusted.hadOutlier) {
      caveats.add(BudgetRecommendationCaveat.outlierMonth);
    }

    final suggested = _roundedBudgetAmount(
      _trendAdjustedAmount(outlierAdjusted.values) * input.targetAggressiveness,
    );
    final confidence = _confidence(nonZeroTotals.length, caveats);

    return BudgetRecommendation(
      scope: BudgetRecommendationScope.monthly,
      suggestedAmount: suggested,
      currency: input.settings.baseCurrency.trim().toUpperCase(),
      warningThresholdPercent: _thresholdFor(confidence),
      confidence: confidence,
      sourcePeriodLabel: _sourcePeriodLabel(months),
      explanation: _monthlyExplanation(nonZeroTotals.length, caveats),
      caveats: caveats.toList(growable: false),
    );
  }

  List<BudgetRecommendation> recommendCategoryBudgets(
    BudgetRecommendationInput input, {
    int limit = 3,
  }) {
    final now = input.now ?? DateTime.now();
    final months = _recentCompleteMonths(now);
    final activeCategories = input.categories
        .where((category) => !category.isArchived && category.categoryId != '')
        .toList(growable: false);
    final existingCategoryIds = input.existingCategoryBudgets
        .where((budget) => !budget.isArchived)
        .map((budget) => budget.categoryId)
        .toSet();

    final recommendations = <_ScoredCategoryRecommendation>[];
    for (final category in activeCategories) {
      final monthTotals = _monthlyTotals(
        expenses: input.expenses,
        settings: input.settings,
        months: months,
        where: (expense) => expense.categoryId == category.categoryId,
      );
      final nonZeroTotals = monthTotals
          .where((month) => month.total > 0)
          .map((month) => month.total)
          .toList(growable: false);
      if (nonZeroTotals.isEmpty) continue;

      final caveats = <BudgetRecommendationCaveat>{};
      if (nonZeroTotals.length < 2) {
        caveats.add(BudgetRecommendationCaveat.sparseHistory);
      }
      if (monthTotals.any((month) => month.ignoredCurrencyCount > 0)) {
        caveats.add(BudgetRecommendationCaveat.missingRates);
      }
      if (existingCategoryIds.contains(category.categoryId)) {
        caveats.add(BudgetRecommendationCaveat.existingBudget);
      }
      final outlierAdjusted = _outlierAdjusted(nonZeroTotals);
      if (outlierAdjusted.hadOutlier) {
        caveats.add(BudgetRecommendationCaveat.outlierMonth);
      }

      final suggested = _roundedBudgetAmount(
        _trendAdjustedAmount(outlierAdjusted.values) *
            input.targetAggressiveness,
      );
      if (suggested <= 0) continue;

      final first = nonZeroTotals.first;
      final last = nonZeroTotals.last;
      final growthScore = first <= 0 ? 0 : max(0, (last - first) / first);
      final score = suggested * (1 + growthScore);
      final confidence = _confidence(nonZeroTotals.length, caveats);
      recommendations.add(
        _ScoredCategoryRecommendation(
          score: score,
          recommendation: BudgetRecommendation(
            scope: BudgetRecommendationScope.category,
            categoryId: category.categoryId,
            categoryName: category.name,
            suggestedAmount: suggested,
            currency: input.settings.baseCurrency.trim().toUpperCase(),
            warningThresholdPercent: _thresholdFor(confidence),
            confidence: confidence,
            sourcePeriodLabel: _sourcePeriodLabel(months),
            explanation: _categoryExplanation(
              category.name,
              nonZeroTotals.length,
              last > first,
              caveats,
            ),
            caveats: caveats.toList(growable: false),
          ),
        ),
      );
    }

    recommendations.sort((a, b) => b.score.compareTo(a.score));
    return recommendations
        .take(limit)
        .map((scored) => scored.recommendation)
        .toList(growable: false);
  }

  List<DateTime> _recentCompleteMonths(DateTime now) {
    final currentMonth = DateTime(now.year, now.month);
    return List.generate(3, (index) {
      return DateTime(currentMonth.year, currentMonth.month - index - 1);
    }).reversed.toList(growable: false);
  }

  List<_MonthTotal> _monthlyTotals({
    required List<Expense> expenses,
    required UserSettings settings,
    required List<DateTime> months,
    bool Function(Expense expense)? where,
  }) {
    return months.map((month) {
      final breakdown = _calculationService.calculateExpenses(
        expenses: expenses,
        settings: settings,
        where: (expense) {
          final inMonth = expense.date.year == month.year &&
              expense.date.month == month.month;
          return inMonth && (where == null || where(expense));
        },
      );
      return _MonthTotal(
        total: breakdown.total,
        ignoredCurrencyCount: breakdown.ignoredCurrencyCount,
      );
    }).toList(growable: false);
  }

  _OutlierAdjusted _outlierAdjusted(List<double> values) {
    if (values.length < 3) return _OutlierAdjusted(values, false);
    final sorted = [...values]..sort();
    final lowAverage = (sorted[0] + sorted[1]) / 2;
    final high = sorted[2];
    if (lowAverage > 0 && high > lowAverage * 1.8) {
      return _OutlierAdjusted([sorted[0], sorted[1]], true);
    }
    return _OutlierAdjusted(values, false);
  }

  double _trendAdjustedAmount(List<double> values) {
    if (values.isEmpty) return 0;
    final average = values.reduce((a, b) => a + b) / values.length;
    if (values.length < 2) return average;

    final first = values.first;
    final last = values.last;
    if (first <= 0) return average;
    final change = (last - first) / first;
    if (change >= 0.2) return average * 1.1;
    if (change <= -0.2) return average * 0.95;
    return average;
  }

  double _roundedBudgetAmount(double amount) {
    if (amount <= 0 || !amount.isFinite) return 0;
    if (amount < 100) return (amount / 10).ceil() * 10;
    if (amount < 1000) return (amount / 50).ceil() * 50;
    return (amount / 100).ceil() * 100;
  }

  BudgetRecommendationConfidence _confidence(
    int nonZeroMonthCount,
    Set<BudgetRecommendationCaveat> caveats,
  ) {
    if (nonZeroMonthCount < 2 ||
        caveats.contains(BudgetRecommendationCaveat.missingRates)) {
      return BudgetRecommendationConfidence.low;
    }
    if (nonZeroMonthCount == 2 ||
        caveats.contains(BudgetRecommendationCaveat.outlierMonth)) {
      return BudgetRecommendationConfidence.medium;
    }
    return BudgetRecommendationConfidence.high;
  }

  int _thresholdFor(BudgetRecommendationConfidence confidence) {
    switch (confidence) {
      case BudgetRecommendationConfidence.high:
        return 80;
      case BudgetRecommendationConfidence.medium:
        return 75;
      case BudgetRecommendationConfidence.low:
        return 70;
    }
  }

  String _sourcePeriodLabel(List<DateTime> months) {
    if (months.isEmpty) return '';
    final first = months.first;
    final last = months.last;
    return '${first.year}-${first.month.toString().padLeft(2, '0')} to '
        '${last.year}-${last.month.toString().padLeft(2, '0')}';
  }

  String _monthlyExplanation(
    int monthCount,
    Set<BudgetRecommendationCaveat> caveats,
  ) {
    if (monthCount < 2) {
      return 'Based on limited recent spending history.';
    }
    if (caveats.contains(BudgetRecommendationCaveat.outlierMonth)) {
      return 'Based on recent monthly spending with one unusually high month reduced.';
    }
    return 'Based on recent average monthly spending and trend.';
  }

  String _categoryExplanation(
    String categoryName,
    int monthCount,
    bool growing,
    Set<BudgetRecommendationCaveat> caveats,
  ) {
    if (monthCount < 2) {
      return 'Based on limited recent $categoryName spending.';
    }
    if (caveats.contains(BudgetRecommendationCaveat.outlierMonth)) {
      return 'Based on $categoryName spending with one unusually high month reduced.';
    }
    if (growing) {
      return 'Based on growing recent $categoryName spending.';
    }
    return 'Based on recent $categoryName spending.';
  }
}

class _MonthTotal {
  const _MonthTotal({
    required this.total,
    required this.ignoredCurrencyCount,
  });

  final double total;
  final int ignoredCurrencyCount;
}

class _OutlierAdjusted {
  const _OutlierAdjusted(this.values, this.hadOutlier);

  final List<double> values;
  final bool hadOutlier;
}

class _ScoredCategoryRecommendation {
  const _ScoredCategoryRecommendation({
    required this.score,
    required this.recommendation,
  });

  final double score;
  final BudgetRecommendation recommendation;
}
