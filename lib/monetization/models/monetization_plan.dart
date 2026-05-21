import 'package:equatable/equatable.dart';

enum PlanTier {
  free,
  premium,
  unknown,
  pending;

  String get label {
    switch (this) {
      case PlanTier.free:
        return 'Free';
      case PlanTier.premium:
        return 'Premium';
      case PlanTier.unknown:
        return 'Unknown';
      case PlanTier.pending:
        return 'Pending';
    }
  }

  bool get isPremium => this == PlanTier.premium;
}

class MonetizationPlan extends Equatable {
  const MonetizationPlan({
    required this.tier,
    required this.title,
    required this.summary,
    required this.features,
    required this.adsEnabled,
    required this.premiumCtaEnabled,
  });

  final PlanTier tier;
  final String title;
  final String summary;
  final List<String> features;
  final bool adsEnabled;
  final bool premiumCtaEnabled;

  static const free = MonetizationPlan(
    tier: PlanTier.free,
    title: 'Free',
    summary: 'Manual tracking, core reports, budgets, export, and limited AI.',
    features: [
      'Manual expense tracking stays available',
      'Categories, budgets, basic reports, and offline sync',
      'AI parse 5/day, receipts 3/day, advice 3/day',
      'Polite ads after consent',
    ],
    adsEnabled: true,
    premiumCtaEnabled: true,
  );

  static const premium = MonetizationPlan(
    tier: PlanTier.premium,
    title: 'Premium',
    summary: 'No ads, higher AI limits, deeper reports, and richer exports.',
    features: [
      'No ads after entitlement is confirmed',
      'Higher AI limits, still finite and policy-backed',
      'Advanced reports and deeper month comparisons',
      'Larger export ranges and premium insights later',
    ],
    adsEnabled: false,
    premiumCtaEnabled: false,
  );

  @override
  List<Object?> get props => [
        tier,
        title,
        summary,
        features,
        adsEnabled,
        premiumCtaEnabled,
      ];
}
