import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/ai/models/ai_search_payload.dart';
import 'package:expenses_tracker/ai/models/ai_summary_payload.dart';

class AiActionMapper {
  const AiActionMapper._();

  static ExpenseFilter searchPayloadToFilter(
    AiSearchPayload payload, {
    DateTime? now,
  }) {
    final normalizedRange = _rangeFromText(payload.periodText, now: now);
    final categoryTerms = <String>{
      ...payload.categoryIds
          .map(_normalizeText)
          .where((item) => item.isNotEmpty),
      ...payload.categoryNames
          .map(_normalizeText)
          .where((item) => item.isNotEmpty),
    }.toList();

    return ExpenseFilter(
      query: payload.query.trim(),
      startDate: payload.startDate ?? normalizedRange?.startDate,
      endDate: payload.endDate ?? normalizedRange?.endDate,
      categoryIds: categoryTerms,
      minAmount: payload.minAmount,
      maxAmount: payload.maxAmount,
      paymentMethods: payload.paymentMethods,
      currency: payload.currency?.trim().toUpperCase(),
    );
  }

  static AiSearchPayload searchPayloadFromJson(
    Map<String, dynamic> json, {
    DateTime? now,
  }) {
    final payload = AiSearchPayload.fromJson(json);
    final inferredPayments = _paymentMethodsFromText(
      '${payload.query} ${payload.periodText ?? ''}',
    );
    final range = _rangeFromText(
      '${payload.query} ${payload.periodText ?? ''}',
      now: now,
    );

    return AiSearchPayload(
      query: payload.query,
      startDate: payload.startDate ?? range?.startDate,
      endDate: payload.endDate ?? range?.endDate,
      categoryNames: payload.categoryNames,
      categoryIds: payload.categoryIds,
      minAmount: payload.minAmount,
      maxAmount: payload.maxAmount,
      paymentMethods: payload.paymentMethods.isEmpty
          ? inferredPayments
          : payload.paymentMethods,
      currency: payload.currency,
      periodText: payload.periodText,
    );
  }

  static ReportRange summaryPayloadToRange(
    AiSummaryPayload payload, {
    DateTime? now,
  }) {
    final rangeFromText = _rangeFromText(payload.periodText, now: now);
    if (rangeFromText != null) return rangeFromText;
    return payload.toReportRange(now: now);
  }

  static List<PaymentMethod> paymentMethodsFromText(String text) {
    return _paymentMethodsFromText(text);
  }

  static ReportRange? rangeFromText(String? text, {DateTime? now}) {
    return _rangeFromText(text, now: now);
  }

  static ReportRange? _rangeFromText(String? text, {DateTime? now}) {
    final normalized = _normalizeText(text ?? '');
    if (normalized.isEmpty) return null;
    final anchor = now ?? DateTime.now();

    if (_containsAny(normalized, const [
      'الشهر ده',
      'هذا الشهر',
      'الشهر الحالي',
      'this month',
    ])) {
      return ReportRange.monthly(anchorDate: anchor);
    }
    if (_containsAny(normalized, const [
      'الشهر اللي فات',
      'الشهر الماضي',
      'last month',
    ])) {
      return ReportRange.monthly(
        anchorDate: DateTime(anchor.year, anchor.month - 1),
      );
    }
    if (_containsAny(normalized, const [
      'الاسبوع ده',
      'الأسبوع ده',
      'هذا الاسبوع',
      'هذا الأسبوع',
      'this week',
    ])) {
      return ReportRange.weekly(anchorDate: anchor);
    }
    if (_containsAny(normalized, const [
      'الاسبوع اللي فات',
      'الأسبوع اللي فات',
      'last week',
    ])) {
      return ReportRange.weekly(
        anchorDate: anchor.subtract(const Duration(days: 7)),
      );
    }
    if (_containsAny(normalized, const ['امبارح', 'أمس', 'yesterday'])) {
      final yesterday = anchor.subtract(const Duration(days: 1));
      return ReportRange.custom(startDate: yesterday, endDate: yesterday);
    }
    if (_containsAny(normalized, const ['النهارده', 'اليوم', 'today'])) {
      return ReportRange.custom(startDate: anchor, endDate: anchor);
    }
    return null;
  }

  static List<PaymentMethod> _paymentMethodsFromText(String text) {
    final normalized = _normalizeText(text);
    final methods = <PaymentMethod>[];
    if (_containsAny(normalized, const ['cash', 'كاش', 'نقد'])) {
      methods.add(PaymentMethod.cash);
    }
    if (_containsAny(normalized, const ['visa', 'فيزا', 'card', 'كارت'])) {
      methods.add(PaymentMethod.visa);
    }
    if (_containsAny(normalized, const ['wallet', 'محفظة', 'فودافون كاش'])) {
      methods.add(PaymentMethod.wallet);
    }
    if (_containsAny(normalized, const [
      'bank transfer',
      'bank_transfer',
      'تحويل بنكي',
      'بنك',
    ])) {
      methods.add(PaymentMethod.bankTransfer);
    }
    return methods;
  }

  static bool _containsAny(String text, List<String> values) {
    return values.any((value) => text.contains(_normalizeText(value)));
  }

  static String _normalizeText(String text) {
    return text
        .trim()
        .toLowerCase()
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه');
  }
}
