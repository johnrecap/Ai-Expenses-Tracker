import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/l10n/l10n.dart';
import 'package:expenses_tracker/screens/onboarding/blocs/onboarding_cubit.dart';
import 'package:expenses_tracker/screens/onboarding/widgets/ai_intro_step.dart';
import 'package:expenses_tracker/screens/onboarding/widgets/essentials_step.dart';
import 'package:expenses_tracker/screens/onboarding/widgets/reminder_setup_step.dart';
import 'package:expenses_tracker/services/notifications/notification_scheduler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FirstRunSetupScreen extends StatelessWidget {
  const FirstRunSetupScreen({
    required SettingsRepository settingsRepository,
    required ExpenseRepository expenseRepository,
    required this.onCompleted,
    NotificationScheduler? notificationScheduler,
    super.key,
  })  : _settingsRepository = settingsRepository,
        _expenseRepository = expenseRepository,
        _notificationScheduler = notificationScheduler,
        _cubit = null;

  const FirstRunSetupScreen.withCubit({
    required OnboardingCubit cubit,
    required this.onCompleted,
    super.key,
  })  : _cubit = cubit,
        _settingsRepository = null,
        _expenseRepository = null,
        _notificationScheduler = null;

  final SettingsRepository? _settingsRepository;
  final ExpenseRepository? _expenseRepository;
  final NotificationScheduler? _notificationScheduler;
  final OnboardingCubit? _cubit;
  final ValueChanged<UserSettings> onCompleted;

  @override
  Widget build(BuildContext context) {
    final cubit = _cubit;
    if (cubit != null) {
      return BlocProvider<OnboardingCubit>.value(
        value: cubit,
        child: _FirstRunSetupView(onCompleted: onCompleted),
      );
    }

    return BlocProvider(
      create: (_) => OnboardingCubit(
        settingsRepository: _settingsRepository!,
        notificationScheduler:
            _notificationScheduler ?? NotificationScheduler.instance,
        loadExpenses: _expenseRepository!.getExpenses,
      )..load(),
      child: _FirstRunSetupView(onCompleted: onCompleted),
    );
  }
}

class _FirstRunSetupView extends StatelessWidget {
  const _FirstRunSetupView({required this.onCompleted});

  final ValueChanged<UserSettings> onCompleted;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listenWhen: (previous, current) {
        return previous.step != current.step ||
            previous.failure != current.failure ||
            previous.warning != current.warning;
      },
      listener: (context, state) {
        if (state.isComplete && state.settings != null) {
          onCompleted(state.settings!);
          return;
        }

        final l10n = context.l10n;
        final failure = state.failure;
        if (failure != null && failure != OnboardingFailure.loadFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_failureMessage(l10n, failure))),
          );
        }
        if (state.warning == OnboardingWarning.remindersDisabled) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.onboardingReminderPermissionDenied)),
          );
        }
      },
      builder: (context, state) {
        final locale = state.selectedLanguagePreference?.languageCode;
        final child = Builder(
          builder: (context) => _SetupScaffold(state: state),
        );
        if (locale == null) return child;
        return Localizations.override(
          context: context,
          locale: Locale(locale),
          child: child,
        );
      },
    );
  }

  String _failureMessage(
    AppLocalizations l10n,
    OnboardingFailure failure,
  ) {
    switch (failure) {
      case OnboardingFailure.loadFailed:
        return l10n.onboardingLoadFailed;
      case OnboardingFailure.requiredChoicesMissing:
        return l10n.onboardingSelectRequired;
      case OnboardingFailure.saveFailed:
        return l10n.onboardingSaveFailed;
    }
  }
}

class _SetupScaffold extends StatelessWidget {
  const _SetupScaffold({required this.state});

  final OnboardingState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (state.isLoading) {
      return Scaffold(
        body: Center(
          child: Semantics(
            label: l10n.onboardingLoading,
            child: const CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (state.failure == OnboardingFailure.loadFailed &&
        state.settings == null) {
      return Scaffold(
        body: _SetupError(message: l10n.onboardingLoadFailed),
      );
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.onboardingTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(value: _progressValue),
                      const SizedBox(height: 28),
                      _StepBody(state: state),
                      const SizedBox(height: 24),
                      _StepActions(state: state),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  double get _progressValue {
    switch (state.step) {
      case OnboardingStep.essentials:
        return 1 / 3;
      case OnboardingStep.aiIntro:
        return 2 / 3;
      case OnboardingStep.reminders:
      case OnboardingStep.complete:
        return 1;
    }
  }
}

class _StepBody extends StatelessWidget {
  const _StepBody({required this.state});

  final OnboardingState state;

  @override
  Widget build(BuildContext context) {
    switch (state.step) {
      case OnboardingStep.essentials:
        return EssentialsStep(state: state);
      case OnboardingStep.aiIntro:
        return const AiIntroStep();
      case OnboardingStep.reminders:
        return ReminderSetupStep(state: state);
      case OnboardingStep.complete:
        return Center(child: Text(context.l10n.onboardingComplete));
    }
  }
}

class _StepActions extends StatelessWidget {
  const _StepActions({required this.state});

  final OnboardingState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<OnboardingCubit>();
    final primaryChild = state.isSaving
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(_primaryLabel(l10n));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(
          key: const Key('onboarding-primary-action'),
          onPressed: _primaryEnabled
              ? () {
                  switch (state.step) {
                    case OnboardingStep.essentials:
                      cubit.continueFromEssentials();
                      break;
                    case OnboardingStep.aiIntro:
                      cubit.continueFromAiIntro();
                      break;
                    case OnboardingStep.reminders:
                      cubit.finish();
                      break;
                    case OnboardingStep.complete:
                      break;
                  }
                }
              : null,
          child: primaryChild,
        ),
        if (state.step == OnboardingStep.reminders) ...[
          const SizedBox(height: 8),
          TextButton(
            key: const Key('onboarding-skip-reminders'),
            onPressed: state.isSaving ? null : cubit.skipReminders,
            child: Text(l10n.onboardingSkipReminders),
          ),
        ],
        if (state.step == OnboardingStep.aiIntro ||
            state.step == OnboardingStep.reminders) ...[
          const SizedBox(height: 8),
          TextButton(
            key: const Key('onboarding-back'),
            onPressed: state.isSaving ? null : cubit.goBack,
            child: Text(l10n.onboardingBack),
          ),
        ],
      ],
    );
  }

  bool get _primaryEnabled {
    if (state.isSaving) return false;
    if (state.step == OnboardingStep.essentials) {
      return state.canContinueEssentials;
    }
    return state.step != OnboardingStep.complete;
  }

  String _primaryLabel(AppLocalizations l10n) {
    switch (state.step) {
      case OnboardingStep.essentials:
      case OnboardingStep.aiIntro:
        return l10n.onboardingContinue;
      case OnboardingStep.reminders:
        return l10n.onboardingFinish;
      case OnboardingStep.complete:
        return l10n.onboardingComplete;
    }
  }
}

class _SetupError extends StatelessWidget {
  const _SetupError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: context.read<OnboardingCubit>().load,
              child: Text(context.l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
