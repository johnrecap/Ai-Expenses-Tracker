import 'package:flutter/widgets.dart';

import '../models/models.dart';

enum AdLoadStatus {
  idle,
  loading,
  ready,
  failed,
}

class BannerAdHandle {
  const BannerAdHandle({
    required this.placementKey,
    required this.width,
    required this.height,
    this.debugLabel,
    this.child,
  });

  final AdPlacementKey placementKey;
  final double width;
  final double height;
  final String? debugLabel;
  final Widget? child;
}

abstract class AdService {
  bool get isInitialized;

  Future<void> initialize();

  Future<BannerAdHandle?> loadBanner({
    required AdPlacementKey placementKey,
    required double width,
  });

  Future<void> disposeBanner(BannerAdHandle handle);

  Future<bool> loadInterstitial(AdPlacementKey placementKey);

  Future<bool> showInterstitial(AdPlacementKey placementKey);

  Future<bool> loadRewarded(AdPlacementKey placementKey);

  Future<bool> showRewarded({
    required AdPlacementKey placementKey,
    required void Function(String adEventId) onRewardEarned,
  });

  Future<void> shutdown();
}

class FakeAdService implements AdService {
  FakeAdService({
    this.failLoads = false,
    this.rewardEventId = 'debug-reward-event',
  });

  final bool failLoads;
  final String rewardEventId;

  bool _initialized = false;
  int initializeCalls = 0;
  int bannerLoadCalls = 0;
  int bannerDisposeCalls = 0;
  int interstitialLoadCalls = 0;
  int interstitialShows = 0;
  int rewardedLoadCalls = 0;
  int rewardedShows = 0;
  int shutdownCalls = 0;

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    initializeCalls += 1;
    _initialized = true;
  }

  @override
  Future<BannerAdHandle?> loadBanner({
    required AdPlacementKey placementKey,
    required double width,
  }) async {
    bannerLoadCalls += 1;
    if (failLoads || !_initialized) return null;
    return BannerAdHandle(
      placementKey: placementKey,
      width: width,
      height: 50,
      debugLabel: 'Test ad slot',
    );
  }

  @override
  Future<void> disposeBanner(BannerAdHandle handle) async {
    bannerDisposeCalls += 1;
  }

  @override
  Future<bool> loadInterstitial(AdPlacementKey placementKey) async {
    interstitialLoadCalls += 1;
    return _initialized && !failLoads;
  }

  @override
  Future<bool> showInterstitial(AdPlacementKey placementKey) async {
    if (!_initialized || failLoads) return false;
    interstitialShows += 1;
    return true;
  }

  @override
  Future<bool> loadRewarded(AdPlacementKey placementKey) async {
    rewardedLoadCalls += 1;
    return _initialized && !failLoads;
  }

  @override
  Future<bool> showRewarded({
    required AdPlacementKey placementKey,
    required void Function(String adEventId) onRewardEarned,
  }) async {
    if (!_initialized || failLoads) return false;
    rewardedShows += 1;
    onRewardEarned(rewardEventId);
    return true;
  }

  @override
  Future<void> shutdown() async {
    shutdownCalls += 1;
    _initialized = false;
  }
}
