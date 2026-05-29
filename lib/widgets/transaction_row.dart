import 'package:expenses_tracker/theme/app_design_tokens.dart';
import 'package:expenses_tracker/widgets/finance_card.dart';
import 'package:expenses_tracker/widgets/money_amount_text.dart';
import 'package:flutter/material.dart';

class TransactionRow extends StatelessWidget {
  const TransactionRow({
    required this.title,
    required this.amount,
    required this.currencyCode,
    this.subtitle,
    this.dateText,
    this.icon = Icons.receipt_long,
    this.iconColor,
    this.leading,
    this.status,
    this.onTap,
    this.trailing,
    this.action,
    super.key,
  });

  final String title;
  final String amount;
  final String currencyCode;
  final String? subtitle;
  final String? dateText;
  final IconData icon;
  final Color? iconColor;
  final Widget? leading;
  final Widget? status;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final resolvedIconColor = iconColor ?? colorScheme.primary;

    return FinanceCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          leading ??
              SizedBox.square(
                dimension: 48,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: resolvedIconColor.withValues(alpha: 0.14),
                    borderRadius: AppRadii.card,
                  ),
                  child: Icon(icon, color: resolvedIconColor),
                ),
              ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.rowTitle(context),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption(context),
                  ),
                ],
                if (status != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  status!,
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 132),
            child:
                trailing ??
                MoneyAmountText(
                  amount: amount,
                  currencyCode: currencyCode,
                  secondaryText: dateText,
                  textAlign: TextAlign.end,
                ),
          ),
          if (action != null) ...[
            const SizedBox(width: AppSpacing.xs),
            action!,
          ],
        ],
      ),
    );
  }
}
