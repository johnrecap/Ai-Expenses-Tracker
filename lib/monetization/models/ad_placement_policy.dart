import 'package:equatable/equatable.dart';

enum AdPlacementKey {
  homeBanner,
  expensesBanner,
  reportsBanner,
  exportInterstitial,
  postSaveInterstitial,
  aiRewarded,
}

enum AdFormat {
  banner,
  interstitial,
  rewarded,
}

class AdPlacementPolicy extends Equatable {
  const AdPlacementPolicy({
    required this.key,
    required this.format,
    required this.enabledForFree,
    required this.enabledForPremium,
    this.minimumInterval = Duration.zero,
    this.requiredCompletedActions = 0,
    this.blockedRoutes = const [],
  });

  final AdPlacementKey key;
  final AdFormat format;
  final bool enabledForFree;
  final bool enabledForPremium;
  final Duration minimumInterval;
  final int requiredCompletedActions;
  final List<String> blockedRoutes;

  static const criticalRoutes = [
    'auth',
    'login',
    'register',
    'app_lock',
    'unlock',
    'add_expense',
    'ai_preview',
    'ai_assistant',
    'purchase',
  ];

  static List<AdPlacementPolicy> defaults() {
    return const [
      AdPlacementPolicy(
        key: AdPlacementKey.homeBanner,
        format: AdFormat.banner,
        enabledForFree: true,
        enabledForPremium: false,
      ),
      AdPlacementPolicy(
        key: AdPlacementKey.expensesBanner,
        format: AdFormat.banner,
        enabledForFree: true,
        enabledForPremium: false,
      ),
      AdPlacementPolicy(
        key: AdPlacementKey.reportsBanner,
        format: AdFormat.banner,
        enabledForFree: true,
        enabledForPremium: false,
      ),
      AdPlacementPolicy(
        key: AdPlacementKey.exportInterstitial,
        format: AdFormat.interstitial,
        enabledForFree: true,
        enabledForPremium: false,
        minimumInterval: Duration(minutes: 10),
        blockedRoutes: criticalRoutes,
      ),
      AdPlacementPolicy(
        key: AdPlacementKey.postSaveInterstitial,
        format: AdFormat.interstitial,
        enabledForFree: true,
        enabledForPremium: false,
        minimumInterval: Duration(minutes: 10),
        requiredCompletedActions: 5,
        blockedRoutes: criticalRoutes,
      ),
      AdPlacementPolicy(
        key: AdPlacementKey.aiRewarded,
        format: AdFormat.rewarded,
        enabledForFree: true,
        enabledForPremium: false,
        blockedRoutes: ['auth', 'app_lock', 'purchase'],
      ),
    ];
  }

  @override
  List<Object?> get props => [
        key,
        format,
        enabledForFree,
        enabledForPremium,
        minimumInterval,
        requiredCompletedActions,
        blockedRoutes,
      ];
}
