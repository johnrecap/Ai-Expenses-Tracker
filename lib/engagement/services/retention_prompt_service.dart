import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/engagement/engagement.dart';
import 'package:expenses_tracker/services/budget_calculator.dart';

class RetentionPromptService {
  const RetentionPromptService();

  List<RetentionPrompt> buildPrompts({
    required List<Expense> expenses,
    required BudgetProgress budgetProgress,
    required TrackingStreak streak,
    required WeeklyDigest digest,
  }) {
    if (expenses.isEmpty) {
      return const [
        RetentionPrompt(
          kind: RetentionPromptKind.onboarding,
          title: 'Start your setup',
          message: 'Add one expense, create categories, then set a budget.',
          actionLabel: 'Add expense',
        ),
      ];
    }

    final prompts = <RetentionPrompt>[];

    if (!streak.hasTrackedToday) {
      prompts.add(
        RetentionPrompt(
          kind: RetentionPromptKind.streak,
          title: 'Keep your streak',
          message: streak.currentStreakDays == 0
              ? 'Log today once to start a tracking streak.'
              : 'Log today to keep your ${streak.currentStreakDays}-day streak.',
          actionLabel: 'Log expense',
        ),
      );
    }

    if (!digest.isEmpty && digest.topCategory != null) {
      prompts.add(
        RetentionPrompt(
          kind: RetentionPromptKind.weeklySummary,
          title: 'Weekly check-in',
          message:
              '${digest.topCategory!.categoryName} is your top category this week.',
          actionLabel: 'View digest',
        ),
      );
    }

    switch (budgetProgress.status) {
      case BudgetProgressStatus.exceeded:
        prompts.add(
          const RetentionPrompt(
            kind: RetentionPromptKind.budgetNudge,
            title: 'Budget review',
            message: 'Your monthly budget is over target. Review recent spend.',
            actionLabel: 'Review budget',
          ),
        );
        break;
      case BudgetProgressStatus.nearLimit:
        prompts.add(
          const RetentionPrompt(
            kind: RetentionPromptKind.budgetNudge,
            title: 'Budget nudge',
            message: 'You are near your budget limit. Check your top category.',
            actionLabel: 'Open budget',
          ),
        );
        break;
      case BudgetProgressStatus.none:
        prompts.add(
          const RetentionPrompt(
            kind: RetentionPromptKind.spendingChallenge,
            title: 'Set a simple target',
            message: 'Add a monthly budget to make progress easier to track.',
            actionLabel: 'Set budget',
          ),
        );
        break;
      case BudgetProgressStatus.normal:
        if (streak.currentStreakDays >= 3) {
          prompts.add(
            const RetentionPrompt(
              kind: RetentionPromptKind.spendingChallenge,
              title: 'Three-day challenge',
              message: 'Keep tracking for the rest of the week.',
              actionLabel: 'Continue',
            ),
          );
        }
        break;
    }

    return prompts.take(2).toList(growable: false);
  }
}
