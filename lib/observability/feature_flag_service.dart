enum AppFeatureFlag {
  aiGateway,
  receiptAi,
  adviceAi,
  ads,
  rewardedCredits,
  premiumCta,
  experimentalRetentionCards,
}

abstract class FeatureFlagService {
  const FeatureFlagService();

  bool isEnabled(AppFeatureFlag flag);
}

class LocalFeatureFlagService extends FeatureFlagService {
  LocalFeatureFlagService({
    Map<AppFeatureFlag, bool> overrides = const {},
  }) : _overrides = Map.unmodifiable(overrides);

  final Map<AppFeatureFlag, bool> _overrides;

  static const Map<AppFeatureFlag, bool> defaults = {
    AppFeatureFlag.aiGateway: true,
    AppFeatureFlag.receiptAi: true,
    AppFeatureFlag.adviceAi: true,
    AppFeatureFlag.ads: true,
    AppFeatureFlag.rewardedCredits: true,
    AppFeatureFlag.premiumCta: true,
    AppFeatureFlag.experimentalRetentionCards: true,
  };

  @override
  bool isEnabled(AppFeatureFlag flag) => _overrides[flag] ?? defaults[flag]!;
}

class DisabledFeatureFlagService extends FeatureFlagService {
  const DisabledFeatureFlagService();

  @override
  bool isEnabled(AppFeatureFlag flag) => false;
}
