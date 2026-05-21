import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' as gma;

import '../models/models.dart';
import 'ad_consent_service.dart';
import 'ad_service.dart';

class GoogleMobileAdsConfig {
  const GoogleMobileAdsConfig({
    this.enableProductionAds = const bool.fromEnvironment(
      'ADMOB_ENABLE_PRODUCTION_ADS',
    ),
    this.androidBannerUnitId = const String.fromEnvironment(
      'ADMOB_ANDROID_BANNER_UNIT_ID',
    ),
    this.iosBannerUnitId = const String.fromEnvironment(
      'ADMOB_IOS_BANNER_UNIT_ID',
    ),
    this.androidInterstitialUnitId = const String.fromEnvironment(
      'ADMOB_ANDROID_INTERSTITIAL_UNIT_ID',
    ),
    this.iosInterstitialUnitId = const String.fromEnvironment(
      'ADMOB_IOS_INTERSTITIAL_UNIT_ID',
    ),
    this.androidRewardedUnitId = const String.fromEnvironment(
      'ADMOB_ANDROID_REWARDED_UNIT_ID',
    ),
    this.iosRewardedUnitId = const String.fromEnvironment(
      'ADMOB_IOS_REWARDED_UNIT_ID',
    ),
  });

  static const androidTestAppId = 'ca-app-pub-3940256099942544~3347511713';
  static const iosTestAppId = 'ca-app-pub-3940256099942544~1458002511';
  static const _androidTestBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const _iosTestBanner = 'ca-app-pub-3940256099942544/2934735716';
  static const _androidTestInterstitial =
      'ca-app-pub-3940256099942544/1033173712';
  static const _iosTestInterstitial = 'ca-app-pub-3940256099942544/4411468910';
  static const _androidTestRewarded = 'ca-app-pub-3940256099942544/5224354917';
  static const _iosTestRewarded = 'ca-app-pub-3940256099942544/1712485313';

  final bool enableProductionAds;
  final String androidBannerUnitId;
  final String iosBannerUnitId;
  final String androidInterstitialUnitId;
  final String iosInterstitialUnitId;
  final String androidRewardedUnitId;
  final String iosRewardedUnitId;

  String? unitIdFor(AdPlacementKey placementKey) {
    final platform = _mobilePlatform;
    if (platform == null) return null;

    if (!kReleaseMode) {
      return switch (placementKey) {
        AdPlacementKey.homeBanner ||
        AdPlacementKey.expensesBanner ||
        AdPlacementKey.reportsBanner =>
          platform == TargetPlatform.android
              ? _androidTestBanner
              : _iosTestBanner,
        AdPlacementKey.exportInterstitial ||
        AdPlacementKey.postSaveInterstitial =>
          platform == TargetPlatform.android
              ? _androidTestInterstitial
              : _iosTestInterstitial,
        AdPlacementKey.aiRewarded => platform == TargetPlatform.android
            ? _androidTestRewarded
            : _iosTestRewarded,
      };
    }

    if (!enableProductionAds) return null;
    final configured = switch (placementKey) {
      AdPlacementKey.homeBanner ||
      AdPlacementKey.expensesBanner ||
      AdPlacementKey.reportsBanner =>
        platform == TargetPlatform.android
            ? androidBannerUnitId
            : iosBannerUnitId,
      AdPlacementKey.exportInterstitial ||
      AdPlacementKey.postSaveInterstitial =>
        platform == TargetPlatform.android
            ? androidInterstitialUnitId
            : iosInterstitialUnitId,
      AdPlacementKey.aiRewarded => platform == TargetPlatform.android
          ? androidRewardedUnitId
          : iosRewardedUnitId,
    };
    return configured.trim().isEmpty ? null : configured.trim();
  }

  TargetPlatform? get _mobilePlatform {
    if (kIsWeb) return null;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => TargetPlatform.android,
      TargetPlatform.iOS => TargetPlatform.iOS,
      _ => null,
    };
  }
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
    final completer = Completer<ConsentState>();
    final params = gma.ConsentRequestParameters(
      consentDebugSettings: kDebugMode && forceDebugGeography
          ? gma.ConsentDebugSettings(
              debugGeography: gma.DebugGeography.debugGeographyEea,
              testIdentifiers: debugTestDeviceIds,
            )
          : null,
    );

    try {
      gma.ConsentInformation.instance.requestConsentInfoUpdate(
        params,
        () async {
          try {
            await gma.ConsentForm.loadAndShowConsentFormIfRequired(
              (formError) async {
                if (formError != null) {
                  _completeUnavailable(completer, formError.message);
                  return;
                }
                completer.complete(await _snapshot());
              },
            );
          } catch (error) {
            _completeUnavailable(completer, error.toString());
          }
        },
        (formError) => _completeUnavailable(completer, formError.message),
      );
    } catch (error) {
      _completeUnavailable(completer, error.toString());
    }

    return completer.future;
  }

  @override
  Future<void> showPrivacyOptions() async {
    final completer = Completer<void>();
    await gma.ConsentForm.showPrivacyOptionsForm((formError) {
      if (formError == null) {
        completer.complete();
      } else {
        completer.completeError(StateError(formError.message));
      }
    });
    return completer.future;
  }

  Future<ConsentState> _snapshot() async {
    final canRequestAds = await gma.ConsentInformation.instance.canRequestAds();
    final status = await gma.ConsentInformation.instance.getConsentStatus();
    final privacyOptions = await gma.ConsentInformation.instance
        .getPrivacyOptionsRequirementStatus();
    return ConsentState(
      canRequestAds: canRequestAds,
      privacyOptionsRequired:
          privacyOptions == gma.PrivacyOptionsRequirementStatus.required,
      lastUpdatedAt: DateTime.now(),
      statusLabel: status.name,
      isDebugGeographyEnabled: kDebugMode && forceDebugGeography,
    );
  }

  void _completeUnavailable(Completer<ConsentState> completer, String message) {
    if (completer.isCompleted) return;
    completer.complete(ConsentState.unavailable(errorMessage: message));
  }
}

class GoogleMobileAdsService implements AdService {
  GoogleMobileAdsService({
    this.config = const GoogleMobileAdsConfig(),
  });

  final GoogleMobileAdsConfig config;
  final Map<AdPlacementKey, gma.InterstitialAd> _interstitials = {};
  final Map<AdPlacementKey, gma.RewardedAd> _rewardedAds = {};
  final Map<BannerAdHandle, gma.BannerAd> _bannerAds = {};
  bool _initialized = false;

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    if (config._mobilePlatform == null) return;
    await gma.MobileAds.instance.initialize();
    _initialized = true;
  }

  @override
  Future<BannerAdHandle?> loadBanner({
    required AdPlacementKey placementKey,
    required double width,
  }) async {
    if (!_initialized) return null;
    final adUnitId = config.unitIdFor(placementKey);
    if (adUnitId == null) return null;

    final completer = Completer<BannerAdHandle?>();
    final adWidth = width.truncate().clamp(320, 1200).toInt();
    final adaptiveSize =
        await gma.AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      adWidth,
    );
    final size = adaptiveSize ?? gma.AdSize.banner;
    late final gma.BannerAd bannerAd;
    bannerAd = gma.BannerAd(
      adUnitId: adUnitId,
      size: size,
      request: const gma.AdRequest(),
      listener: gma.BannerAdListener(
        onAdLoaded: (ad) {
          final handle = BannerAdHandle(
            placementKey: placementKey,
            width: size.width.toDouble(),
            height: size.height.toDouble(),
            child: SizedBox(
              width: size.width.toDouble(),
              height: size.height.toDouble(),
              child: gma.AdWidget(ad: bannerAd),
            ),
          );
          _bannerAds[handle] = bannerAd;
          if (!completer.isCompleted) completer.complete(handle);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (!completer.isCompleted) completer.complete(null);
        },
      ),
    );
    bannerAd.load();
    return completer.future;
  }

  @override
  Future<void> disposeBanner(BannerAdHandle handle) async {
    _bannerAds.remove(handle)?.dispose();
  }

  @override
  Future<bool> loadInterstitial(AdPlacementKey placementKey) async {
    if (!_initialized) return false;
    if (_interstitials.containsKey(placementKey)) return true;
    final adUnitId = config.unitIdFor(placementKey);
    if (adUnitId == null) return false;

    final completer = Completer<bool>();
    gma.InterstitialAd.load(
      adUnitId: adUnitId,
      request: const gma.AdRequest(),
      adLoadCallback: gma.InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitials[placementKey] = ad;
          if (!completer.isCompleted) completer.complete(true);
        },
        onAdFailedToLoad: (error) {
          if (!completer.isCompleted) completer.complete(false);
        },
      ),
    );
    return completer.future;
  }

  @override
  Future<bool> showInterstitial(AdPlacementKey placementKey) async {
    final ad = _interstitials.remove(placementKey);
    if (ad == null) return false;
    ad.fullScreenContentCallback = gma.FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) => ad.dispose(),
      onAdFailedToShowFullScreenContent: (ad, error) => ad.dispose(),
    );
    ad.show();
    return true;
  }

  @override
  Future<bool> loadRewarded(AdPlacementKey placementKey) async {
    if (!_initialized) return false;
    if (_rewardedAds.containsKey(placementKey)) return true;
    final adUnitId = config.unitIdFor(placementKey);
    if (adUnitId == null) return false;

    final completer = Completer<bool>();
    gma.RewardedAd.load(
      adUnitId: adUnitId,
      request: const gma.AdRequest(),
      rewardedAdLoadCallback: gma.RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAds[placementKey] = ad;
          if (!completer.isCompleted) completer.complete(true);
        },
        onAdFailedToLoad: (error) {
          if (!completer.isCompleted) completer.complete(false);
        },
      ),
    );
    return completer.future;
  }

  @override
  Future<bool> showRewarded({
    required AdPlacementKey placementKey,
    required void Function(String adEventId) onRewardEarned,
  }) async {
    final ad = _rewardedAds.remove(placementKey);
    if (ad == null) return false;
    ad.fullScreenContentCallback = gma.FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) => ad.dispose(),
      onAdFailedToShowFullScreenContent: (ad, error) => ad.dispose(),
    );
    ad.show(
      onUserEarnedReward: (ad, reward) {
        final responseId = ad.responseInfo?.responseId;
        onRewardEarned(
          responseId == null || responseId.isEmpty
              ? 'admob_reward_${DateTime.now().millisecondsSinceEpoch}'
              : responseId,
        );
      },
    );
    return true;
  }

  @override
  Future<void> shutdown() async {
    for (final ad in _bannerAds.values) {
      ad.dispose();
    }
    for (final ad in _interstitials.values) {
      ad.dispose();
    }
    for (final ad in _rewardedAds.values) {
      ad.dispose();
    }
    _bannerAds.clear();
    _interstitials.clear();
    _rewardedAds.clear();
    _initialized = false;
  }
}
