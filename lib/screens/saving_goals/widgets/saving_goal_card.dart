import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/screens/settings/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SavingGoalCard extends StatelessWidget {
  final SavingGoal goal;
  final VoidCallback onEdit;
  final VoidCallback onContribute;
  final VoidCallback onArchive;

  const SavingGoalCard({
    super.key,
    required this.goal,
    required this.onEdit,
    required this.onContribute,
    required this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    final deadline = goal.deadline;
    final remainingAmount = goal.remainingAmount;
    final remainingLabel = remainingAmount <= 0
        ? context.l10n.goalReached
        : context.l10n.remainingAmountLabel(
            formatAmountWithCurrency(remainingAmount, goal.currency),
          );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.savedPercentLabel(
                        goal.progressPercent.toStringAsFixed(0),
                      ),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: context.l10n.addContribution,
                icon: const Icon(Icons.add_card_outlined),
                onPressed: onContribute,
              ),
              IconButton(
                tooltip: context.l10n.edit,
                icon: const Icon(Icons.edit_outlined),
                onPressed: onEdit,
              ),
              IconButton(
                tooltip: context.l10n.archive,
                icon: const Icon(Icons.archive_outlined),
                onPressed: onArchive,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: goal.progressRatio,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${formatAmountWithCurrency(goal.currentAmount, goal.currency)} / '
                  '${formatAmountWithCurrency(goal.targetAmount, goal.currency)}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                remainingLabel,
                style: TextStyle(
                  color: goal.isComplete
                      ? Colors.green.shade700
                      : Theme.of(context).colorScheme.outline,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (deadline != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.event_outlined, size: 16),
                const SizedBox(width: 6),
                Text(
                  context.l10n.deadlineDateLabel(
                    DateFormat('MMM d, yyyy').format(deadline),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
