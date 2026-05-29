import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/engagement/engagement.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/services/budget_calculator.dart';

class RetentionPromptService {
  const RetentionPromptService();

  List<RetentionPrompt> buildPrompts({
    required List<Expense> expenses,
    required BudgetProgress budgetProgress,
    required TrackingStreak streak,
    required WeeklyDigest digest,
    required AppLocalizations l10n,
  }) {
    if (expenses.isEmpty) {
      return [
        RetentionPrompt(
          kind: RetentionPromptKind.onboarding,
          title: l10n.retentionStartSetupTitle,
          message: l10n.retentionStartSetupMessage,
          actionLabel: l10n.addExpense,
        ),
      ];
    }

    final prompts = <RetentionPrompt>[];

    if (!streak.hasTrackedToday) {
      prompts.add(
        RetentionPrompt(
          kind: RetentionPromptKind.streak,
          title: l10n.retentionKeepStreakTitle,
          message: streak.currentStreakDays == 0
              ? l10n.retentionStartStreakMessage
              : l10n.retentionKeepStreakMessage(streak.currentStreakDays),
          actionLabel: l10n.retentionLogExpenseAction,
        ),
      );
    }

    if (!digest.isEmpty && digest.topCategory != null) {
      prompts.add(
        RetentionPrompt(
          kind: RetentionPromptKind.weeklySummary,
          title: l10n.weeklyCheckIn,
          message: l10n.weeklyInsightTopCategory(
            digest.topCategory!.categoryName,
          ),
          actionLabel: l10n.viewDigest,
        ),
      );
    }

    switch (budgetProgress.status) {
      case BudgetProgressStatus.exceeded:
        prompts.add(
          RetentionPrompt(
            kind: RetentionPromptKind.budgetNudge,
            title: l10n.retentionBudgetReviewTitle,
            message: l10n.retentionBudgetExceededMessage,
            actionLabel: l10n.retentionReviewBudgetAction,
          ),
        );
        break;
      case BudgetProgressStatus.nearLimit:
        prompts.add(
          RetentionPrompt(
            kind: RetentionPromptKind.budgetNudge,
            title: l10n.retentionBudgetNudgeTitle,
            message: l10n.retentionBudgetNearLimitMessage,
            actionLabel: l10n.retentionOpenBudgetAction,
          ),
        );
        break;
      case BudgetProgressStatus.none:
        prompts.add(
          RetentionPrompt(
            kind: RetentionPromptKind.spendingChallenge,
            title: l10n.retentionSetTargetTitle,
            message: l10n.retentionSetTargetMessage,
            actionLabel: l10n.retentionSetBudgetAction,
          ),
        );
        break;
      case BudgetProgressStatus.normal:
        if (streak.currentStreakDays >= 3) {
          prompts.add(
            RetentionPrompt(
              kind: RetentionPromptKind.spendingChallenge,
              title: l10n.retentionThreeDayChallengeTitle,
              message: l10n.retentionThreeDayChallengeMessage,
              actionLabel: l10n.continueAction,
            ),
          );
        }
        break;
    }

    return prompts.take(2).toList(growable: false);
  }
}
