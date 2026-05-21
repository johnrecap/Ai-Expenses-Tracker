import '../models/models.dart';
import 'ad_consent_service.dart';
import 'ad_service.dart';

class GoogleMobileAdsConfig {
  const GoogleMobileAdsConfig({
    this.enableProductionAds = false,
    this.androidBannerUnitId = '',
    this.iosBannerUnitId = '',
    this.androidInterstitialUnitId = '',
    this.iosInterstitialUnitId = '',
    this.androidRewardedUnitId = '',
    this.iosRewardedUnitId = '',
  });

  static const androidTestAppId = 'ca-app-pub-3940256099942544~3347511713';
  static const iosTestAppId = 'ca-app-pub-3940256099942544~1458002511';

  final bool enableProductionAds;
  final String androidBannerUnitId;
  final String iosBannerUnitId;
  final String androidInterstitialUnitId;
  final String iosInterstitialUnitId;
  final String androidRewardedUnitId;
  final String iosRewardedUnitId;

  String? unitIdFor(AdPlacementKey placementKey) => null;
}

class GoogleMobileAdsConsentService implements AdConsentService {
  const GoogleMobileAdsConsentService({
    this.forceDebugGeography = false,
    this.debugTestDeviceIds = const [],
  });

  final bool forceDebugGeography;
  final List<String> debugTestDeviceIds;

  @override
  Future<ConsentState> requestConsentInfoUpdate() async {
    return ConsentState.unavailable(
      errorMessage: 'Google Mobile Ads is unavailable on this platform.',
    );
  }

  @override
  Future<void> showPrivacyOptions() async {
    throw StateError('Google Mobile Ads is unavailable on this platform.');
  }
}

class GoogleMobileAdsService implements AdService {
  GoogleMobileAdsService({
    this.config = const GoogleMobileAdsConfig(),
  });

  final GoogleMobileAdsConfig config;

  @override
  bool get isInitialized => false;

  @override
  Future<void> initialize() async {}

  @override
  Future<BannerAdHandle?> loadBanner({
    required AdPlacementKey placementKey,
    required double width,
  }) async =>
      null;

  @override
  Future<void> disposeBanner(BannerAdHandle handle) async {}

  @override
  Future<bool> loadInterstitial(AdPlacementKey placementKey) async => false;

  @override
  Future<bool> showInterstitial(AdPlacementKey placementKey) async => false;

  @override
  Future<bool> loadRewarded(AdPlacementKey placementKey) async => false;

  @override
  Future<bool> showRewarded({
    required AdPlacementKey placementKey,
    required void Function(String adEventId) onRewardEarned,
  }) async =>
      false;

  @override
  Future<void> shutdown() async {}
}
