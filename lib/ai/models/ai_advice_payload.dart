import 'package:expense_repository/expense_repository.dart';

class AiAdvicePayload {
  final ReportRangeType period;
  final DateTime? startDate;
  final DateTime? endDate;
  final String currency;
  final String? focusCategory;
  final String? tone;

  const AiAdvicePayload({
    required this.period,
    required this.currency,
    this.startDate,
    this.endDate,
    this.focusCategory,
    this.tone,
  });

  ReportRange toReportRange({DateTime? now}) {
    switch (period) {
      case ReportRangeType.weekly:
        return ReportRange.weekly(anchorDate: startDate ?? now);
      case ReportRangeType.monthly:
        return ReportRange.monthly(anchorDate: startDate ?? now);
      case ReportRangeType.custom:
        return ReportRange.custom(
          startDate: startDate ?? now ?? DateTime.now(),
          endDate: endDate ?? startDate ?? now ?? DateTime.now(),
        );
    }
  }
}
