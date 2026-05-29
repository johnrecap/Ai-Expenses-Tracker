import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/screens/settings/utils/currency_formatter.dart';
import 'package:expenses_tracker/services/budget_calculator.dart';
import 'package:flutter/material.dart';

class BudgetProgressCard extends StatelessWidget {
  final BudgetProgress progress;
  final VoidCallback onManage;

  const BudgetProgressCard({
    super.key,
    required this.progress,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final budget = progress.budget;
    if (budget == null) {
      return _BudgetCardShell(
        title: l10n.monthlyBudgetTitle,
        actionLabel: l10n.budgetSetAction,
        onManage: onManage,
        child: Text(
          l10n.budgetNoBudgetSet,
          style: TextStyle(color: Theme.of(context).colorScheme.outline),
        ),
      );
    }

    final percent = progress.percentUsed.clamp(0, 1).toDouble();
    final statusColor = _statusColor(context);

    return _BudgetCardShell(
      title: l10n.monthlyBudgetTitle,
      actionLabel: l10n.edit,
      onManage: onManage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _Metric(
                  label: l10n.budgetSpentLabel,
                  value: formatAmountWithCurrency(
                    progress.spent,
                    budget.currency,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Metric(
                  label: l10n.budgetRemainingLabel,
                  value: formatAmountWithCurrency(
                    progress.remaining,
                    budget.currency,
                  ),
                  alignEnd: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: percent,
              color: statusColor,
              backgroundColor: Colors.grey.shade200,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.budgetPercentOfLimit(
              (progress.percentUsed * 100).toStringAsFixed(0),
              formatAmountWithCurrency(budget.amount, budget.currency),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(context).colorScheme.outline,
              fontSize: 12,
            ),
          ),
          if (_warningText(l10n) != null) ...[
            const SizedBox(height: 8),
            Text(
              _warningText(l10n)!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
            ),
          ],
          if (progress.ignoredCurrencyCount > 0) ...[
            const SizedBox(height: 6),
            Text(
              l10n.budgetIgnoredCurrencyExpenses(progress.ignoredCurrencyCount),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _statusColor(BuildContext context) {
    switch (progress.status) {
      case BudgetProgressStatus.exceeded:
        return Theme.of(context).colorScheme.error;
      case BudgetProgressStatus.nearLimit:
        return Colors.orange.shade700;
      case BudgetProgressStatus.normal:
      case BudgetProgressStatus.none:
        return Theme.of(context).colorScheme.primary;
    }
  }

  String? _warningText(AppLocalizations l10n) {
    switch (progress.status) {
      case BudgetProgressStatus.exceeded:
        return l10n.budgetExceededWarning;
      case BudgetProgressStatus.nearLimit:
        return l10n.budgetNearLimitWarning;
      case BudgetProgressStatus.normal:
      case BudgetProgressStatus.none:
        return null;
    }
  }
}

class _BudgetCardShell extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onManage;
  final Widget child;

  const _BudgetCardShell({
    required this.title,
    required this.actionLabel,
    required this.onManage,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              TextButton(
                onPressed: onManage,
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 40),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: Text(
                  actionLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final bool alignEnd;

  const _Metric({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Theme.of(context).colorScheme.outline,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
