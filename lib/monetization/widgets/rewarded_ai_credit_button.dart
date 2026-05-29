import 'package:expenses_tracker/ai/models/models.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:flutter/material.dart';

import '../cubit/monetization_cubit.dart';

class RewardedAiCreditButton extends StatefulWidget {
  const RewardedAiCreditButton({
    required this.cubit,
    required this.requestType,
    this.label,
    super.key,
  });

  final MonetizationCubit cubit;
  final AiUsageRequestType requestType;
  final String? label;

  @override
  State<RewardedAiCreditButton> createState() => _RewardedAiCreditButtonState();
}

class _RewardedAiCreditButtonState extends State<RewardedAiCreditButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _loading
          ? null
          : () async {
              setState(() => _loading = true);
              final l10n = context.l10n;
              final messenger = ScaffoldMessenger.of(context);
              final credit = await widget.cubit.requestRewardedCredit(
                widget.requestType,
              );
              if (!mounted) return;
              setState(() => _loading = false);
              final message = credit == null
                  ? l10n.rewardUnavailable
                  : l10n.extraAiUseAdded;
              messenger.showSnackBar(SnackBar(content: Text(message)));
            },
      icon: _loading
          ? const SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.play_circle_outline),
      label: Text(widget.label ?? context.l10n.watchAdForExtraAiUse),
    );
  }
}
