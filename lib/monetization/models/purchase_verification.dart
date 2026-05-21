import 'package:equatable/equatable.dart';

import 'entitlement_snapshot.dart';
import 'monetization_plan.dart';

enum EntitlementVerificationStatus {
  verified,
  restored,
  notFound,
  invalidReceipt,
  expired,
  refunded,
  revoked,
  backendUnavailable,
}

enum PurchasePlatform {
  googlePlay,
  appStore,
  sandbox,
}

class PurchaseVerificationRequest extends Equatable {
  const PurchaseVerificationRequest({
    required this.platform,
    required this.productId,
    required this.purchaseToken,
    required this.clientRequestId,
    this.transactionId,
  });

  final PurchasePlatform platform;
  final String productId;
  final String purchaseToken;
  final String clientRequestId;
  final String? transactionId;

  @override
  List<Object?> get props => [
        platform,
        productId,
        purchaseToken,
        clientRequestId,
        transactionId,
      ];
}

class EntitlementRestoreRequest extends Equatable {
  const EntitlementRestoreRequest({
    required this.platform,
    required this.purchaseTokens,
    required this.clientRequestId,
  });

  final PurchasePlatform platform;
  final List<String> purchaseTokens;
  final String clientRequestId;

  @override
  List<Object?> get props => [
        platform,
        purchaseTokens,
        clientRequestId,
      ];
}

class VerifiedEntitlement extends Equatable {
  const VerifiedEntitlement({
    required this.userId,
    required this.tier,
    required this.status,
    required this.source,
    required this.lastVerifiedAt,
    this.productId,
    this.expiresAt,
    this.graceUntil,
    this.serverRevision,
    this.reason,
  });

  final String userId;
  final PlanTier tier;
  final EntitlementStatus status;
  final EntitlementSource source;
  final DateTime lastVerifiedAt;
  final String? productId;
  final DateTime? expiresAt;
  final DateTime? graceUntil;
  final String? serverRevision;
  final String? reason;

  bool get isPremiumActive {
    return tier == PlanTier.premium &&
        (status == EntitlementStatus.active ||
            status == EntitlementStatus.gracePeriod);
  }

  EntitlementSnapshot toSnapshot() {
    return EntitlementSnapshot(
      tier: isPremiumActive ? PlanTier.premium : PlanTier.free,
      source: source,
      updatedAt: lastVerifiedAt,
      expiresAt: expiresAt,
      graceUntil: graceUntil,
      isVerified: isPremiumActive,
      status: status,
      reason: reason,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        tier,
        status,
        source,
        lastVerifiedAt,
        productId,
        expiresAt,
        graceUntil,
        serverRevision,
        reason,
      ];
}

class PurchaseVerificationResult extends Equatable {
  const PurchaseVerificationResult({
    required this.status,
    required this.entitlement,
    this.errorCode,
    this.recoveryMessage,
  });

  final EntitlementVerificationStatus status;
  final VerifiedEntitlement entitlement;
  final String? errorCode;
  final String? recoveryMessage;

  bool get verified {
    return status == EntitlementVerificationStatus.verified ||
        status == EntitlementVerificationStatus.restored;
  }

  EntitlementSnapshot get snapshot => entitlement.toSnapshot();

  @override
  List<Object?> get props => [
        status,
        entitlement,
        errorCode,
        recoveryMessage,
      ];
}
