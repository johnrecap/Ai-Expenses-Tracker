part of 'monetization_cubit.dart';

enum MonetizationLoadStatus {
  initial,
  loading,
  ready,
  failure,
  entitlementUnavailable,
}

class MonetizationState extends Equatable {
  const MonetizationState({
    required this.status,
    required this.entitlement,
    required this.policy,
    required this.quotaUsage,
    required this.consent,
    required this.frequencyState,
    required this.rewardedCredits,
    required this.adsInitialized,
    this.errorMessage,
    this.purchaseMessage,
  });

  final MonetizationLoadStatus status;
  final EntitlementSnapshot entitlement;
  final MonetizationPolicy policy;
  final Map<AiUsageRequestType, AiQuotaUsage> quotaUsage;
  final ConsentState consent;
  final AdFrequencyState frequencyState;
  final List<RewardedAdCredit> rewardedCredits;
  final bool adsInitialized;
  final String? errorMessage;
  final String? purchaseMessage;

  factory MonetizationState.initial() {
    final policy = MonetizationPolicy.defaults();
    return MonetizationState(
      status: MonetizationLoadStatus.initial,
      entitlement: EntitlementSnapshot.freeDefault(),
      policy: policy,
      quotaUsage: {
        for (final type in AiUsageRequestType.values)
          type: AiQuotaUsage.defaultFor(
            requestType: type,
            policy: policy.freeQuota,
          ),
      },
      consent: ConsentState.unavailable(),
      frequencyState: const AdFrequencyState(),
      rewardedCredits: const [],
      adsInitialized: false,
    );
  }

  PlanTier get effectiveTier {
    return entitlement.isPremiumActive ? PlanTier.premium : PlanTier.free;
  }

  AiQuotaUsage usageFor(AiUsageRequestType requestType) {
    return quotaUsage[requestType] ??
        AiQuotaUsage.defaultFor(
          requestType: requestType,
          policy: policy.quotaFor(effectiveTier),
        );
  }

  MonetizationState copyWith({
    MonetizationLoadStatus? status,
    EntitlementSnapshot? entitlement,
    MonetizationPolicy? policy,
    Map<AiUsageRequestType, AiQuotaUsage>? quotaUsage,
    ConsentState? consent,
    AdFrequencyState? frequencyState,
    List<RewardedAdCredit>? rewardedCredits,
    bool? adsInitialized,
    String? errorMessage,
    bool clearError = false,
    String? purchaseMessage,
  }) {
    return MonetizationState(
      status: status ?? this.status,
      entitlement: entitlement ?? this.entitlement,
      policy: policy ?? this.policy,
      quotaUsage: quotaUsage ?? this.quotaUsage,
      consent: consent ?? this.consent,
      frequencyState: frequencyState ?? this.frequencyState,
      rewardedCredits: rewardedCredits ?? this.rewardedCredits,
      adsInitialized: adsInitialized ?? this.adsInitialized,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      purchaseMessage: purchaseMessage ?? this.purchaseMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        entitlement,
        policy,
        quotaUsage,
        consent,
        frequencyState,
        rewardedCredits,
        adsInitialized,
        errorMessage,
        purchaseMessage,
      ];
}
