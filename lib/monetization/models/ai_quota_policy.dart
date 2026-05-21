import 'package:equatable/equatable.dart';
import 'package:expenses_tracker/ai/models/models.dart';

import 'monetization_plan.dart';

class AiQuotaPolicy extends Equatable {
  const AiQuotaPolicy({
    required this.tier,
    required this.textParseDailyLimit,
    required this.receiptDailyLimit,
    required this.adviceDailyLimit,
    required this.rewardedParseDailyLimit,
    required this.rewardedReceiptDailyLimit,
    required this.rewardedAdviceDailyLimit,
    required this.effectiveFrom,
  });

  final PlanTier tier;
  final int textParseDailyLimit;
  final int receiptDailyLimit;
  final int adviceDailyLimit;
  final int rewardedParseDailyLimit;
  final int rewardedReceiptDailyLimit;
  final int rewardedAdviceDailyLimit;
  final DateTime effectiveFrom;

  static AiQuotaPolicy freeDefaults({DateTime? effectiveFrom}) {
    return AiQuotaPolicy(
      tier: PlanTier.free,
      textParseDailyLimit: 5,
      receiptDailyLimit: 3,
      adviceDailyLimit: 3,
      rewardedParseDailyLimit: 3,
      rewardedReceiptDailyLimit: 1,
      rewardedAdviceDailyLimit: 3,
      effectiveFrom: effectiveFrom ?? DateTime(2026, 5, 17),
    );
  }

  static AiQuotaPolicy premiumDefaults({DateTime? effectiveFrom}) {
    return AiQuotaPolicy(
      tier: PlanTier.premium,
      textParseDailyLimit: 100,
      receiptDailyLimit: 30,
      adviceDailyLimit: 30,
      rewardedParseDailyLimit: 0,
      rewardedReceiptDailyLimit: 0,
      rewardedAdviceDailyLimit: 0,
      effectiveFrom: effectiveFrom ?? DateTime(2026, 5, 17),
    );
  }

  int limitFor(AiUsageRequestType type) {
    switch (type) {
      case AiUsageRequestType.parseText:
        return textParseDailyLimit;
      case AiUsageRequestType.receiptExtraction:
        return receiptDailyLimit;
      case AiUsageRequestType.financialAdvice:
        return adviceDailyLimit;
    }
  }

  int rewardedLimitFor(AiUsageRequestType type) {
    switch (type) {
      case AiUsageRequestType.parseText:
        return rewardedParseDailyLimit;
      case AiUsageRequestType.receiptExtraction:
        return rewardedReceiptDailyLimit;
      case AiUsageRequestType.financialAdvice:
        return rewardedAdviceDailyLimit;
    }
  }

  @override
  List<Object?> get props => [
        tier,
        textParseDailyLimit,
        receiptDailyLimit,
        adviceDailyLimit,
        rewardedParseDailyLimit,
        rewardedReceiptDailyLimit,
        rewardedAdviceDailyLimit,
        effectiveFrom,
      ];
}

class AiQuotaUsage extends Equatable {
  const AiQuotaUsage({
    required this.requestType,
    required this.limit,
    required this.used,
    this.rewardedCreditsAvailable = 0,
    this.resetAt,
    this.isStale = false,
  });

  final AiUsageRequestType requestType;
  final int limit;
  final int used;
  final int rewardedCreditsAvailable;
  final DateTime? resetAt;
  final bool isStale;

  int get remaining =>
      (limit + rewardedCreditsAvailable - used).clamp(0, 1 << 31).toInt();
  bool get exhausted => remaining <= 0;

  factory AiQuotaUsage.fromStatus(
    AiUsageStatus status, {
    required AiQuotaPolicy policy,
    int rewardedCreditsAvailable = 0,
  }) {
    return AiQuotaUsage(
      requestType: status.requestType,
      limit: status.limit ?? policy.limitFor(status.requestType),
      used: status.used ?? 0,
      rewardedCreditsAvailable: rewardedCreditsAvailable,
      resetAt: status.resetAt,
      isStale: false,
    );
  }

  factory AiQuotaUsage.defaultFor({
    required AiUsageRequestType requestType,
    required AiQuotaPolicy policy,
  }) {
    return AiQuotaUsage(
      requestType: requestType,
      limit: policy.limitFor(requestType),
      used: 0,
      resetAt: DateTime.now().toUtc().add(const Duration(days: 1)),
      isStale: true,
    );
  }

  AiQuotaUsage copyWith({
    int? limit,
    int? used,
    int? rewardedCreditsAvailable,
    DateTime? resetAt,
    bool? isStale,
  }) {
    return AiQuotaUsage(
      requestType: requestType,
      limit: limit ?? this.limit,
      used: used ?? this.used,
      rewardedCreditsAvailable:
          rewardedCreditsAvailable ?? this.rewardedCreditsAvailable,
      resetAt: resetAt ?? this.resetAt,
      isStale: isStale ?? this.isStale,
    );
  }

  @override
  List<Object?> get props => [
        requestType,
        limit,
        used,
        rewardedCreditsAvailable,
        resetAt,
        isStale,
      ];
}
