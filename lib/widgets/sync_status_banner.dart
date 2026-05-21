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
    if (pendingCount == 0) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final message = pendingCount == 1
        ? '1 expense is waiting to sync'
        : '$pendingCount expenses are waiting to sync';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: colorScheme.primaryContainer,
      child: Row(
        children: [
          Icon(
            Icons.cloud_sync_outlined,
            size: 18,
            color: colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: colorScheme.onPrimaryContainer,
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
    if (!expense.syncStatus.isPending) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule,
            size: 12,
            color: colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            'Pending',
            style: TextStyle(
              color: colorScheme.onSecondaryContainer,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
