import 'package:expense_repository/expense_repository.dart';

class AiSummaryPayload {
  final ReportRangeType period;
  final DateTime? startDate;
  final DateTime? endDate;
  final String currency;
  final String? periodText;

  const AiSummaryPayload({
    required this.period,
    required this.currency,
    this.startDate,
    this.endDate,
    this.periodText,
  });

  factory AiSummaryPayload.weekly({
    DateTime? anchorDate,
    String currency = 'EGP',
    String? periodText,
  }) {
    return AiSummaryPayload(
      period: ReportRangeType.weekly,
      startDate: anchorDate,
      currency: currency,
      periodText: periodText,
    );
  }

  factory AiSummaryPayload.monthly({
    DateTime? anchorDate,
    String currency = 'EGP',
    String? periodText,
  }) {
    return AiSummaryPayload(
      period: ReportRangeType.monthly,
      startDate: anchorDate,
      currency: currency,
      periodText: periodText,
    );
  }

  factory AiSummaryPayload.custom({
    required DateTime startDate,
    required DateTime endDate,
    String currency = 'EGP',
    String? periodText,
  }) {
    return AiSummaryPayload(
      period: ReportRangeType.custom,
      startDate: startDate,
      endDate: endDate,
      currency: currency,
      periodText: periodText,
    );
  }

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
