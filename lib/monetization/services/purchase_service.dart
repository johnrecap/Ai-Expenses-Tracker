import 'dart:async';

class PremiumProduct {
  const PremiumProduct({
    required this.productId,
    required this.title,
    this.priceLabel,
    this.periodLabel,
  });

  final String productId;
  final String title;
  final String? priceLabel;
  final String? periodLabel;
}

enum PurchaseStatus {
  idle,
  unavailable,
  loading,
  pendingVerification,
  verified,
  failed,
}

class PurchaseResult {
  const PurchaseResult({
    required this.status,
    required this.message,
  });

  final PurchaseStatus status;
  final String message;
}

abstract class PurchaseService {
  Stream<PurchaseStatus> get purchaseStatus;

  Future<List<PremiumProduct>> loadProducts();

  Future<PurchaseResult> buyPremium(String productId);

  Future<PurchaseResult> restorePurchases();
}

class DisabledPurchaseService implements PurchaseService {
  const DisabledPurchaseService();

  static const premiumMonthlyProductId = 'premium_monthly';
  static const premiumYearlyProductId = 'premium_yearly';

  @override
  Stream<PurchaseStatus> get purchaseStatus async* {
    yield PurchaseStatus.unavailable;
  }

  @override
  Future<List<PremiumProduct>> loadProducts() async {
    return const [
      PremiumProduct(
        productId: premiumMonthlyProductId,
        title: 'Premium Monthly',
        periodLabel: 'Monthly',
      ),
      PremiumProduct(
        productId: premiumYearlyProductId,
        title: 'Premium Yearly',
        periodLabel: 'Yearly',
      ),
    ];
  }

  @override
  Future<PurchaseResult> buyPremium(String productId) async {
    return const PurchaseResult(
      status: PurchaseStatus.unavailable,
      message: 'Premium purchases are coming soon. No real payment was made.',
    );
  }

  @override
  Future<PurchaseResult> restorePurchases() async {
    return const PurchaseResult(
      status: PurchaseStatus.unavailable,
      message: 'Restore purchases will be enabled after store setup.',
    );
  }
}
