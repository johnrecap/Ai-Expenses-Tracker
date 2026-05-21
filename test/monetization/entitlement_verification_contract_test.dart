import 'package:expenses_tracker/monetization/monetization.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('premium entitlement verification contract fixtures', () {
    test('valid purchase returns verified Premium snapshot', () async {
      final repository = _FakeVerifiedEntitlementRepository(
        result: _result(
          verificationStatus: EntitlementVerificationStatus.verified,
          entitlementStatus: EntitlementStatus.active,
          tier: PlanTier.premium,
        ),
      );

      final result = await repository.verifyPurchase(_verifyRequest());

      expect(result.verified, isTrue);
      expect(result.snapshot.isPremiumActive, isTrue);
      expect(result.snapshot.shouldDisableAds, isTrue);
    });

    test('invalid receipt remains Free', () async {
      final repository = _FakeVerifiedEntitlementRepository(
        result: _result(
          verificationStatus: EntitlementVerificationStatus.invalidReceipt,
          entitlementStatus: EntitlementStatus.free,
          tier: PlanTier.free,
          errorCode: 'invalid_receipt',
        ),
      );

      final result = await repository.verifyPurchase(_verifyRequest());

      expect(result.verified, isFalse);
      expect(result.snapshot.isPremiumActive, isFalse);
      expect(result.errorCode, 'invalid_receipt');
    });

    test('expired subscription remains Free', () async {
      final result = _result(
        verificationStatus: EntitlementVerificationStatus.expired,
        entitlementStatus: EntitlementStatus.expired,
        tier: PlanTier.premium,
        expiresAt: DateTime(2026, 5, 1),
      );

      expect(result.snapshot.isPremiumActive, isFalse);
      expect(result.snapshot.status, EntitlementStatus.expired);
    });

    test('refunded subscription remains Free', () async {
      final result = _result(
        verificationStatus: EntitlementVerificationStatus.refunded,
        entitlementStatus: EntitlementStatus.refunded,
        tier: PlanTier.premium,
      );

      expect(result.snapshot.isPremiumActive, isFalse);
      expect(result.snapshot.status, EntitlementStatus.refunded);
    });

    test('restore can return verified Premium entitlement', () async {
      final repository = _FakeVerifiedEntitlementRepository(
        restoreResult: _result(
          verificationStatus: EntitlementVerificationStatus.restored,
          entitlementStatus: EntitlementStatus.active,
          tier: PlanTier.premium,
        ),
      );

      final result = await repository.restoreEntitlement(
        const EntitlementRestoreRequest(
          platform: PurchasePlatform.googlePlay,
          purchaseTokens: ['token'],
          clientRequestId: 'client-request',
        ),
      );

      expect(result.status, EntitlementVerificationStatus.restored);
      expect(result.snapshot.isPremiumActive, isTrue);
    });

    test('backend unavailable does not grant Premium', () async {
      final repository = LocalEntitlementRepository();
      final result = await repository.verifyPurchase(_verifyRequest());

      expect(result.status, EntitlementVerificationStatus.backendUnavailable);
      expect(result.snapshot.isPremiumActive, isFalse);
      expect(result.recoveryMessage, isNotEmpty);
    });
  });
}

PurchaseVerificationRequest _verifyRequest() {
  return const PurchaseVerificationRequest(
    platform: PurchasePlatform.googlePlay,
    productId: DisabledPurchaseService.premiumMonthlyProductId,
    purchaseToken: 'token',
    clientRequestId: 'client-request',
  );
}

PurchaseVerificationResult _result({
  required EntitlementVerificationStatus verificationStatus,
  required EntitlementStatus entitlementStatus,
  required PlanTier tier,
  DateTime? expiresAt,
  String? errorCode,
}) {
  return PurchaseVerificationResult(
    status: verificationStatus,
    entitlement: VerifiedEntitlement(
      userId: 'user-1',
      productId: DisabledPurchaseService.premiumMonthlyProductId,
      tier: tier,
      status: entitlementStatus,
      source: EntitlementSource.storeVerified,
      lastVerifiedAt: DateTime(2026, 5, 20),
      expiresAt: expiresAt,
    ),
    errorCode: errorCode,
    recoveryMessage: errorCode == null ? null : 'Recovery copy',
  );
}

class _FakeVerifiedEntitlementRepository extends LocalEntitlementRepository {
  _FakeVerifiedEntitlementRepository({
    PurchaseVerificationResult? result,
    PurchaseVerificationResult? restoreResult,
  })  : _result = result,
        _restoreResult = restoreResult;

  final PurchaseVerificationResult? _result;
  final PurchaseVerificationResult? _restoreResult;

  @override
  Future<PurchaseVerificationResult> verifyPurchase(
    PurchaseVerificationRequest request,
  ) async {
    return _result ?? await super.verifyPurchase(request);
  }

  @override
  Future<PurchaseVerificationResult> restoreEntitlement(
    EntitlementRestoreRequest request,
  ) async {
    return _restoreResult ?? await super.restoreEntitlement(request);
  }
}
