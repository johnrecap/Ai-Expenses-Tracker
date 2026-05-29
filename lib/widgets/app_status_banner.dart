import 'package:expenses_tracker/theme/app_design_tokens.dart';
import 'package:flutter/material.dart';

class AppStatusBanner extends StatelessWidget {
  const AppStatusBanner({
    required this.message,
    this.tone = AppStatusTone.info,
    this.icon,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String message;
  final AppStatusTone tone;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = AppSemanticColors.tone(Theme.of(context).colorScheme, tone);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: AppRadii.card,
        boxShadow: AppShadows.soft(Theme.of(context).colorScheme.shadow),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.info_outline,
              color: colors.foreground,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(width: AppSpacing.sm),
              TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  foregroundColor: colors.foreground,
                  visualDensity: VisualDensity.compact,
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
