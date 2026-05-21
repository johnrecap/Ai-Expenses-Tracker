import 'package:expense_repository/expense_repository.dart';

enum ReportDrilldownKind { bucket, category }

enum ReportDrilldownCurrencyPolicy { reportConvertedTotal }

class ReportDrilldownTarget {
  const ReportDrilldownTarget._({
    required this.kind,
    required this.title,
    required this.range,
    required this.filter,
    this.bucket,
    this.category,
  });

  factory ReportDrilldownTarget.bucket({
    required ReportRange range,
    required ReportBucket bucket,
  }) {
    return ReportDrilldownTarget._(
      kind: ReportDrilldownKind.bucket,
      title: bucket.label,
      range: range,
      bucket: bucket,
      filter: ExpenseFilter(
        startDate: _dateOnly(bucket.startDate),
        endDate: _dateOnly(bucket.endDate),
      ),
    );
  }

  factory ReportDrilldownTarget.category({
    required ReportRange range,
    required CategoryReportTotal category,
  }) {
    return ReportDrilldownTarget._(
      kind: ReportDrilldownKind.category,
      title: category.categoryName,
      range: range,
      category: category,
      filter: ExpenseFilter(
        startDate: _dateOnly(range.startDate),
        endDate: _dateOnly(range.endDate),
        categoryIds: [category.categoryId],
      ),
    );
  }

  final ReportDrilldownKind kind;
  final String title;
  final ReportRange range;
  final ReportBucket? bucket;
  final CategoryReportTotal? category;
  final ReportDrilldownCurrencyPolicy currencyPolicy =
      ReportDrilldownCurrencyPolicy.reportConvertedTotal;
  final ExpenseFilter filter;

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
