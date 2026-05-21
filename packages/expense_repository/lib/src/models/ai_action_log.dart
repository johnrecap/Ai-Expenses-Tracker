import '../entities/ai_action_log_entity.dart';

enum AiActionLogStatus {
  previewed,
  confirmed,
  canceled,
  failed;

  String get value {
    switch (this) {
      case AiActionLogStatus.previewed:
        return 'previewed';
      case AiActionLogStatus.confirmed:
        return 'confirmed';
      case AiActionLogStatus.canceled:
        return 'canceled';
      case AiActionLogStatus.failed:
        return 'failed';
    }
  }

  static AiActionLogStatus fromValue(String? value) {
    switch (value) {
      case 'confirmed':
        return AiActionLogStatus.confirmed;
      case 'canceled':
        return AiActionLogStatus.canceled;
      case 'failed':
        return AiActionLogStatus.failed;
      case 'previewed':
      default:
        return AiActionLogStatus.previewed;
    }
  }
}

class AiActionLog {
  final String actionId;
  final String userId;
  final String rawInput;
  final Map<String, Object?> parsedResponse;
  final String intent;
  final double confidence;
  final AiActionLogStatus status;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final String? targetExpenseId;
  final String? errorMessage;
  final String? provider;
  final String? model;
  final String? providerRequestId;
  final int? inputTokens;
  final int? outputTokens;
  final String? errorCode;

  const AiActionLog({
    required this.actionId,
    required this.userId,
    required this.rawInput,
    required this.parsedResponse,
    required this.intent,
    required this.confidence,
    required this.status,
    required this.createdAt,
    this.confirmedAt,
    this.targetExpenseId,
    this.errorMessage,
    this.provider,
    this.model,
    this.providerRequestId,
    this.inputTokens,
    this.outputTokens,
    this.errorCode,
  });

  AiActionLog copyWith({
    String? actionId,
    String? userId,
    String? rawInput,
    Map<String, Object?>? parsedResponse,
    String? intent,
    double? confidence,
    AiActionLogStatus? status,
    DateTime? createdAt,
    DateTime? confirmedAt,
    String? targetExpenseId,
    String? errorMessage,
    String? provider,
    String? model,
    String? providerRequestId,
    int? inputTokens,
    int? outputTokens,
    String? errorCode,
  }) {
    return AiActionLog(
      actionId: actionId ?? this.actionId,
      userId: userId ?? this.userId,
      rawInput: rawInput ?? this.rawInput,
      parsedResponse: parsedResponse ?? this.parsedResponse,
      intent: intent ?? this.intent,
      confidence: confidence ?? this.confidence,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      targetExpenseId: targetExpenseId ?? this.targetExpenseId,
      errorMessage: errorMessage ?? this.errorMessage,
      provider: provider ?? this.provider,
      model: model ?? this.model,
      providerRequestId: providerRequestId ?? this.providerRequestId,
      inputTokens: inputTokens ?? this.inputTokens,
      outputTokens: outputTokens ?? this.outputTokens,
      errorCode: errorCode ?? this.errorCode,
    );
  }

  AiActionLogEntity toEntity() {
    return AiActionLogEntity(
      actionId: actionId,
      userId: userId,
      rawInput: rawInput,
      parsedResponse: parsedResponse,
      intent: intent,
      confidence: confidence,
      status: status,
      createdAt: createdAt,
      confirmedAt: confirmedAt,
      targetExpenseId: targetExpenseId,
      errorMessage: errorMessage,
      provider: provider,
      model: model,
      providerRequestId: providerRequestId,
      inputTokens: inputTokens,
      outputTokens: outputTokens,
      errorCode: errorCode,
    );
  }

  static AiActionLog fromEntity(AiActionLogEntity entity) {
    return AiActionLog(
      actionId: entity.actionId,
      userId: entity.userId,
      rawInput: entity.rawInput,
      parsedResponse: entity.parsedResponse,
      intent: entity.intent,
      confidence: entity.confidence,
      status: entity.status,
      createdAt: entity.createdAt,
      confirmedAt: entity.confirmedAt,
      targetExpenseId: entity.targetExpenseId,
      errorMessage: entity.errorMessage,
      provider: entity.provider,
      model: entity.model,
      providerRequestId: entity.providerRequestId,
      inputTokens: entity.inputTokens,
      outputTokens: entity.outputTokens,
      errorCode: entity.errorCode,
    );
  }
}
