import 'ai_expense_payload.dart';
import 'ai_intent.dart';
import 'ai_advice_payload.dart';
import 'ai_provider_metadata.dart';
import 'ai_search_payload.dart';
import 'ai_summary_payload.dart';
import 'ai_usage_status.dart';

class AiResponse {
  const AiResponse({
    required this.intent,
    required this.confidence,
    required this.needsConfirmation,
    required this.rawJson,
    this.expensePayload,
    this.searchPayload,
    this.summaryPayload,
    this.advicePayload,
    this.clarifyingQuestion,
    this.providerMetadata,
    this.usageStatus,
    this.errorCode,
  });

  final AiIntent intent;
  final AiExpensePayload? expensePayload;
  final AiSearchPayload? searchPayload;
  final AiSummaryPayload? summaryPayload;
  final AiAdvicePayload? advicePayload;
  final double confidence;
  final bool needsConfirmation;
  final String? clarifyingQuestion;
  final AiProviderMetadata? providerMetadata;
  final AiUsageStatus? usageStatus;
  final String? errorCode;
  final String rawJson;

  bool get requiresClarification {
    if (intent == AiIntent.addExpense) return false;
    return confidence < 0.75 || intent == AiIntent.unknown;
  }

  AiResponse copyWith({
    AiIntent? intent,
    AiExpensePayload? expensePayload,
    AiSearchPayload? searchPayload,
    AiSummaryPayload? summaryPayload,
    AiAdvicePayload? advicePayload,
    double? confidence,
    bool? needsConfirmation,
    String? clarifyingQuestion,
    AiProviderMetadata? providerMetadata,
    AiUsageStatus? usageStatus,
    String? errorCode,
    String? rawJson,
  }) {
    return AiResponse(
      intent: intent ?? this.intent,
      expensePayload: expensePayload ?? this.expensePayload,
      searchPayload: searchPayload ?? this.searchPayload,
      summaryPayload: summaryPayload ?? this.summaryPayload,
      advicePayload: advicePayload ?? this.advicePayload,
      confidence: confidence ?? this.confidence,
      needsConfirmation: needsConfirmation ?? this.needsConfirmation,
      clarifyingQuestion: clarifyingQuestion ?? this.clarifyingQuestion,
      providerMetadata: providerMetadata ?? this.providerMetadata,
      usageStatus: usageStatus ?? this.usageStatus,
      errorCode: errorCode ?? this.errorCode,
      rawJson: rawJson ?? this.rawJson,
    );
  }
}
