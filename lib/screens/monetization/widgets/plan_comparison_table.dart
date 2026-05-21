import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:flutter/material.dart';

import 'plan_feature_row.dart';

class PlanComparisonTable extends StatelessWidget {
  const PlanComparisonTable({super.key});

  @override
  Widget build(BuildContext context) {
    final headerStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w800,
        );
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
            Row(
              children: [
                const Expanded(flex: 2, child: SizedBox.shrink()),
                Expanded(child: Text(context.l10n.free, style: headerStyle)),
                Expanded(
                  child: Text(context.l10n.premium, style: headerStyle),
                ),
              ],
            ),
            const Divider(height: 24),
            PlanFeatureRow(
              label: context.l10n.manualTracking,
              freeValue: context.l10n.included,
              premiumValue: context.l10n.included,
            ),
            PlanFeatureRow(
              label: context.l10n.aiTextParse,
              freeValue: '5/day',
              premiumValue: context.l10n.higherFiniteLimit,
            ),
            PlanFeatureRow(
              label: context.l10n.receipts,
              freeValue: '3/day',
              premiumValue: context.l10n.moreReceipts,
            ),
            PlanFeatureRow(
              label: context.l10n.advice,
              freeValue: '3/day',
              premiumValue: context.l10n.moreAdvice,
            ),
            PlanFeatureRow(
              label: context.l10n.ads,
              freeValue: context.l10n.politeAds,
              premiumValue: context.l10n.noAds,
            ),
            PlanFeatureRow(
              label: context.l10n.reportsExport,
              freeValue: context.l10n.basic,
              premiumValue: context.l10n.advancedLater,
            ),
          ],
        ),
      ),
    );
  }
}
