import 'dart:async';

import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/services/sync_retry_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SyncStatusBanner extends StatelessWidget {
  final List<Expense> expenses;
  final VoidCallback? onRetry;

  const SyncStatusBanner({super.key, required this.expenses, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final unresolved = expenses
        .where((expense) => expense.syncStatus.isUnresolved)
        .toList(growable: false);
    if (unresolved.isEmpty) return const SizedBox.shrink();

    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final hasFailures = unresolved.any(
      (expense) => expense.syncStatus.isFailed,
    );
    final status = _statusLabel(l10n, unresolved);
    final reason = _reasonFor(unresolved);
    final message =
        '${l10n.syncPendingCount(unresolved.length, status)}. '
        '${_reasonMessage(l10n, reason)}';
    final retry = onRetry ?? _retryFromContext(context);
    final canRetry = retry != null && reason.canRetry;

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
          if (canRetry) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: retry,
              style: TextButton.styleFrom(
                foregroundColor: hasFailures
                    ? colorScheme.onErrorContainer
                    : colorScheme.onPrimaryContainer,
              ),
              child: Text(l10n.retry),
            ),
          ],
        ],
      ),
    );
  }

  VoidCallback? _retryFromContext(BuildContext context) {
    try {
      final retryService = context.read<SyncRetryService>();
      return () => unawaited(retryService.retry());
    } catch (_) {
      return null;
    }
  }

  SyncStatusReason _reasonFor(List<Expense> expenses) {
    for (final reason in const [
      SyncStatusReason.auth,
      SyncStatusReason.server,
      SyncStatusReason.offline,
      SyncStatusReason.validation,
      SyncStatusReason.unknown,
      SyncStatusReason.syncing,
      SyncStatusReason.queued,
    ]) {
      if (expenses.any((expense) => expense.syncStatusReason == reason)) {
        return reason;
      }
    }
    return SyncStatusReason.queued;
  }

  String _statusLabel(AppLocalizations l10n, List<Expense> expenses) {
    if (expenses.any((expense) => expense.syncStatus.isFailed)) {
      return l10n.syncFailed.toLowerCase();
    }
    if (expenses.any((expense) => expense.syncStatus.isSyncing)) {
      return l10n.syncSyncing.toLowerCase();
    }
    return l10n.syncQueued.toLowerCase();
  }

  String _reasonMessage(AppLocalizations l10n, SyncStatusReason reason) {
    switch (reason) {
      case SyncStatusReason.offline:
        return l10n.syncPendingOffline;
      case SyncStatusReason.auth:
        return l10n.syncPendingAuth;
      case SyncStatusReason.server:
        return l10n.syncPendingServer;
      case SyncStatusReason.validation:
        return l10n.syncPendingValidation;
      case SyncStatusReason.syncing:
        return l10n.syncSyncing;
      case SyncStatusReason.queued:
        return l10n.syncPendingQueued;
      case SyncStatusReason.unknown:
        return l10n.syncPendingUnknown;
    }
  }
}

class ExpenseSyncBadge extends StatelessWidget {
  final Expense expense;

  const ExpenseSyncBadge({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    if (!expense.syncStatus.isUnresolved) {
      return const SizedBox.shrink();
    }

    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final failed = expense.syncStatus.isFailed;
    final syncing = expense.syncStatus.isSyncing;
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
            failed
                ? Icons.cloud_off_outlined
                : syncing
                ? Icons.cloud_sync_outlined
                : Icons.schedule,
            size: 12,
            color: failed
                ? colorScheme.onErrorContainer
                : colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            failed
                ? l10n.syncFailed
                : syncing
                ? l10n.syncSyncing
                : l10n.syncQueued,
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
