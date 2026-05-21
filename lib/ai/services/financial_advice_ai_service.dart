import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/services/report_calculator.dart';

import '../models/models.dart';
import 'ai_gateway_client.dart';
import 'ai_gateway_error.dart';
import 'ai_service.dart';
import 'ai_usage_fallback_service.dart';

abstract class FinancialAdviceAiService {
  Future<AiFinancialAdvicePayload> requestAdvice({
    required String period,
    required AiContext context,
  });
}

class GatewayFinancialAdviceAiService implements FinancialAdviceAiService {
  GatewayFinancialAdviceAiService({
    required AiGatewayClient client,
    AiUsageFallbackService fallbackService = const AiUsageFallbackService(),
  })  : _client = client,
        _fallbackService = fallbackService;

  final AiGatewayClient _client;
  final AiUsageFallbackService _fallbackService;

  static final Map<String, AiFinancialAdvicePayload> _cache = {};

  @override
  Future<AiFinancialAdvicePayload> requestAdvice({
    required String period,
    required AiContext context,
  }) async {
    final normalizedPeriod = period == 'week' ? 'week' : 'month';
    final summary = buildAdviceSummary(
      period: normalizedPeriod,
      context: context,
    );
    final cacheKey =
        _cacheKey(context.userId, normalizedPeriod, summary, context.now);
    final cached = _cache[cacheKey];
    if (cached != null) return cached;

    try {
      final result = await _client.financialAdvice(
        period: normalizedPeriod,
        summary: summary,
        context: context,
      );
      final payload = AiFinancialAdvicePayload.fromJson(
        result.structuredJson,
        usageStatus: result.usageStatus == null
            ? null
            : AiUsageStatus.fromJson(result.usageStatus),
        providerMetadata: result.metadata,
        generatedAt: context.now,
      );
      _cache[cacheKey] = payload;
      return payload;
    } on AiGatewayException catch (error) {
      final status = _fallbackService.fromGatewayError(
        error,
        AiUsageRequestType.financialAdvice,
      );
      return _localFallbackAdvice(
        period: normalizedPeriod,
        summary: summary,
        status: status,
        now: context.now,
      );
    }
  }
}

Map<String, Object?> buildAdviceSummary({
  required String period,
  required AiContext context,
}) {
  final range = period == 'week'
      ? ReportRange.weekly(anchorDate: context.now)
      : ReportRange.monthly(anchorDate: context.now);
  final report = ReportCalculator.calculate(
    expenses: context.expenses,
    range: range,
    settings: context.effectiveSettings,
  );
  return {
    'period': period,
    'startDate': range.startDate.toIso8601String(),
    'endDate': range.endDate.toIso8601String(),
    'currency': report.currency,
    'total': report.total,
    'previousTotal': report.previousTotal,
    'deltaPercent': report.deltaPercent,
    'topCategory': report.topCategory?.categoryName,
    'categoryTotals': report.categoryTotals
        .take(5)
        .map((total) => {
              'category': total.categoryName,
              'amount': total.total,
            })
        .toList(),
    'budget': context.budget == null
        ? null
        : {
            'amount': context.budget!.amount,
            'currency': context.budget!.currency,
            'month': '${context.budget!.year}-${context.budget!.month}',
          },
  };
}

AiFinancialAdvicePayload _localFallbackAdvice({
  required String period,
  required Map<String, Object?> summary,
  required AiUsageStatus status,
  required DateTime now,
}) {
  final total = (summary['total'] as num?)?.toDouble() ?? 0;
  final currency = summary['currency'] as String? ?? 'EGP';
  final topCategory = summary['topCategory'] as String?;
  final advice = topCategory == null
      ? 'No AI advice is available now. You can still track expenses manually and review local reports.'
      : 'AI advice is unavailable now. Locally, your highest spending area is $topCategory. Review it before adding more discretionary spending.';
  return AiFinancialAdvicePayload(
    period: period,
    groundedSummary: 'Local total: ${total.toStringAsFixed(0)} $currency.',
    advice: advice,
    categoryDrivers: [
      if (topCategory != null)
        AiAdviceCategoryDriver(
          category: topCategory,
          amount: total,
          currency: currency,
          note: 'Local fallback based on current report total.',
        ),
    ],
    confidence: 0,
    qualityNote: status.message,
    usageStatus: status,
    generatedAt: now,
  );
}

String _cacheKey(
  String? userId,
  String period,
  Map<String, Object?> summary,
  DateTime now,
) {
  final dateKey = '${now.year}-${now.month}-${now.day}';
  final digest = sha256.convert(utf8.encode(jsonEncode(summary))).toString();
  return '${userId ?? 'anonymous'}:$period:$dateKey:$digest';
}
