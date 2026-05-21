import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/monetization/monetization.dart';
import 'package:flutter/material.dart';

class CurrentPlanBadge extends StatelessWidget {
  const CurrentPlanBadge({
    required this.entitlement,
    super.key,
  });

  final EntitlementSnapshot entitlement;

  @override
  Widget build(BuildContext context) {
    final isPremium = entitlement.isPremiumActive;
    final color = isPremium ? Colors.green.shade700 : Colors.black;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPremium ? Icons.workspace_premium : Icons.person_outline,
              size: 18,
              color: color,
            ),
            const SizedBox(width: 8),
            Text(
              _localizedPlanLabel(context, entitlement.tier),
              style: TextStyle(fontWeight: FontWeight.w700, color: color),
            ),
          ],
        ),
      ),
    );
  }

  String _localizedPlanLabel(BuildContext context, PlanTier tier) {
    switch (tier) {
      case PlanTier.free:
        return context.l10n.freePlan;
      case PlanTier.premium:
        return context.l10n.premiumPlan;
      case PlanTier.unknown:
        return context.l10n.unknownPlan;
      case PlanTier.pending:
        return context.l10n.pendingPlan;
    }
  }
}
