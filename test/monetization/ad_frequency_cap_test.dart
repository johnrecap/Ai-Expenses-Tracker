import 'package:expenses_tracker/monetization/monetization.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdFrequencyState', () {
    const cap = AdFrequencyCap();
    // ignore: prefer_const_declarations
    final now = DateTime(2026, 5, 17, 12);

    test('First eligible interstitial can show', () {
      expect(
        const AdFrequencyState().canShowInterstitial(
          now: now,
          cap: cap,
        ),
        isTrue,
      );
    });

    test('Second interstitial inside ten minutes is blocked', () {
      final state = const AdFrequencyState().recordInterstitial(now);

      expect(
        state.canShowInterstitial(
          now: now.add(const Duration(minutes: 5)),
          cap: cap,
        ),
        isFalse,
      );
    });

    test('Session max blocks further interstitials', () {
      final state = AdFrequencyState(
        interstitialsShownThisSession: cap.maxInterstitialsPerSession,
      );

      expect(
        state.canShowInterstitial(now: now, cap: cap),
        isFalse,
      );
    });

    test('Post-save count threshold works', () {
      const below = AdFrequencyState(completedSavesSinceInterstitial: 4);
      final ready = below.recordCompletedSave();

      expect(
        below.canShowInterstitial(
          now: now,
          cap: cap,
          requiredCompletedActions: 5,
        ),
        isFalse,
      );
      expect(
        ready.canShowInterstitial(
          now: now,
          cap: cap,
          requiredCompletedActions: 5,
        ),
        isTrue,
      );
    });

    test('Premium blocks regardless of counters through feature gate', () {
      const service = FeatureGateService();
      expect(
        service.canShowInterstitial(
          entitlement: EntitlementSnapshot.premiumFixture(),
          consent: ConsentState.allowed(),
          policy: MonetizationPolicy.defaults(),
          placementKey: AdPlacementKey.exportInterstitial,
          frequencyState:
              const AdFrequencyState(completedSavesSinceInterstitial: 99),
          now: now,
        ),
        isFalse,
      );
    });
  });
}
