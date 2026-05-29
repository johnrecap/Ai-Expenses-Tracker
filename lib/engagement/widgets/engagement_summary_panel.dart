import 'package:expenses_tracker/engagement/engagement.dart';
import 'package:expenses_tracker/engagement/widgets/weekly_digest_screen.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:flutter/material.dart';

class EngagementSummaryPanel extends StatelessWidget {
  final TrackingStreak streak;
  final WeeklyDigest digest;
  final SpendingHealthScore healthScore;

  const EngagementSummaryPanel({
    required this.streak,
    required this.digest,
    required this.healthScore,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _MetricTile(
              icon: Icons.local_fire_department_outlined,
              label: context.l10n.streak,
              value: streak.currentStreakDays == 1
                  ? context.l10n.dayCount(1)
                  : context.l10n.dayCount(streak.currentStreakDays),
              helper: streak.hasTrackedToday
                  ? context.l10n.trackedToday
                  : context.l10n.checkIn,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _MetricTile(
              icon: Icons.health_and_safety_outlined,
              label: context.l10n.health,
              value: healthScore.label,
              helper: healthScore.hasEnoughData
                  ? '${healthScore.score}/100'
                  : context.l10n.needsData,
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            tooltip: context.l10n.weeklyDigest,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => WeeklyDigestScreen(
                    digest: digest,
                    healthScore: healthScore,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.insights_outlined),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String helper;

  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.helper,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                  fontSize: 11,
                ),
              ),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                helper,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
