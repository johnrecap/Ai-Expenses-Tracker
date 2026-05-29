import 'package:expenses_tracker/engagement/engagement.dart';
import 'package:flutter/material.dart';

class RetentionPromptPanel extends StatelessWidget {
  final List<RetentionPrompt> prompts;
  final ValueChanged<RetentionPrompt> onAction;

  const RetentionPromptPanel({
    required this.prompts,
    required this.onAction,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (prompts.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          for (var index = 0; index < prompts.length; index++) ...[
            _RetentionPromptTile(
              prompt: prompts[index],
              onTap: () => onAction(prompts[index]),
            ),
            if (index != prompts.length - 1) const Divider(height: 20),
          ],
        ],
      ),
    );
  }
}

class _RetentionPromptTile extends StatelessWidget {
  final RetentionPrompt prompt;
  final VoidCallback onTap;

  const _RetentionPromptTile({required this.prompt, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(_iconFor(prompt.kind), color: Theme.of(context).primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                prompt.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                prompt.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            minimumSize: const Size(0, 40),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: Text(
            prompt.actionLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  IconData _iconFor(RetentionPromptKind kind) {
    switch (kind) {
      case RetentionPromptKind.onboarding:
        return Icons.checklist_outlined;
      case RetentionPromptKind.streak:
        return Icons.local_fire_department_outlined;
      case RetentionPromptKind.weeklySummary:
        return Icons.insights_outlined;
      case RetentionPromptKind.budgetNudge:
        return Icons.account_balance_wallet_outlined;
      case RetentionPromptKind.spendingChallenge:
        return Icons.flag_outlined;
    }
  }
}
