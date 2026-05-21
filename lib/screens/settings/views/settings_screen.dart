import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/guided_tour/guided_tour.dart';
import 'package:expenses_tracker/l10n/app_language_cubit.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/monetization/monetization.dart';
import 'package:expenses_tracker/screens/settings/blocs/settings_bloc/settings_cubit.dart';
import 'package:expenses_tracker/screens/settings/widgets/ai_settings_section.dart';
import 'package:expenses_tracker/screens/settings/widgets/currency_settings_section.dart';
import 'package:expenses_tracker/screens/settings/widgets/language_settings_section.dart';
import 'package:expenses_tracker/screens/settings/widgets/monetization_settings_section.dart';
import 'package:expenses_tracker/screens/settings/widgets/notification_settings_section.dart';
import 'package:expenses_tracker/screens/settings/widgets/payment_settings_section.dart';
import 'package:expenses_tracker/screens/settings/widgets/profile_identity_section.dart';
import 'package:expenses_tracker/screens/settings/widgets/privacy_settings_section.dart';
import 'package:expenses_tracker/screens/settings/widgets/security_settings_section.dart';
import 'package:expenses_tracker/screens/settings/widgets/settings_section.dart';
import 'package:expenses_tracker/screens/settings/widgets/support_settings_section.dart';
import 'package:expenses_tracker/services/notifications/notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsScreen extends StatelessWidget {
  final List<Expense> expenses;

  const SettingsScreen({
    this.expenses = const [],
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SettingsCubit(context.read<SettingsRepository>())..loadSettings(),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.grey[100],
          elevation: 0,
          title: Text(
            context.l10n.settings,
            style: const TextStyle(color: Colors.black),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: BlocConsumer<SettingsCubit, SettingsState>(
          listener: (context, state) {
            if (state is SettingsFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
            if (state is SettingsSuccess) {
              try {
                context
                    .read<AppLanguageCubit>()
                    .setPreference(state.settings.languagePreference);
              } catch (_) {}
            }
          },
          builder: (context, state) {
            if (state is SettingsLoading || state is SettingsInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is SettingsFailure) {
              return _SettingsError(
                message: state.message,
              );
            }

            if (state is SettingsSuccess) {
              return _SettingsForm(
                settings: state.settings,
                isSaving: state is SettingsSaving,
                expenses: expenses,
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _SettingsForm extends StatelessWidget {
  final UserSettings settings;
  final bool isSaving;
  final List<Expense> expenses;

  const _SettingsForm({
    required this.settings,
    required this.isSaving,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = 16 + MediaQuery.viewPaddingOf(context).bottom;
    return SafeArea(
      top: false,
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding),
        children: [
          ProfileIdentitySection(
            fallbackAccountId: settings.userId,
          ),
          const SizedBox(height: 16),
          LanguageSettingsSection(
            settings: settings,
            isSaving: isSaving,
          ),
          const SizedBox(height: 16),
          SettingsSection(
            title: context.l10n.guidedTourSettingsSectionTitle,
            subtitle: context.l10n.guidedTourSettingsSectionDescription,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.tips_and_updates_outlined),
              title: Text(context.l10n.guidedTourReplayTour),
              subtitle: Text(context.l10n.guidedTourReplayTourDescription),
              trailing: const Icon(Icons.replay),
              onTap: () => _replayTour(context),
            ),
          ),
          const SizedBox(height: 16),
          CurrencySettingsSection(
            settings: settings,
            isSaving: isSaving,
          ),
          const SizedBox(height: 16),
          PaymentSettingsSection(
            settings: settings,
            isSaving: isSaving,
          ),
          const SizedBox(height: 16),
          NotificationSettingsSection(
            settings: settings.notificationSettings,
            isSaving: isSaving,
            onChanged: (notificationSettings) async {
              context
                  .read<SettingsCubit>()
                  .saveNotificationSettings(notificationSettings);
              await NotificationScheduler.instance.syncDailyReminder(
                settings: settings.copyWith(
                  notificationSettings: notificationSettings,
                  updatedAt: DateTime.now(),
                ),
                expenses: expenses,
              );
              await NotificationScheduler.instance.syncWeeklyDigest(
                settings: settings.copyWith(
                  notificationSettings: notificationSettings,
                  updatedAt: DateTime.now(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          const SecuritySettingsSection(),
          const SizedBox(height: 16),
          const AiSettingsSection(),
          const SizedBox(height: 16),
          const _OptionalMonetizationSettingsSection(),
          const SizedBox(height: 16),
          const PrivacySettingsSection(),
          const SizedBox(height: 16),
          const SupportSettingsSection(),
        ],
      ),
    );
  }

  void _replayTour(BuildContext context) {
    final guidedTourCubit = _readGuidedTourCubit(context);
    if (guidedTourCubit == null) return;
    if (!Navigator.of(context).canPop()) {
      guidedTourCubit.replay();
      return;
    }
    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      guidedTourCubit.replay();
    });
  }

  GuidedTourCubit? _readGuidedTourCubit(BuildContext context) {
    try {
      return context.read<GuidedTourCubit>();
    } catch (_) {
      return null;
    }
  }
}

class _OptionalMonetizationSettingsSection extends StatelessWidget {
  const _OptionalMonetizationSettingsSection();

  @override
  Widget build(BuildContext context) {
    MonetizationCubit? monetizationCubit;
    try {
      monetizationCubit = context.read<MonetizationCubit>();
    } catch (_) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<MonetizationCubit, MonetizationState>(
      bloc: monetizationCubit,
      builder: (context, monetizationState) {
        return MonetizationSettingsSection(
          state: monetizationState,
          cubit: monetizationCubit,
        );
      },
    );
  }
}

class _SettingsError extends StatelessWidget {
  final String message;

  const _SettingsError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.failedToLoadSettings,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.read<SettingsCubit>().loadSettings(),
              style: TextButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: Text(context.l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
