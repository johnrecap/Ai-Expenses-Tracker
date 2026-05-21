enum HomeBudgetStatus {
  none,
  normal,
  nearLimit,
  exceeded,
}

class HomeSummary {
  const HomeSummary({
    required this.displayName,
    required this.periodStart,
    required this.periodEnd,
    required this.spendingTotal,
    required this.currency,
    required this.hasMixedCurrencies,
    required this.convertedCurrencies,
    required this.unconvertedCurrencies,
    required this.pendingSyncCount,
    this.budgetAmount,
    this.budgetRemaining,
    this.budgetStatus = HomeBudgetStatus.none,
    this.ignoredCurrencyCount = 0,
    this.topCategoryName,
  });

  final String displayName;
  final DateTime periodStart;
  final DateTime periodEnd;
  final double spendingTotal;
  final String currency;
  final bool hasMixedCurrencies;
  final List<String> convertedCurrencies;
  final List<String> unconvertedCurrencies;
  final double? budgetAmount;
  final double? budgetRemaining;
  final HomeBudgetStatus budgetStatus;
  final int ignoredCurrencyCount;
  final String? topCategoryName;
  final int pendingSyncCount;

  bool get hasBudget => budgetAmount != null && budgetAmount! > 0;

  bool get isBudgetExceeded => budgetStatus == HomeBudgetStatus.exceeded;

  bool get canShowSingleCurrencyTotal => !hasUnconvertedCurrencies;

  bool get hasConvertedCurrencies => convertedCurrencies.isNotEmpty;

  bool get hasUnconvertedCurrencies => unconvertedCurrencies.isNotEmpty;
}
