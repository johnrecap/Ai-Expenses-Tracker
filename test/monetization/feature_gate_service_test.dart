import 'package:expenses_tracker/ai/models/models.dart';
import 'package:expenses_tracker/monetization/monetization.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FeatureGateService', () {
    const service = FeatureGateService();

    test('Free user keeps manual tracking enabled', () {
      expect(
        service.canUseManualTracking(EntitlementSnapshot.freeDefault()),
        isTrue,
      );
    });

    test('Free user keeps core reports and exports enabled', () {
      final entitlement = EntitlementSnapshot.freeDefault();

      expect(service.canUseBasicReports(entitlement), isTrue);
      expect(service.canUseBasicExports(entitlement), isTrue);
    });

    test('Free user can reserve banner when consent allows', () {
      expect(
        service.shouldReserveBanner(
          entitlement: EntitlementSnapshot.freeDefault(),
          consent: ConsentState.allowed(),
          policy: MonetizationPolicy.defaults(),
          placementKey: AdPlacementKey.homeBanner,
        ),
        isTrue,
      );
    });

    test('Premium user never reserves banner', () {
      expect(
        service.shouldReserveBanner(
          entitlement: EntitlementSnapshot.premiumFixture(),
          consent: ConsentState.allowed(),
          policy: MonetizationPolicy.defaults(),
          placementKey: AdPlacementKey.homeBanner,
        ),
        isFalse,
      );
    });

    test('Unknown entitlement defaults safely to non-premium ads behavior', () {
      final entitlement = EntitlementSnapshot(
        tier: PlanTier.unknown,
        source: EntitlementSource.localCache,
        updatedAt: DateTime(2026, 5, 17),
      );

      expect(
        service.shouldReserveBanner(
          entitlement: entitlement,
          consent: ConsentState.allowed(),
          policy: MonetizationPolicy.defaults(),
          placementKey: AdPlacementKey.homeBanner,
        ),
        isTrue,
      );
    });

    test('Quota exhausted blocks only the AI action', () {
      final policy = MonetizationPolicy.defaults();
      final usage = AiQuotaUsage(
        requestType: AiUsageRequestType.parseText,
        limit: policy.freeQuota.textParseDailyLimit,
        used: policy.freeQuota.textParseDailyLimit,
      );

      expect(
        service.canRequestAi(
          AiUsageRequestType.parseText,
          entitlement: EntitlementSnapshot.freeDefault(),
          policy: policy,
          usage: usage,
        ),
        isFalse,
      );
      expect(
        service.canUseManualTracking(EntitlementSnapshot.freeDefault()),
        isTrue,
      );
      expect(
        service.canUseBasicReports(EntitlementSnapshot.freeDefault()),
        isTrue,
      );
    });

    test('Rewarded credit can add one allowed AI action', () {
      final policy = MonetizationPolicy.defaults();
      final usage = AiQuotaUsage(
        requestType: AiUsageRequestType.parseText,
        limit: policy.freeQuota.textParseDailyLimit,
        used: policy.freeQuota.textParseDailyLimit,
        rewardedCreditsAvailable: 1,
      );

      expect(
        service.canRequestAi(
          AiUsageRequestType.parseText,
          entitlement: EntitlementSnapshot.freeDefault(),
          policy: policy,
          usage: usage,
        ),
        isTrue,
      );
    });

    test('Critical routes block interstitials', () {
      expect(
        service.canShowInterstitial(
          entitlement: EntitlementSnapshot.freeDefault(),
          consent: ConsentState.allowed(),
          policy: MonetizationPolicy.defaults(),
          placementKey: AdPlacementKey.exportInterstitial,
          frequencyState: const AdFrequencyState(),
          now: DateTime(2026, 5, 17, 12),
          routeName: '/add_expense',
        ),
        isFalse,
      );
    });
  });
}
