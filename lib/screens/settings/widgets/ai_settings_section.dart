import 'package:expenses_tracker/ai/models/models.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/monetization/monetization.dart';
import 'package:expenses_tracker/screens/settings/widgets/settings_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class AiSettingsSection extends StatelessWidget {
  const AiSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    MonetizationCubit? monetizationCubit;
    try {
      monetizationCubit = context.read<MonetizationCubit>();
    } catch (_) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<MonetizationCubit, MonetizationState>(
      bloc: monetizationCubit,
      builder: (context, state) {
        return SettingsSection(
          title: l10n.aiUsageSettingsTitle,
          subtitle: l10n.aiUsageSettingsDescription,
          child: Column(
            children: [
              _UsageTile(
                label: l10n.aiUsageTextParsing,
                usage: state.usageFor(AiUsageRequestType.parseText),
              ),
              _UsageTile(
                label: l10n.aiUsageReceiptExtraction,
                usage: state.usageFor(AiUsageRequestType.receiptExtraction),
              ),
              _UsageTile(
                label: l10n.aiUsageFinancialAdvice,
                usage: state.usageFor(AiUsageRequestType.financialAdvice),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _UsageTile extends StatelessWidget {
  const _UsageTile({required this.label, required this.usage});

  final String label;
  final AiQuotaUsage usage;

  @override
  Widget build(BuildContext context) {
    final reset = usage.resetAt == null
        ? null
        : DateFormat('HH:mm').format(usage.resetAt!.toLocal());
    final subtitle = [
      context.l10n.aiUsageUsed(
        usage.used,
        usage.limit + usage.rewardedCreditsAvailable,
      ),
      if (reset != null) context.l10n.aiUsageResetsAround(reset),
      if (usage.isStale) context.l10n.aiUsageWaitingForLiveUsage,
    ].join(' - ');

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        usage.exhausted ? Icons.block_outlined : Icons.auto_awesome_outlined,
      ),
      title: Text(label),
      subtitle: Text(subtitle),
      trailing: Text(
        context.l10n.aiUsageRemaining(usage.remaining),
        style: TextStyle(
          color: usage.exhausted
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
