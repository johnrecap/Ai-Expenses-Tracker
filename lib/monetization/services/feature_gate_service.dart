import 'package:expenses_tracker/ai/models/models.dart';

import '../models/models.dart';

class FeatureGateService {
  const FeatureGateService();

  bool canUseManualTracking(EntitlementSnapshot entitlement) => true;

  bool canUseBasicReports(EntitlementSnapshot entitlement) => true;

  bool canUseBasicExports(EntitlementSnapshot entitlement) => true;

  bool canRequestAi(
    AiUsageRequestType type, {
    required EntitlementSnapshot entitlement,
    required MonetizationPolicy policy,
    AiQuotaUsage? usage,
  }) {
    final tier = entitlement.isPremiumActive ? PlanTier.premium : PlanTier.free;
    final effectiveUsage = usage ??
        AiQuotaUsage.defaultFor(
          requestType: type,
          policy: policy.quotaFor(tier),
        );
    return effectiveUsage.remaining > 0;
  }

  bool shouldShowPremiumCta(EntitlementSnapshot entitlement) {
    return !entitlement.isPremiumActive;
  }

  bool shouldReserveBanner({
    required EntitlementSnapshot entitlement,
    required ConsentState consent,
    required MonetizationPolicy policy,
    required AdPlacementKey placementKey,
  }) {
    if (entitlement.shouldDisableAds) return false;
    if (!consent.canRequestAds) return false;
    final placement = policy.placementFor(placementKey);
    return placement != null &&
        placement.format == AdFormat.banner &&
        placement.enabledForFree;
  }

  bool canShowInterstitial({
    required EntitlementSnapshot entitlement,
    required ConsentState consent,
    required MonetizationPolicy policy,
    required AdPlacementKey placementKey,
    required AdFrequencyState frequencyState,
    required DateTime now,
    String? routeName,
  }) {
    if (entitlement.shouldDisableAds) return false;
    if (!consent.canRequestAds) return false;
    final placement = policy.placementFor(placementKey);
    if (placement == null || placement.format != AdFormat.interstitial) {
      return false;
    }
    if (!placement.enabledForFree) return false;
    if (_isBlockedRoute(routeName, placement.blockedRoutes)) return false;
    return frequencyState.canShowInterstitial(
      now: now,
      cap: _capForPlacement(policy.adFrequencyCap, placement),
      requiredCompletedActions: placement.requiredCompletedActions,
    );
  }

  bool canGrantRewardedCredit({
    required EntitlementSnapshot entitlement,
    required ConsentState consent,
    required MonetizationPolicy policy,
    required AdFrequencyState frequencyState,
    required AiUsageRequestType requestType,
  }) {
    if (entitlement.shouldDisableAds) return false;
    if (!consent.canRequestAds) return false;
    if (policy.freeQuota.rewardedLimitFor(requestType) <= 0) return false;
    return frequencyState.canGrantRewardedCredit(policy.adFrequencyCap);
  }

  bool canUseAdvancedReports(EntitlementSnapshot entitlement) {
    return entitlement.isPremiumActive;
  }

  bool canUseLargeExportRange(EntitlementSnapshot entitlement) {
    return entitlement.isPremiumActive;
  }

  bool _isBlockedRoute(String? routeName, List<String> blockedRoutes) {
    if (routeName == null || routeName.trim().isEmpty) return false;
    final route = routeName.toLowerCase();
    return blockedRoutes.any(route.contains);
  }

  AdFrequencyCap _capForPlacement(
    AdFrequencyCap cap,
    AdPlacementPolicy placement,
  ) {
    if (placement.minimumInterval <= cap.minimumInterstitialInterval) {
      return cap;
    }
    return AdFrequencyCap(
      minimumInterstitialInterval: placement.minimumInterval,
      maxInterstitialsPerSession: cap.maxInterstitialsPerSession,
      postSaveExpenseThreshold: cap.postSaveExpenseThreshold,
      maxRewardedCreditsPerDay: cap.maxRewardedCreditsPerDay,
    );
  }
}
