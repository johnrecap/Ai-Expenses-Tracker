import 'package:equatable/equatable.dart';

import 'ad_frequency_cap.dart';
import 'ad_placement_policy.dart';
import 'ai_quota_policy.dart';
import 'monetization_plan.dart';

class MonetizationPolicy extends Equatable {
  const MonetizationPolicy({
    required this.version,
    required this.updatedAt,
    required this.freeQuota,
    required this.premiumQuota,
    required this.adFrequencyCap,
    required this.adPlacements,
    required this.plans,
  });

  final String version;
  final DateTime updatedAt;
  final AiQuotaPolicy freeQuota;
  final AiQuotaPolicy premiumQuota;
  final AdFrequencyCap adFrequencyCap;
  final List<AdPlacementPolicy> adPlacements;
  final List<MonetizationPlan> plans;

  factory MonetizationPolicy.defaults({DateTime? updatedAt}) {
    return MonetizationPolicy(
      version: '2026-05-17.free-premium-v1',
      updatedAt: updatedAt ?? DateTime(2026, 5, 17),
      freeQuota: AiQuotaPolicy.freeDefaults(),
      premiumQuota: AiQuotaPolicy.premiumDefaults(),
      adFrequencyCap: AdFrequencyCap.defaults,
      adPlacements: AdPlacementPolicy.defaults(),
      plans: const [MonetizationPlan.free, MonetizationPlan.premium],
    );
  }

  AiQuotaPolicy quotaFor(PlanTier tier) {
    return tier == PlanTier.premium ? premiumQuota : freeQuota;
  }

  AdPlacementPolicy? placementFor(AdPlacementKey key) {
    for (final placement in adPlacements) {
      if (placement.key == key) return placement;
    }
    return null;
  }

  MonetizationPlan planFor(PlanTier tier) {
    return tier == PlanTier.premium
        ? MonetizationPlan.premium
        : MonetizationPlan.free;
  }

  @override
  List<Object?> get props => [
        version,
        updatedAt,
        freeQuota,
        premiumQuota,
        adFrequencyCap,
        adPlacements,
        plans,
      ];
}
