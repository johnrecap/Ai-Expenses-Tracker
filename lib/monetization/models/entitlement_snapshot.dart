import 'package:equatable/equatable.dart';

import 'monetization_plan.dart';

enum EntitlementStatus {
  free,
  active,
  gracePeriod,
  expired,
  refunded,
  revoked,
  unavailable,
}

enum EntitlementSource {
  localDefault,
  localCache,
  firestore,
  worker,
  storeSandbox,
  storeVerified,
}

class EntitlementSnapshot extends Equatable {
  const EntitlementSnapshot({
    required this.tier,
    required this.source,
    required this.updatedAt,
    this.expiresAt,
    this.graceUntil,
    this.isVerified = false,
    this.status = EntitlementStatus.free,
    this.reason,
  });

  final PlanTier tier;
  final EntitlementSource source;
  final DateTime updatedAt;
  final DateTime? expiresAt;
  final DateTime? graceUntil;
  final bool isVerified;
  final EntitlementStatus status;
  final String? reason;

  bool get isPremiumActive {
    if (tier != PlanTier.premium) return false;
    final now = DateTime.now();
    if (expiresAt != null && expiresAt!.isBefore(now)) {
      return graceUntil != null && graceUntil!.isAfter(now);
    }
    if (status == EntitlementStatus.revoked ||
        status == EntitlementStatus.refunded ||
        status == EntitlementStatus.unavailable) {
      return false;
    }
    return isVerified || source == EntitlementSource.storeSandbox;
  }

  bool get shouldDisableAds => isPremiumActive;

  factory EntitlementSnapshot.freeDefault({DateTime? updatedAt}) {
    return EntitlementSnapshot(
      tier: PlanTier.free,
      source: EntitlementSource.localDefault,
      updatedAt: updatedAt ?? DateTime.now(),
      status: EntitlementStatus.free,
      reason: 'Default usable free plan.',
    );
  }

  factory EntitlementSnapshot.premiumFixture({DateTime? updatedAt}) {
    return EntitlementSnapshot(
      tier: PlanTier.premium,
      source: EntitlementSource.storeSandbox,
      updatedAt: updatedAt ?? DateTime.now(),
      isVerified: true,
      status: EntitlementStatus.active,
      reason: 'Development premium fixture.',
    );
  }

  EntitlementSnapshot copyWith({
    PlanTier? tier,
    EntitlementSource? source,
    DateTime? updatedAt,
    DateTime? expiresAt,
    DateTime? graceUntil,
    bool? isVerified,
    EntitlementStatus? status,
    String? reason,
  }) {
    return EntitlementSnapshot(
      tier: tier ?? this.tier,
      source: source ?? this.source,
      updatedAt: updatedAt ?? this.updatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      graceUntil: graceUntil ?? this.graceUntil,
      isVerified: isVerified ?? this.isVerified,
      status: status ?? this.status,
      reason: reason ?? this.reason,
    );
  }

  @override
  List<Object?> get props => [
        tier,
        source,
        updatedAt,
        expiresAt,
        graceUntil,
        isVerified,
        status,
        reason,
      ];
}
