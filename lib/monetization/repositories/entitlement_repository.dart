import '../models/models.dart';

abstract class EntitlementRepository {
  Stream<EntitlementSnapshot> watchEntitlement();

  Future<EntitlementSnapshot> getEntitlement();

  Future<EntitlementSnapshot> refreshEntitlement();

  Future<PurchaseVerificationResult> verifyPurchase(
    PurchaseVerificationRequest request,
  );

  Future<PurchaseVerificationResult> restoreEntitlement(
    EntitlementRestoreRequest request,
  );
}

class LocalEntitlementRepository implements EntitlementRepository {
  LocalEntitlementRepository({
    EntitlementSnapshot? initialSnapshot,
  }) : _snapshot = initialSnapshot ?? EntitlementSnapshot.freeDefault();

  EntitlementSnapshot _snapshot;

  @override
  Future<EntitlementSnapshot> getEntitlement() async => _snapshot;

  @override
  Future<EntitlementSnapshot> refreshEntitlement() async => _snapshot;

  @override
  Future<PurchaseVerificationResult> verifyPurchase(
    PurchaseVerificationRequest request,
  ) async {
    return PurchaseVerificationResult(
      status: EntitlementVerificationStatus.backendUnavailable,
      entitlement: VerifiedEntitlement(
        userId: '',
        tier: PlanTier.free,
        status: EntitlementStatus.unavailable,
        source: EntitlementSource.localDefault,
        lastVerifiedAt: DateTime.now(),
        reason: 'Purchase verification backend is not configured.',
      ),
      errorCode: 'backend_unavailable',
      recoveryMessage: 'Premium verification is not available yet.',
    );
  }

  @override
  Future<PurchaseVerificationResult> restoreEntitlement(
    EntitlementRestoreRequest request,
  ) async {
    return PurchaseVerificationResult(
      status: EntitlementVerificationStatus.backendUnavailable,
      entitlement: VerifiedEntitlement(
        userId: '',
        tier: PlanTier.free,
        status: EntitlementStatus.unavailable,
        source: EntitlementSource.localDefault,
        lastVerifiedAt: DateTime.now(),
        reason: 'Entitlement restore backend is not configured.',
      ),
      errorCode: 'backend_unavailable',
      recoveryMessage: 'Premium restore is not available yet.',
    );
  }

  @override
  Stream<EntitlementSnapshot> watchEntitlement() async* {
    yield _snapshot;
  }

  void setFixture(EntitlementSnapshot snapshot) {
    _snapshot = snapshot;
  }
}
