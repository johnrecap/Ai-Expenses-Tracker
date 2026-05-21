import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/ai/models/models.dart';
import 'package:expenses_tracker/monetization/monetization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class QuotaUsageCard extends StatelessWidget {
  const QuotaUsageCard({
    required this.state,
    super.key,
  });

  final MonetizationState state;

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
            Text(
              context.l10n.todayAiUsage,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            _QuotaLine(
              label: context.l10n.textParse,
              usage: state.usageFor(AiUsageRequestType.parseText),
            ),
            _QuotaLine(
              label: context.l10n.receipts,
              usage: state.usageFor(AiUsageRequestType.receiptExtraction),
            ),
            _QuotaLine(
              label: context.l10n.advice,
              usage: state.usageFor(AiUsageRequestType.financialAdvice),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuotaLine extends StatelessWidget {
  const _QuotaLine({
    required this.label,
    required this.usage,
  });

  final String label;
  final AiQuotaUsage usage;

  @override
  Widget build(BuildContext context) {
    final total = usage.limit + usage.rewardedCreditsAvailable;
    final used = usage.used.clamp(0, total).toInt();
    final reset = usage.resetAt == null
        ? null
        : DateFormat('HH:mm').format(usage.resetAt!.toLocal());
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label)),
              Text(
                usage.isStale
                    ? context.l10n.leftByDefault(usage.remaining)
                    : context.l10n.leftCount(usage.remaining),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: total == 0 ? 0 : used / total,
            minHeight: 7,
            borderRadius: BorderRadius.circular(99),
          ),
          if (usage.isStale || reset != null) ...[
            const SizedBox(height: 4),
            Text(
              usage.isStale
                  ? context.l10n.showingPolicyDefaultsUntilWorker
                  : context.l10n.resetsAroundWithPeriod(reset!),
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ],
      ),
    );
  }
}
