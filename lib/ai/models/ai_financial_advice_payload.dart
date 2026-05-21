import 'ai_provider_metadata.dart';
import 'ai_usage_status.dart';

class AiFinancialAdvicePayload {
  const AiFinancialAdvicePayload({
    required this.period,
    required this.groundedSummary,
    required this.advice,
    required this.categoryDrivers,
    required this.confidence,
    required this.generatedAt,
    this.qualityNote,
    this.usageStatus,
    this.providerMetadata,
  });

  final String period;
  final String groundedSummary;
  final String advice;
  final List<AiAdviceCategoryDriver> categoryDrivers;
  final double confidence;
  final DateTime generatedAt;
  final String? qualityNote;
  final AiUsageStatus? usageStatus;
  final AiProviderMetadata? providerMetadata;

  factory AiFinancialAdvicePayload.fromJson(
    Map<String, dynamic> json, {
    AiUsageStatus? usageStatus,
    AiProviderMetadata? providerMetadata,
    DateTime? generatedAt,
  }) {
    return AiFinancialAdvicePayload(
      period: json['period'] as String? ?? 'month',
      groundedSummary: json['groundedSummary'] as String? ?? '',
      advice: json['advice'] as String? ?? '',
      categoryDrivers: (json['categoryDrivers'] as List? ?? const [])
          .whereType<Map>()
          .map((item) => AiAdviceCategoryDriver.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList(),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      generatedAt: generatedAt ?? DateTime.now(),
      qualityNote: json['qualityNote'] as String?,
      usageStatus: usageStatus,
      providerMetadata: providerMetadata,
    );
  }
}

class AiAdviceCategoryDriver {
  const AiAdviceCategoryDriver({
    required this.category,
    required this.amount,
    this.currency,
    this.note,
  });

  final String category;
  final double amount;
  final String? currency;
  final String? note;

  factory AiAdviceCategoryDriver.fromJson(Map<String, dynamic> json) {
    return AiAdviceCategoryDriver(
      category: json['category'] as String? ?? 'Unknown',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String?,
      note: json['note'] as String?,
    );
  }
}
