import 'package:expenses_tracker/feature_flags/feature_readiness.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/monetization/monetization.dart';
import 'package:expenses_tracker/screens/monetization/views/free_premium_screen.dart';
import 'package:flutter/material.dart';

class MonetizationSettingsSection extends StatelessWidget {
  const MonetizationSettingsSection({
    required this.state,
    this.cubit,
    super.key,
  });

  final MonetizationState state;
  final MonetizationCubit? cubit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isPremium = state.entitlement.isPremiumActive;
    final isLoading =
        state.status == MonetizationLoadStatus.initial ||
        state.status == MonetizationLoadStatus.loading;
    final hasLoadError =
        state.status == MonetizationLoadStatus.failure &&
        state.errorMessage?.trim().isNotEmpty == true;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              isPremium ? Icons.workspace_premium : Icons.person_outline,
            ),
            title: Text(_planTitle(context, state.effectiveTier)),
            subtitle: Text(
              isLoading
                  ? l10n.loadingLivePlanState
                  : isPremium
                  ? l10n.adsDisabled
                  : l10n.premiumBackendVerificationUnavailable,
            ),
            trailing: isLoading
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => FreePremiumScreen(cubit: cubit),
                ),
              );
            },
          ),
          if (!isPremium)
            ListTile(
              leading: const Icon(Icons.block),
              title: Text(l10n.removeAds),
              subtitle: Text(
                l10n.readinessBody(FeatureReadiness.premiumPurchase),
              ),
            ),
          if (hasLoadError)
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(l10n.usingFreeSafePlanState),
              subtitle: Text(state.errorMessage!.trim()),
              trailing: cubit == null
                  ? null
                  : IconButton(
                      onPressed: () {
                        cubit!.load();
                      },
                      icon: const Icon(Icons.refresh),
                      tooltip: l10n.refreshPlanState,
                    ),
            ),
          if (state.consent.privacyOptionsRequired)
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: Text(l10n.privacyAndAdChoices),
              onTap: cubit?.showPrivacyOptions,
            ),
        ],
      ),
    );
  }

  String _planTitle(BuildContext context, PlanTier tier) {
    final l10n = context.l10n;
    switch (tier) {
      case PlanTier.free:
        return l10n.freePlan;
      case PlanTier.premium:
        return l10n.premiumPlan;
      case PlanTier.unknown:
        return l10n.unknownPlan;
      case PlanTier.pending:
        return l10n.pendingPlan;
    }
  }
}
