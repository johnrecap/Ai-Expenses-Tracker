import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/screens/onboarding/blocs/onboarding_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReminderSetupStep extends StatelessWidget {
  const ReminderSetupStep({
    required this.state,
    super.key,
  });

  final OnboardingState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.onboardingReminderTitle,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.onboardingReminderSubtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 24),
        _ReminderSwitch(
          key: const Key('onboarding-daily-reminder'),
          icon: Icons.today_outlined,
          title: l10n.onboardingDailyReminder,
          subtitle: l10n.onboardingDailyReminderDescription,
          value: state.notificationChoice.dailyReminderEnabled,
          onChanged: state.isSaving
              ? null
              : context.read<OnboardingCubit>().setDailyReminderEnabled,
        ),
        const SizedBox(height: 12),
        _ReminderSwitch(
          key: const Key('onboarding-weekly-digest'),
          icon: Icons.summarize_outlined,
          title: l10n.onboardingWeeklyDigest,
          subtitle: l10n.onboardingWeeklyDigestDescription,
          value: state.notificationChoice.weeklyDigestEnabled,
          onChanged: state.isSaving
              ? null
              : context.read<OnboardingCubit>().setWeeklyDigestEnabled,
        ),
        const SizedBox(height: 20),
        Text(
          l10n.onboardingReminderLater,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _ReminderSwitch extends StatelessWidget {
  const _ReminderSwitch({
    required super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
        color: colorScheme.surface,
      ),
      child: SwitchListTile(
        secondary: Icon(icon),
        value: value,
        title: Text(title),
        subtitle: Text(subtitle),
        onChanged: onChanged,
        contentPadding: const EdgeInsetsDirectional.only(
          start: 12,
          end: 8,
        ),
      ),
    );
  }
}
