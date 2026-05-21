import 'package:expenses_tracker/feature_flags/feature_readiness.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/screens/settings/widgets/settings_section.dart';
import 'package:flutter/material.dart';

class PrivacySettingsSection extends StatelessWidget {
  const PrivacySettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SettingsSection(
      title: l10n.privacy,
      subtitle: l10n.privacySettingsDescription,
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.dataOwnership),
            subtitle: Text(l10n.dataOwnershipDescription),
          ),
          const _ReadinessTile(readiness: FeatureReadiness.backupExport),
          const _ReadinessTile(readiness: FeatureReadiness.restorePreview),
          const _ReadinessTile(readiness: FeatureReadiness.restoreExecution),
          const _ReadinessTile(readiness: FeatureReadiness.walletManagement),
          const _ReadinessTile(readiness: FeatureReadiness.transferManagement),
        ],
      ),
    );
  }
}

class _ReadinessTile extends StatelessWidget {
  const _ReadinessTile({required this.readiness});

  final FeatureReadiness readiness;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final label = readiness.state == ReadinessState.comingSoon
        ? l10n.readinessComingSoonLabel
        : l10n.readinessDisabledLabel;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      enabled: false,
      leading: Icon(_iconFor(readiness.surface)),
      title: Text(l10n.readinessTitle(readiness)),
      subtitle: Text(l10n.readinessBody(readiness)),
      trailing: Text(label),
    );
  }

  IconData _iconFor(FeatureSurface surface) {
    switch (surface) {
      case FeatureSurface.premiumPurchase:
      case FeatureSurface.premiumRestore:
        return Icons.workspace_premium_outlined;
      case FeatureSurface.walletManagement:
        return Icons.account_balance_wallet_outlined;
      case FeatureSurface.transferManagement:
        return Icons.swap_horiz;
      case FeatureSurface.backupExport:
        return Icons.download_outlined;
      case FeatureSurface.restorePreview:
        return Icons.fact_check_outlined;
      case FeatureSurface.restoreExecution:
        return Icons.lock_outline;
    }
  }
}
