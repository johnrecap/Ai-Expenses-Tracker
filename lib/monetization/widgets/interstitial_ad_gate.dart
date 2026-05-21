import '../models/models.dart';
import '../services/services.dart';

class InterstitialAdGate {
  InterstitialAdGate({
    required this.adService,
    this.featureGateService = const FeatureGateService(),
  });

  final AdService adService;
  final FeatureGateService featureGateService;

  Future<AdFrequencyState> maybeShow({
    required EntitlementSnapshot entitlement,
    required ConsentState consent,
    required MonetizationPolicy policy,
    required AdFrequencyState frequencyState,
    required AdPlacementKey placementKey,
    required DateTime now,
    String? routeName,
  }) async {
    final allowed = featureGateService.canShowInterstitial(
      entitlement: entitlement,
      consent: consent,
      policy: policy,
      placementKey: placementKey,
      frequencyState: frequencyState,
      now: now,
      routeName: routeName,
    );
    if (!allowed) return frequencyState;
    if (!adService.isInitialized) {
      await adService.initialize();
    }
    final loaded = await adService.loadInterstitial(placementKey);
    if (!loaded) return frequencyState;
    final shown = await adService.showInterstitial(placementKey);
    return shown ? frequencyState.recordInterstitial(now) : frequencyState;
  }
}
