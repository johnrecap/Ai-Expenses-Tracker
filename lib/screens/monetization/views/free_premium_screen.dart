import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/monetization/monetization.dart';
import 'package:expenses_tracker/screens/monetization/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FreePremiumScreen extends StatelessWidget {
  const FreePremiumScreen({
    this.cubit,
    super.key,
  });

  final MonetizationCubit? cubit;

  @override
  Widget build(BuildContext context) {
    final providedCubit = cubit;
    if (providedCubit != null) {
      return BlocProvider.value(
        value: providedCubit,
        child: const _FreePremiumView(),
      );
    }

    try {
      final sharedCubit = context.read<MonetizationCubit>();
      return BlocProvider.value(
        value: sharedCubit,
        child: const _FreePremiumView(),
      );
    } catch (_) {
      // Direct test and development entry points may not have app auth wiring.
    }

    return BlocProvider(
      create: (_) => MonetizationCubit(
        entitlementRepository: LocalEntitlementRepository(),
        policyRepository: const LocalMonetizationPolicyRepository(),
      )..load(),
      child: const _FreePremiumView(),
    );
  }
}

class _FreePremiumView extends StatelessWidget {
  const _FreePremiumView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: const BackButton(),
        title: Text(
          context.l10n.freePremiumTitle,
          style: const TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<MonetizationCubit>().load();
            },
            icon: const Icon(Icons.refresh),
            tooltip: context.l10n.refreshPlanState,
          ),
        ],
      ),
      body: BlocConsumer<MonetizationCubit, MonetizationState>(
        listener: (context, state) {
          final message = state.purchaseMessage ?? state.errorMessage;
          if (message == null || message.trim().isEmpty) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        },
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (state.status == MonetizationLoadStatus.loading ||
                  state.status == MonetizationLoadStatus.initial) ...[
                const LinearProgressIndicator(),
                const SizedBox(height: 16),
              ],
              if (state.status == MonetizationLoadStatus.failure &&
                  state.errorMessage?.trim().isNotEmpty == true) ...[
                _FreeSafeWarningCard(message: state.errorMessage!.trim()),
                const SizedBox(height: 16),
              ],
              CurrentPlanBadge(entitlement: state.entitlement),
              const SizedBox(height: 16),
              _FreeStillWorksCard(state: state),
              const SizedBox(height: 16),
              QuotaUsageCard(state: state),
              const SizedBox(height: 16),
              const PlanComparisonTable(),
              const SizedBox(height: 16),
              _AdBehaviorCard(state: state),
              const SizedBox(height: 16),
              PremiumCtaPanel(
                state: state,
              ),
              if (state.consent.privacyOptionsRequired) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    context.read<MonetizationCubit>().showPrivacyOptions();
                  },
                  icon: const Icon(Icons.privacy_tip_outlined),
                  label: Text(context.l10n.privacyAndAdChoices),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _FreeSafeWarningCard extends StatelessWidget {
  const _FreeSafeWarningCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.l10n.planRefreshFailedFreeSafe(message),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FreeStillWorksCard extends StatelessWidget {
  const _FreeStillWorksCard({required this.state});

  final MonetizationState state;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.lock_open_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                state.entitlement.isPremiumActive
                    ? context.l10n.premiumStillWorks
                    : context.l10n.freeStillWorks,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdBehaviorCard extends StatelessWidget {
  const _AdBehaviorCard({required this.state});

  final MonetizationState state;

  @override
  Widget build(BuildContext context) {
    final premium = state.entitlement.isPremiumActive;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(premium ? Icons.block : Icons.ads_click_outlined),
                const SizedBox(width: 8),
                Text(
                  premium ? context.l10n.adsDisabled : context.l10n.adsOnFree,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              premium
                  ? context.l10n.premiumAdsDisabledBody
                  : context.l10n.freeAdsBody,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.consentStatusLabel(state.consent.statusLabel),
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
      ),
    );
  }
}
