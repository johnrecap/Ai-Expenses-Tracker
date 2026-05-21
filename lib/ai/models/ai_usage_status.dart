enum AiUsageRequestType {
  parseText('parse_text'),
  receiptExtraction('receipt_extraction'),
  financialAdvice('financial_advice');

  const AiUsageRequestType(this.value);

  final String value;

  static AiUsageRequestType fromValue(String? value) {
    for (final type in AiUsageRequestType.values) {
      if (type.value == value) return type;
    }
    return AiUsageRequestType.parseText;
  }

  String get label {
    switch (this) {
      case AiUsageRequestType.parseText:
        return 'Text parsing';
      case AiUsageRequestType.receiptExtraction:
        return 'Receipt scans';
      case AiUsageRequestType.financialAdvice:
        return 'Financial advice';
    }
  }
}

enum AiFallbackReason {
  none,
  aiDisabled,
  functionsUnavailable,
  quotaExhausted,
  providerFailed,
  lowConfidence,
  invalidInput,
}

class AiUsageStatus {
  const AiUsageStatus({
    required this.requestType,
    required this.allowed,
    this.limit,
    this.used,
    this.remaining,
    this.resetAt,
    this.fallbackReason = AiFallbackReason.none,
    this.message,
  });

  final AiUsageRequestType requestType;
  final bool allowed;
  final int? limit;
  final int? used;
  final int? remaining;
  final DateTime? resetAt;
  final AiFallbackReason fallbackReason;
  final String? message;

  factory AiUsageStatus.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AiUsageStatus(
        requestType: AiUsageRequestType.parseText,
        allowed: true,
      );
    }
    return AiUsageStatus(
      requestType: AiUsageRequestType.fromValue(json['requestType'] as String?),
      allowed: json['allowed'] != false,
      limit: _readInt(json['limit']),
      used: _readInt(json['used']),
      remaining: _readInt(json['remaining']),
      resetAt: DateTime.tryParse(json['resetAt'] as String? ?? ''),
    );
  }

  AiUsageStatus copyWith({
    bool? allowed,
    AiFallbackReason? fallbackReason,
    String? message,
  }) {
    return AiUsageStatus(
      requestType: requestType,
      allowed: allowed ?? this.allowed,
      limit: limit,
      used: used,
      remaining: remaining,
      resetAt: resetAt,
      fallbackReason: fallbackReason ?? this.fallbackReason,
      message: message ?? this.message,
    );
  }

  static int? _readInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return null;
  }
}

enum AiUsageSnapshotSource {
  worker,
  cached,
  defaultPolicy,
  unknown,
}

class AiUsageSnapshot {
  const AiUsageSnapshot({
    required this.requestType,
    required this.source,
    this.used,
    this.limit,
    this.remaining,
    this.resetAt,
    this.isStale = false,
  });

  final AiUsageRequestType requestType;
  final int? used;
  final int? limit;
  final int? remaining;
  final DateTime? resetAt;
  final AiUsageSnapshotSource source;
  final bool isStale;

  bool get isKnown => used != null || limit != null || remaining != null;
  bool get isExhausted => remaining != null && remaining! <= 0;
  bool get isLow {
    final effectiveRemaining = remaining;
    final effectiveLimit = limit;
    if (effectiveRemaining == null || effectiveLimit == null) return false;
    if (effectiveRemaining <= 0) return false;
    return effectiveRemaining <= 1 ||
        effectiveLimit > 0 && effectiveRemaining / effectiveLimit <= 0.2;
  }

  factory AiUsageSnapshot.fromStatus(
    AiUsageStatus status, {
    AiUsageSnapshotSource source = AiUsageSnapshotSource.worker,
    bool isStale = false,
  }) {
    return AiUsageSnapshot(
      requestType: status.requestType,
      used: status.used,
      limit: status.limit,
      remaining: status.remaining,
      resetAt: status.resetAt,
      source: source,
      isStale: isStale,
    );
  }
}
