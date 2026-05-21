import 'package:expenses_tracker/engagement/engagement.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/screens/settings/utils/currency_formatter.dart';
import 'package:flutter/material.dart';

class WeeklyDigestScreen extends StatelessWidget {
  final WeeklyDigest digest;
  final SpendingHealthScore healthScore;

  const WeeklyDigestScreen({
    required this.digest,
    required this.healthScore,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          l10n.weeklyDigest,
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DigestCard(
            child: digest.isEmpty
                ? Text(l10n.weeklyDigestEmpty)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MetricRow(
                        label: l10n.weeklyDigestThisWeek,
                        value: formatAmountWithCurrency(
                          digest.currentTotal,
                          digest.report.currency,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _MetricRow(
                        label: l10n.weeklyDigestPreviousWeek,
                        value: formatAmountWithCurrency(
                          digest.previousTotal,
                          digest.report.currency,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _MetricRow(
                        label: l10n.weeklyDigestChange,
                        value: '${digest.deltaPercent.toStringAsFixed(0)}%',
                      ),
                      if (digest.topCategory != null) ...[
                        const SizedBox(height: 12),
                        _MetricRow(
                          label: l10n.topCategory,
                          value: digest.topCategory!.categoryName,
                        ),
                      ],
                    ],
                  ),
          ),
          const SizedBox(height: 16),
          _DigestCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.weeklyDigestLocalInsight,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(_localizedInsight(l10n, digest)),
                if (digest.ignoredCurrencyCount > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n.weeklyDigestIgnoredCurrencyExpenses(
                      digest.ignoredCurrencyCount,
                    ),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          _DigestCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.weeklyDigestHealthScore(
                    _localizedHealthLabel(l10n, healthScore),
                    healthScore.score,
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                for (final reason in healthScore.reasons) ...[
                  Text('- ${_localizedHealthReason(l10n, reason)}'),
                  const SizedBox(height: 4),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _localizedInsight(AppLocalizations l10n, WeeklyDigest digest) {
    final topCategory = digest.topCategory;
    if (digest.currentTotal == 0 && digest.previousTotal == 0) {
      return l10n.weeklyInsightStartLogging;
    }
    if (topCategory != null && digest.currentTotal > 0) {
      final share = topCategory.total / digest.currentTotal;
      if (share >= 0.5) {
        return l10n.weeklyInsightTopCategory(topCategory.categoryName);
      }
    }
    if (digest.previousTotal == 0 && digest.currentTotal > 0) {
      return l10n.weeklyInsightFirstTrackedWeek;
    }
    if (digest.deltaPercent > 0) return l10n.weeklyInsightHigherThanLastWeek;
    if (digest.deltaPercent < 0) return l10n.weeklyInsightLowerThanLastWeek;
    return l10n.weeklyInsightUnchanged;
  }

  String _localizedHealthLabel(
    AppLocalizations l10n,
    SpendingHealthScore healthScore,
  ) {
    switch (healthScore.status) {
      case SpendingHealthStatus.good:
        return l10n.spendingHealthOnTrack;
      case SpendingHealthStatus.watch:
        return l10n.spendingHealthWorthWatching;
      case SpendingHealthStatus.risk:
        return l10n.spendingHealthNeedsReview;
      case SpendingHealthStatus.insufficientData:
        return l10n.spendingHealthAddFewExpenses;
    }
  }

  String _localizedHealthReason(AppLocalizations l10n, String reason) {
    switch (reason) {
      case 'Log expenses or set a monthly budget to see a score.':
        return l10n.spendingHealthReasonLogExpensesOrBudget;
      case 'Monthly budget is exceeded.':
        return l10n.spendingHealthReasonBudgetExceeded;
      case 'Monthly budget is near its limit.':
        return l10n.spendingHealthReasonBudgetNearLimit;
      case 'Monthly budget is on track.':
        return l10n.spendingHealthReasonBudgetOnTrack;
      case 'No monthly budget is set.':
        return l10n.spendingHealthReasonNoBudget;
      case 'One category is over 60% of this month\'s spending.':
        return l10n.spendingHealthReasonOneCategoryHigh;
      case 'Spending is spread across categories.':
        return l10n.spendingHealthReasonSpreadAcrossCategories;
      case 'Today has at least one logged expense.':
        return l10n.spendingHealthReasonTrackedToday;
      case 'Recent tracking activity is active.':
        return l10n.spendingHealthReasonRecentTracking;
      case 'No recent tracking streak yet.':
        return l10n.spendingHealthReasonNoRecentStreak;
      default:
        return reason;
    }
  }
}

class _DigestCard extends StatelessWidget {
  final Widget child;

  const _DigestCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;

  const _MetricRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: Theme.of(context).colorScheme.outline),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
