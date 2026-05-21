import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/src/models/ai_action_log.dart';

class AiActionLogEntity {
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

  const AiActionLogEntity({
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

  Map<String, Object?> toDocument() {
    return {
      'actionId': actionId,
      'userId': userId,
      'rawInput': rawInput,
      'parsedResponse': parsedResponse,
      'intent': intent,
      'confidence': confidence,
      'status': status.value,
      'createdAt': createdAt,
      'confirmedAt': confirmedAt,
      'targetExpenseId': targetExpenseId,
      'errorMessage': errorMessage,
      'provider': provider,
      'model': model,
      'providerRequestId': providerRequestId,
      'inputTokens': inputTokens,
      'outputTokens': outputTokens,
      'errorCode': errorCode,
    };
  }

  static AiActionLogEntity fromDocument(Map<String, dynamic> doc) {
    return AiActionLogEntity(
      actionId: doc['actionId'] as String? ?? '',
      userId: doc['userId'] as String? ?? '',
      rawInput: doc['rawInput'] as String? ?? '',
      parsedResponse: _mapFromValue(doc['parsedResponse']),
      intent: doc['intent'] as String? ?? 'unknown',
      confidence: _doubleFromValue(doc['confidence']) ?? 0,
      status: AiActionLogStatus.fromValue(doc['status'] as String?),
      createdAt: _dateTimeFromValue(doc['createdAt']),
      confirmedAt: _nullableDateTimeFromValue(doc['confirmedAt']),
      targetExpenseId: doc['targetExpenseId'] as String?,
      errorMessage: doc['errorMessage'] as String?,
      provider: doc['provider'] as String?,
      model: doc['model'] as String?,
      providerRequestId: doc['providerRequestId'] as String?,
      inputTokens: _intFromValue(doc['inputTokens']),
      outputTokens: _intFromValue(doc['outputTokens']),
      errorCode: doc['errorCode'] as String?,
    );
  }

  static Map<String, Object?> _mapFromValue(Object? value) {
    if (value is Map<String, Object?>) return value;
    if (value is Map) return Map<String, Object?>.from(value);
    return const {};
  }

  static double? _doubleFromValue(Object? value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _intFromValue(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static DateTime _dateTimeFromValue(Object? value) {
    return _nullableDateTimeFromValue(value) ?? DateTime.now();
  }

  static DateTime? _nullableDateTimeFromValue(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
