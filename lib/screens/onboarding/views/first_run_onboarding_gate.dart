import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/screens/onboarding/views/first_run_setup_screen.dart';
import 'package:expenses_tracker/services/notifications/notification_scheduler.dart';
import 'package:flutter/material.dart';

typedef AuthenticatedOnboardingBuilder = Widget Function(
  BuildContext context,
  UserSettings settings,
);

class FirstRunOnboardingGate extends StatefulWidget {
  const FirstRunOnboardingGate({
    required this.settingsRepository,
    required this.expenseRepository,
    required this.authenticatedBuilder,
    this.notificationScheduler,
    super.key,
  });

  final SettingsRepository settingsRepository;
  final ExpenseRepository expenseRepository;
  final AuthenticatedOnboardingBuilder authenticatedBuilder;
  final NotificationScheduler? notificationScheduler;

  @override
  State<FirstRunOnboardingGate> createState() => _FirstRunOnboardingGateState();
}

class _FirstRunOnboardingGateState extends State<FirstRunOnboardingGate> {
  late Future<UserSettings> _settingsFuture;

  @override
  void initState() {
    super.initState();
    _settingsFuture = widget.settingsRepository.getSettings();
  }

  @override
  void didUpdateWidget(FirstRunOnboardingGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settingsRepository != widget.settingsRepository) {
      _settingsFuture = widget.settingsRepository.getSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserSettings>(
      future: _settingsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return _OnboardingGateError(
            onRetry: () {
              setState(() {
                _settingsFuture = widget.settingsRepository.getSettings();
              });
            },
          );
        }

        final settings = snapshot.data!;
        if (settings.requiresOnboarding) {
          return FirstRunSetupScreen(
            settingsRepository: widget.settingsRepository,
            expenseRepository: widget.expenseRepository,
            notificationScheduler: widget.notificationScheduler,
            onCompleted: (completedSettings) {
              setState(() {
                _settingsFuture = Future.value(completedSettings);
              });
            },
          );
        }

        return Localizations.override(
          context: context,
          locale: _localeFor(settings, Localizations.localeOf(context)),
          child: Builder(
            builder: (context) {
              return widget.authenticatedBuilder(context, settings);
            },
          ),
        );
      },
    );
  }

  Locale _localeFor(UserSettings settings, Locale fallback) {
    final languageCode = settings.languagePreference.languageCode;
    if (languageCode == null) return fallback;
    return Locale(languageCode);
  }
}

class _OnboardingGateError extends StatelessWidget {
  const _OnboardingGateError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.onboardingLoadFailed,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onRetry,
                child: Text(context.l10n.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
