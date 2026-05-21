import 'package:expenses_tracker/ai/models/models.dart';
import 'package:expenses_tracker/monetization/monetization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Banner reserves height for Free', (tester) async {
    final adService = FakeAdService();
    await adService.initialize();

    await tester.pumpWidget(
      MaterialApp(
        home: Align(
          alignment: Alignment.topCenter,
          child: AdaptiveBannerAdSlot(
            placementKey: AdPlacementKey.homeBanner,
            enabled: true,
            adService: adService,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      tester
          .getSize(
              find.byKey(const ValueKey('adaptive_banner_slot_homeBanner')))
          .height,
      56,
    );
  });

  testWidgets('Banner hides for Premium', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveBannerAdSlot(
          placementKey: AdPlacementKey.homeBanner,
          enabled: false,
          adService: FakeAdService(),
        ),
      ),
    );

    expect(find.byType(SizedBox), findsOneWidget);
  });

  testWidgets('Failed banner load does not crash', (tester) async {
    final adService = FakeAdService(failLoads: true);
    await adService.initialize();

    await tester.pumpWidget(
      MaterialApp(
        home: Align(
          alignment: Alignment.topCenter,
          child: AdaptiveBannerAdSlot(
            placementKey: AdPlacementKey.homeBanner,
            enabled: true,
            adService: adService,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('Monetization banner reserves only when consent allows',
      (tester) async {
    final adService = FakeAdService();
    final cubit = MonetizationCubit(
      entitlementRepository: LocalEntitlementRepository(),
      policyRepository: const LocalMonetizationPolicyRepository(),
      consentService:
          FakeAdConsentService(consentState: ConsentState.allowed()),
      adService: adService,
    );
    await cubit.load();

    await tester.pumpWidget(
      RepositoryProvider<AdService>.value(
        value: adService,
        child: BlocProvider.value(
          value: cubit,
          child: const MaterialApp(
            home: MonetizationBannerAdSlot(
              placementKey: AdPlacementKey.expensesBanner,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const ValueKey('adaptive_banner_slot_expensesBanner')),
      findsOneWidget,
    );
    await cubit.close();
  });

  testWidgets('Monetization banner hides for denied consent', (tester) async {
    final adService = FakeAdService();
    final cubit = MonetizationCubit(
      entitlementRepository: LocalEntitlementRepository(),
      policyRepository: const LocalMonetizationPolicyRepository(),
      consentService:
          FakeAdConsentService(consentState: ConsentState.unavailable()),
      adService: adService,
    );
    await cubit.load();

    await tester.pumpWidget(
      RepositoryProvider<AdService>.value(
        value: adService,
        child: BlocProvider.value(
          value: cubit,
          child: const MaterialApp(
            home: MonetizationBannerAdSlot(
              placementKey: AdPlacementKey.reportsBanner,
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('adaptive_banner_slot_reportsBanner')),
      findsNothing,
    );
    expect(adService.bannerLoadCalls, 0);
    await cubit.close();
  });

  testWidgets('Monetization banner hides for verified Premium', (tester) async {
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

    await tester.pumpWidget(
      RepositoryProvider<AdService>.value(
        value: adService,
        child: BlocProvider.value(
          value: cubit,
          child: const MaterialApp(
            home: MonetizationBannerAdSlot(
              placementKey: AdPlacementKey.homeBanner,
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('adaptive_banner_slot_homeBanner')),
      findsNothing,
    );
    expect(adService.initializeCalls, 0);
    expect(adService.bannerLoadCalls, 0);
    await cubit.close();
  });

  test('Interstitial gate blocks critical route', () async {
    final adService = FakeAdService();
    final gate = InterstitialAdGate(adService: adService);
    final state = await gate.maybeShow(
      entitlement: EntitlementSnapshot.freeDefault(),
      consent: ConsentState.allowed(),
      policy: MonetizationPolicy.defaults(),
      frequencyState: const AdFrequencyState(),
      placementKey: AdPlacementKey.exportInterstitial,
      now: DateTime(2026, 5, 17, 12),
      routeName: '/ai_preview',
    );

    expect(state.interstitialsShownThisSession, 0);
  });

  test('Rewarded button grants only from reward callback through cubit',
      () async {
    final cubit = MonetizationCubit(
      entitlementRepository: LocalEntitlementRepository(),
      policyRepository: const LocalMonetizationPolicyRepository(),
      consentService:
          FakeAdConsentService(consentState: ConsentState.allowed()),
      adService: FakeAdService(),
    );
    await cubit.load();

    final credit = await cubit.requestRewardedCredit(
      AiUsageRequestType.parseText,
    );

    expect(credit, isNotNull);
    expect(cubit.state.rewardedCredits, hasLength(1));
    await cubit.close();
  });
}
