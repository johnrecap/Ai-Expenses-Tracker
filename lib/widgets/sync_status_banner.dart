import 'package:expense_repository/expense_repository.dart';
import 'package:flutter/material.dart';

class SyncStatusBanner extends StatelessWidget {
  final List<Expense> expenses;

  const SyncStatusBanner({
    super.key,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    final pendingCount =
        expenses.where((expense) => expense.syncStatus.isPending).length;
    final failedCount =
        expenses.where((expense) => expense.syncStatus.isFailed).length;
    if (pendingCount == 0 && failedCount == 0) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final hasFailures = failedCount > 0;
    final message = hasFailures
        ? failedCount == 1
            ? '1 expense could not sync'
            : '$failedCount expenses could not sync'
        : pendingCount == 1
            ? '1 expense is waiting to sync'
            : '$pendingCount expenses are waiting to sync';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: hasFailures
          ? colorScheme.errorContainer
          : colorScheme.primaryContainer,
      child: Row(
        children: [
          Icon(
            hasFailures ? Icons.cloud_off_outlined : Icons.cloud_sync_outlined,
            size: 18,
            color: hasFailures
                ? colorScheme.onErrorContainer
                : colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: hasFailures
                    ? colorScheme.onErrorContainer
                    : colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExpenseSyncBadge extends StatelessWidget {
  final Expense expense;

  const ExpenseSyncBadge({
    super.key,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    if (!expense.syncStatus.isPending && !expense.syncStatus.isFailed) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final failed = expense.syncStatus.isFailed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: failed
            ? colorScheme.errorContainer
            : colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            failed ? Icons.cloud_off_outlined : Icons.schedule,
            size: 12,
            color: failed
                ? colorScheme.onErrorContainer
                : colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            failed ? 'Sync failed' : 'Pending',
            style: TextStyle(
              color: failed
                  ? colorScheme.onErrorContainer
                  : colorScheme.onSecondaryContainer,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
