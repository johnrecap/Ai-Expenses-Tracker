import 'package:expenses_tracker/theme/app_design_tokens.dart';
import 'package:expenses_tracker/widgets/finance_card.dart';
import 'package:flutter/material.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({
    required this.title,
    required this.child,
    this.subtitle,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FinanceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.sectionTitle(context)),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ],
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
