import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/observability/observability.dart';
import 'package:expenses_tracker/screens/settings/widgets/settings_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

class SupportSettingsSection extends StatelessWidget {
  const SupportSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SettingsSection(
      title: l10n.support,
      subtitle: l10n.supportSettingsDescription,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.support_agent_outlined),
        title: Text(l10n.sendFeedback),
        subtitle: Text(l10n.sendFeedbackDescription),
        onTap: () async {
          ObservabilityService? observability;
          try {
            observability = context.read<ObservabilityService>();
          } catch (_) {
            observability = null;
          }
          await observability?.logEvent(ObservabilityEvent.feedbackOpened);
          if (!context.mounted) return;
          await _confirmAndShare(context);
        },
      ),
    );
  }

  Future<void> _confirmAndShare(BuildContext context) async {
    final l10n = context.l10n;
    final includeDiagnostics = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.sendFeedback),
        content: Text(l10n.feedbackDiagnosticsPrompt),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.no),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.includeVersion),
          ),
        ],
      ),
    );

    final diagnostics =
        includeDiagnostics == true ? '\n\n${l10n.appVersion}: 1.0.0+1' : '';
    await Share.share(
      '${l10n.feedbackShareTemplate}'
      '$diagnostics',
      subject: l10n.feedbackSubject,
    );
  }
}
