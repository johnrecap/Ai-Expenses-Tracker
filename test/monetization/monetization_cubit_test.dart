import 'package:expenses_tracker/ai/models/models.dart';
import 'package:expenses_tracker/monetization/monetization.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MonetizationCubit', () {
    test('Loads Free defaults', () async {
      final cubit = MonetizationCubit(
        entitlementRepository: LocalEntitlementRepository(),
        policyRepository: const LocalMonetizationPolicyRepository(),
        consentService:
            FakeAdConsentService(consentState: ConsentState.allowed()),
        adService: FakeAdService(),
      );

      await cubit.load();

      expect(cubit.state.status, MonetizationLoadStatus.ready);
      expect(cubit.state.effectiveTier, PlanTier.free);
      expect(cubit.state.adsInitialized, isTrue);
      await cubit.close();
    });

    test('Loads Premium entitlement and disables ads', () async {
      final adService = FakeAdService();
      final cubit = MonetizationCubit(
        entitlementRepository: LocalEntitlementRepository(
          initialSnapshot: EntitlementSnapshot.premiumFixture(),
        ),
        policyRepository: const LocalMonetizationPolicyRepository(),
        consentService:
            FakeAdConsentService(consentState: ConsentState.allowed()),
        adService: adService,
      );

      await cubit.load();

      expect(cubit.state.effectiveTier, PlanTier.premium);
      expect(cubit.state.adsInitialized, isFalse);
      expect(adService.isInitialized, isFalse);
      expect(adService.initializeCalls, 0);
      expect(adService.bannerLoadCalls, 0);
      expect(adService.interstitialLoadCalls, 0);
      expect(adService.interstitialShows, 0);
      expect(adService.rewardedLoadCalls, 0);
      expect(adService.rewardedShows, 0);
      await cubit.close();
    });

    test('Handles consent failure state without crashing', () async {
      final adService = FakeAdService();
      final cubit = MonetizationCubit(
        entitlementRepository: LocalEntitlementRepository(),
        policyRepository: const LocalMonetizationPolicyRepository(),
        consentService: FakeAdConsentService(
          consentState: ConsentState.unavailable(errorMessage: 'No consent'),
        ),
        adService: adService,
      );

      await cubit.load();

      expect(cubit.state.status, MonetizationLoadStatus.ready);
      expect(cubit.state.consent.canRequestAds, isFalse);
      expect(cubit.state.adsInitialized, isFalse);
      final credit = await cubit.requestRewardedCredit(
        AiUsageRequestType.parseText,
      );
      expect(credit, isNull);
      expect(adService.initializeCalls, 0);
      expect(adService.rewardedLoadCalls, 0);
      expect(adService.rewardedShows, 0);
      await cubit.close();
    });

    test('Refreshes usage after AI action', () async {
      final cubit = MonetizationCubit(
        entitlementRepository: LocalEntitlementRepository(),
        policyRepository: const LocalMonetizationPolicyRepository(),
      );
      await cubit.load();

      cubit.updateUsage(
        const AiUsageStatus(
          requestType: AiUsageRequestType.parseText,
          allowed: true,
          limit: 5,
          used: 2,
          remaining: 3,
        ),
      );

      expect(cubit.state.usageFor(AiUsageRequestType.parseText).used, 2);
      expect(cubit.state.usageFor(AiUsageRequestType.parseText).remaining, 3);
      await cubit.close();
    });

    test('Marks usage stale when provider availability is unknown', () async {
      final cubit = MonetizationCubit(
        entitlementRepository: LocalEntitlementRepository(),
        policyRepository: const LocalMonetizationPolicyRepository(),
      );
      await cubit.load();

      cubit.updateUsage(
        const AiUsageStatus(
          requestType: AiUsageRequestType.receiptExtraction,
          allowed: true,
          limit: 3,
          used: 1,
          remaining: 2,
        ),
      );
      cubit.markUsageStale(AiUsageRequestType.receiptExtraction);

      final usage = cubit.state.usageFor(AiUsageRequestType.receiptExtraction);
      expect(usage.used, 1);
      expect(usage.remaining, 2);
      expect(usage.isStale, isTrue);
      await cubit.close();
    });

    test('Usage snapshot helpers expose known, low, and exhausted states', () {
      final snapshot = AiUsageSnapshot.fromStatus(
        const AiUsageStatus(
          requestType: AiUsageRequestType.parseText,
          allowed: false,
          limit: 5,
          used: 5,
          remaining: 0,
        ),
      );

      expect(snapshot.isKnown, isTrue);
      expect(snapshot.isExhausted, isTrue);
      expect(snapshot.isLow, isFalse);
    });

    test('Handles purchase unavailable state', () async {
      final cubit = MonetizationCubit(
        entitlementRepository: LocalEntitlementRepository(),
        policyRepository: const LocalMonetizationPolicyRepository(),
        purchaseService: const DisabledPurchaseService(),
      );

      final result = await cubit.buyPremium();

      expect(result.status, PurchaseStatus.unavailable);
      expect(cubit.state.purchaseMessage, contains('coming soon'));
      await cubit.close();
    });

    test('Surfaces backend-unavailable entitlement as Free-safe state',
        () async {
      final cubit = MonetizationCubit(
        entitlementRepository: LocalEntitlementRepository(
          initialSnapshot: EntitlementSnapshot.freeDefault().copyWith(
            status: EntitlementStatus.unavailable,
            reason: 'Verification backend unavailable.',
          ),
        ),
        policyRepository: const LocalMonetizationPolicyRepository(),
      );

      await cubit.load();

      expect(cubit.state.status, MonetizationLoadStatus.entitlementUnavailable);
      expect(cubit.state.effectiveTier, PlanTier.free);
      expect(cubit.state.entitlement.isPremiumActive, isFalse);
      await cubit.close();
    });

    test('Applies verified backend entitlement through cubit', () async {
      final cubit = MonetizationCubit(
        entitlementRepository: _VerifiedRepository(),
        policyRepository: const LocalMonetizationPolicyRepository(),
      );

      final result = await cubit.verifyPurchaseWithBackend(
        const PurchaseVerificationRequest(
          platform: PurchasePlatform.googlePlay,
          productId: DisabledPurchaseService.premiumMonthlyProductId,
          purchaseToken: 'token',
          clientRequestId: 'client-request',
        ),
      );

      expect(result.verified, isTrue);
      expect(cubit.state.effectiveTier, PlanTier.premium);
      expect(cubit.state.entitlement.shouldDisableAds, isTrue);
      await cubit.close();
    });

    test('Export interstitial is shown only after explicit completion hook',
        () async {
      final adService = FakeAdService();
      final cubit = MonetizationCubit(
        entitlementRepository: LocalEntitlementRepository(),
        policyRepository: const LocalMonetizationPolicyRepository(),
        consentService:
            FakeAdConsentService(consentState: ConsentState.allowed()),
        adService: adService,
      );
      await cubit.load();

      expect(adService.interstitialShows, 0);

      final shown = await cubit.maybeShowInterstitial(
        AdPlacementKey.exportInterstitial,
        routeName: '/export/completed',
      );

      expect(shown, isTrue);
      expect(adService.interstitialShows, 1);
      expect(cubit.state.frequencyState.interstitialsShownThisSession, 1);
      await cubit.close();
    });

    test('Post-save interstitial waits for save threshold', () async {
      final adService = FakeAdService();
      final cubit = MonetizationCubit(
        entitlementRepository: LocalEntitlementRepository(),
        policyRepository: const LocalMonetizationPolicyRepository(),
        consentService:
            FakeAdConsentService(consentState: ConsentState.allowed()),
        adService: adService,
      );
      await cubit.load();

      for (var i = 0; i < 4; i += 1) {
        final shown = await cubit.recordCompletedSaveAndMaybeShowInterstitial(
          routeName: '/home/post_save',
        );
        expect(shown, isFalse);
      }

      expect(adService.interstitialShows, 0);

      final shown = await cubit.recordCompletedSaveAndMaybeShowInterstitial(
        routeName: '/home/post_save',
      );

      expect(shown, isTrue);
      expect(adService.interstitialShows, 1);
      expect(cubit.state.frequencyState.completedSavesSinceInterstitial, 0);
      await cubit.close();
    });
  });
}

class _VerifiedRepository extends LocalEntitlementRepository {
  @override
  Future<PurchaseVerificationResult> verifyPurchase(
    PurchaseVerificationRequest request,
  ) async {
    final result = PurchaseVerificationResult(
      status: EntitlementVerificationStatus.verified,
      entitlement: VerifiedEntitlement(
        userId: 'user-1',
        tier: PlanTier.premium,
        status: EntitlementStatus.active,
        source: EntitlementSource.storeVerified,
        lastVerifiedAt: DateTime(2026, 5, 20),
        productId: request.productId,
      ),
    );
    setFixture(result.snapshot);
    return result;
  }
}
