enum RetentionPromptKind {
  onboarding,
  streak,
  weeklySummary,
  budgetNudge,
  spendingChallenge,
}

class RetentionPrompt {
  final RetentionPromptKind kind;
  final String title;
  final String message;
  final String actionLabel;

  const RetentionPrompt({
    required this.kind,
    required this.title,
    required this.message,
    required this.actionLabel,
  });
}
