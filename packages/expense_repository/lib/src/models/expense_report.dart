enum ReportRangeType {
  weekly,
  monthly,
  custom,
}

class ReportRange {
  final ReportRangeType type;
  final DateTime startDate;
  final DateTime endDate;

  const ReportRange._({
    required this.type,
    required this.startDate,
    required this.endDate,
  });

  factory ReportRange.weekly({DateTime? anchorDate}) {
    final anchor = anchorDate ?? DateTime.now();
    final start = DateTime(anchor.year, anchor.month, anchor.day)
        .subtract(Duration(days: anchor.weekday - 1));
    return ReportRange._(
      type: ReportRangeType.weekly,
      startDate: start,
      endDate:
          DateTime(start.year, start.month, start.day + 6, 23, 59, 59, 999),
    );
  }

  factory ReportRange.monthly({DateTime? anchorDate}) {
    final anchor = anchorDate ?? DateTime.now();
    final start = DateTime(anchor.year, anchor.month);
    final end = DateTime(anchor.year, anchor.month + 1, 0, 23, 59, 59, 999);
    return ReportRange._(
      type: ReportRangeType.monthly,
      startDate: start,
      endDate: end,
    );
  }

  factory ReportRange.custom({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return ReportRange._(
      type: ReportRangeType.custom,
      startDate: DateTime(startDate.year, startDate.month, startDate.day),
      endDate:
          DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999),
    );
  }
}

class ReportBucket {
  final String label;
  final DateTime startDate;
  final DateTime endDate;
  final double total;

  const ReportBucket({
    required this.label,
    required this.startDate,
    required this.endDate,
    required this.total,
  });
}

class CategoryReportTotal {
  final String categoryId;
  final String categoryName;
  final String categoryIcon;
  final int categoryColor;
  final double total;

  const CategoryReportTotal({
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.total,
  });
}

class ExpenseReport {
  final ReportRange range;
  final String currency;
  final double total;
  final List<ReportBucket> buckets;
  final List<CategoryReportTotal> categoryTotals;
  final CategoryReportTotal? topCategory;
  final double previousTotal;
  final double deltaPercent;
  final int ignoredCurrencyCount;
  final List<String> convertedCurrencies;
  final List<String> unconvertedCurrencies;

  const ExpenseReport({
    required this.range,
    required this.currency,
    required this.total,
    required this.buckets,
    required this.categoryTotals,
    required this.topCategory,
    required this.previousTotal,
    required this.deltaPercent,
    required this.ignoredCurrencyCount,
    this.convertedCurrencies = const [],
    this.unconvertedCurrencies = const [],
  });
}
