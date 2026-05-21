import 'package:expenses_tracker/feature_flags/feature_readiness.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/monetization/monetization.dart';
import 'package:flutter/material.dart';

class PremiumCtaPanel extends StatelessWidget {
  const PremiumCtaPanel({
    required this.state,
    super.key,
  });

  final MonetizationState state;

  @override
  Widget build(BuildContext context) {
    if (state.entitlement.isPremiumActive) {
      return _Panel(
        icon: Icons.check_circle_outline,
        title: context.l10n.premiumIsActive,
        body: context.l10n.premiumActiveBody,
        child: const SizedBox.shrink(),
      );
    }

    return _Panel(
      icon: Icons.workspace_premium_outlined,
      title: context.l10n.readinessTitle(FeatureReadiness.premiumPurchase),
      body: context.l10n.readinessBody(FeatureReadiness.premiumPurchase),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          FilledButton(
            onPressed: null,
            child: Text(context.l10n.checkAvailability),
          ),
          OutlinedButton(
            onPressed: null,
            child: Text(context.l10n.restorePurchases),
          ),
          Text(
            context.l10n.premiumBackendVerificationUnavailable,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.icon,
    required this.title,
    required this.body,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String body;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(body),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
