import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/services/notifications/notification_scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum OnboardingStep {
  essentials,
  aiIntro,
  reminders,
  complete,
}

enum OnboardingFailure {
  loadFailed,
  requiredChoicesMissing,
  saveFailed,
}

enum OnboardingWarning {
  remindersDisabled,
}

class NotificationSetupChoice extends Equatable {
  const NotificationSetupChoice({
    this.dailyReminderEnabled = false,
    this.reminderTime = NotificationSettings.defaultReminderTime,
    this.weeklyDigestEnabled = false,
    this.weeklyDigestTime = NotificationSettings.defaultWeeklyDigestTime,
  });

  final bool dailyReminderEnabled;
  final String reminderTime;
  final bool weeklyDigestEnabled;
  final String weeklyDigestTime;

  bool get hasEnabledReminders => dailyReminderEnabled || weeklyDigestEnabled;

  NotificationSetupChoice copyWith({
    bool? dailyReminderEnabled,
    String? reminderTime,
    bool? weeklyDigestEnabled,
    String? weeklyDigestTime,
  }) {
    return NotificationSetupChoice(
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      weeklyDigestEnabled: weeklyDigestEnabled ?? this.weeklyDigestEnabled,
      weeklyDigestTime: weeklyDigestTime ?? this.weeklyDigestTime,
    );
  }

  NotificationSettings applyTo(NotificationSettings current) {
    return current.copyWith(
      dailyReminderEnabled: dailyReminderEnabled,
      reminderTime: reminderTime,
      weeklyDigestEnabled: weeklyDigestEnabled,
      weeklyDigestTime: weeklyDigestTime,
    );
  }

  @override
  List<Object?> get props => [
        dailyReminderEnabled,
        reminderTime,
        weeklyDigestEnabled,
        weeklyDigestTime,
      ];
}

class OnboardingState extends Equatable {
  const OnboardingState({
    this.step = OnboardingStep.essentials,
    this.settings,
    this.selectedLanguagePreference,
    this.selectedBaseCurrency,
    this.selectedPaymentMethod,
    this.notificationChoice = const NotificationSetupChoice(),
    this.isLoading = false,
    this.isSaving = false,
    this.failure,
    this.warning,
  });

  final OnboardingStep step;
  final UserSettings? settings;
  final LanguagePreference? selectedLanguagePreference;
  final String? selectedBaseCurrency;
  final PaymentMethod? selectedPaymentMethod;
  final NotificationSetupChoice notificationChoice;
  final bool isLoading;
  final bool isSaving;
  final OnboardingFailure? failure;
  final OnboardingWarning? warning;

  bool get isComplete => step == OnboardingStep.complete;

  bool get canContinueEssentials {
    return selectedLanguagePreference != null &&
        selectedLanguagePreference != LanguagePreference.system &&
        (selectedBaseCurrency?.trim().isNotEmpty ?? false) &&
        selectedPaymentMethod != null;
  }

  OnboardingState copyWith({
    OnboardingStep? step,
    Object? settings = _sentinel,
    Object? selectedLanguagePreference = _sentinel,
    Object? selectedBaseCurrency = _sentinel,
    Object? selectedPaymentMethod = _sentinel,
    NotificationSetupChoice? notificationChoice,
    bool? isLoading,
    bool? isSaving,
    Object? failure = _sentinel,
    Object? warning = _sentinel,
  }) {
    return OnboardingState(
      step: step ?? this.step,
      settings: identical(settings, _sentinel)
          ? this.settings
          : settings as UserSettings?,
      selectedLanguagePreference:
          identical(selectedLanguagePreference, _sentinel)
              ? this.selectedLanguagePreference
              : selectedLanguagePreference as LanguagePreference?,
      selectedBaseCurrency: identical(selectedBaseCurrency, _sentinel)
          ? this.selectedBaseCurrency
          : selectedBaseCurrency as String?,
      selectedPaymentMethod: identical(selectedPaymentMethod, _sentinel)
          ? this.selectedPaymentMethod
          : selectedPaymentMethod as PaymentMethod?,
      notificationChoice: notificationChoice ?? this.notificationChoice,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      failure: identical(failure, _sentinel)
          ? this.failure
          : failure as OnboardingFailure?,
      warning: identical(warning, _sentinel)
          ? this.warning
          : warning as OnboardingWarning?,
    );
  }

  @override
  List<Object?> get props => [
        step,
        settings,
        selectedLanguagePreference,
        selectedBaseCurrency,
        selectedPaymentMethod,
        notificationChoice,
        isLoading,
        isSaving,
        failure,
        warning,
      ];
}

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit({
    required SettingsRepository settingsRepository,
    NotificationScheduler? notificationScheduler,
    Future<List<Expense>> Function()? loadExpenses,
    Duration reminderSyncTimeout = const Duration(seconds: 5),
  })  : _settingsRepository = settingsRepository,
        _notificationScheduler = notificationScheduler,
        _loadExpenses = loadExpenses,
        _reminderSyncTimeout = reminderSyncTimeout,
        super(const OnboardingState());

  final SettingsRepository _settingsRepository;
  final NotificationScheduler? _notificationScheduler;
  final Future<List<Expense>> Function()? _loadExpenses;
  final Duration _reminderSyncTimeout;

  Future<void> load() async {
    emit(
      state.copyWith(
        isLoading: true,
        failure: null,
        warning: null,
      ),
    );
    try {
      final settings = await _settingsRepository.getSettings();
      final loadedState = settings.requiresOnboarding
          ? _stateForIncompleteSettings(settings)
          : state.copyWith(
              settings: settings,
              step: OnboardingStep.complete,
              selectedLanguagePreference: settings.languagePreference,
              selectedBaseCurrency: settings.baseCurrency,
              selectedPaymentMethod: settings.defaultPaymentMethod,
            );
      emit(
        loadedState.copyWith(
          isLoading: false,
          failure: null,
          warning: null,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          failure: OnboardingFailure.loadFailed,
          warning: null,
        ),
      );
    }
  }

  void selectLanguage(LanguagePreference preference) {
    if (preference == LanguagePreference.system) {
      emit(
        state.copyWith(
          selectedLanguagePreference: null,
          failure: null,
          warning: null,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        selectedLanguagePreference: preference,
        failure: null,
        warning: null,
      ),
    );
  }

  void selectBaseCurrency(String? currencyCode) {
    final normalized = currencyCode?.trim().toUpperCase();
    emit(
      state.copyWith(
        selectedBaseCurrency:
            normalized == null || normalized.isEmpty ? null : normalized,
        failure: null,
        warning: null,
      ),
    );
  }

  void selectPaymentMethod(PaymentMethod? paymentMethod) {
    emit(
      state.copyWith(
        selectedPaymentMethod: paymentMethod,
        failure: null,
        warning: null,
      ),
    );
  }

  void continueFromEssentials() {
    if (!state.canContinueEssentials) {
      emit(
        state.copyWith(
          failure: OnboardingFailure.requiredChoicesMissing,
          warning: null,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        step: OnboardingStep.aiIntro,
        failure: null,
        warning: null,
      ),
    );
  }

  void continueFromAiIntro() {
    emit(
      state.copyWith(
        step: OnboardingStep.reminders,
        failure: null,
        warning: null,
      ),
    );
  }

  void goBack() {
    switch (state.step) {
      case OnboardingStep.aiIntro:
        emit(
          state.copyWith(
            step: OnboardingStep.essentials,
            failure: null,
            warning: null,
          ),
        );
        return;
      case OnboardingStep.reminders:
        emit(
          state.copyWith(
            step: OnboardingStep.aiIntro,
            failure: null,
            warning: null,
          ),
        );
        return;
      case OnboardingStep.essentials:
      case OnboardingStep.complete:
        return;
    }
  }

  void setDailyReminderEnabled(bool enabled) {
    emit(
      state.copyWith(
        notificationChoice: state.notificationChoice.copyWith(
          dailyReminderEnabled: enabled,
        ),
        failure: null,
        warning: null,
      ),
    );
  }

  void setWeeklyDigestEnabled(bool enabled) {
    emit(
      state.copyWith(
        notificationChoice: state.notificationChoice.copyWith(
          weeklyDigestEnabled: enabled,
        ),
        failure: null,
        warning: null,
      ),
    );
  }

  Future<void> skipReminders() {
    return finish(skipReminders: true);
  }

  Future<void> finish({bool skipReminders = false}) async {
    if (!state.canContinueEssentials || state.settings == null) {
      emit(
        state.copyWith(
          failure: OnboardingFailure.requiredChoicesMissing,
          warning: null,
        ),
      );
      return;
    }

    final selectedBaseCurrency =
        state.selectedBaseCurrency!.trim().toUpperCase();
    final notificationChoice = skipReminders
        ? const NotificationSetupChoice()
        : state.notificationChoice;
    final now = DateTime.now();
    final updated = state.settings!.copyWith(
      languagePreference: state.selectedLanguagePreference,
      baseCurrency: selectedBaseCurrency,
      supportedCurrencies: _withRequiredCurrency(
        state.settings!.supportedCurrencies,
        selectedBaseCurrency,
      ),
      defaultPaymentMethod: state.selectedPaymentMethod,
      notificationSettings: notificationChoice.applyTo(
        state.settings!.notificationSettings,
      ),
      onboardingCompleted: true,
      onboardingVersion: UserSettings.currentOnboardingVersion,
      updatedAt: now,
    );

    emit(
      state.copyWith(
        isSaving: true,
        failure: null,
        warning: null,
      ),
    );

    try {
      await _settingsRepository.saveSettings(updated);
    } catch (_) {
      emit(
        state.copyWith(
          isSaving: false,
          failure: OnboardingFailure.saveFailed,
          warning: null,
        ),
      );
      return;
    }

    var finalSettings = updated;
    OnboardingWarning? warning;
    if (!skipReminders &&
        notificationChoice.hasEnabledReminders &&
        _notificationScheduler != null) {
      final synced = await _syncOptionalReminders(updated);
      if (!synced) {
        final disabledSettings = updated.copyWith(
          notificationSettings: updated.notificationSettings.copyWith(
            dailyReminderEnabled: false,
            weeklyDigestEnabled: false,
          ),
          updatedAt: DateTime.now(),
        );
        try {
          await _settingsRepository.saveSettings(disabledSettings);
          finalSettings = disabledSettings;
        } catch (_) {
          finalSettings = updated;
        }
        warning = OnboardingWarning.remindersDisabled;
      }
    }

    emit(
      state.copyWith(
        settings: finalSettings,
        step: OnboardingStep.complete,
        isSaving: false,
        failure: null,
        warning: warning,
      ),
    );
  }

  OnboardingState _stateForIncompleteSettings(UserSettings settings) {
    return state.copyWith(
      settings: settings,
      step: OnboardingStep.essentials,
      selectedLanguagePreference: settings.languagePreference.followsSystem
          ? null
          : settings.languagePreference,
      selectedBaseCurrency:
          settings.onboardingVersion > 0 ? settings.baseCurrency : null,
      selectedPaymentMethod:
          settings.onboardingVersion > 0 ? settings.defaultPaymentMethod : null,
      notificationChoice: NotificationSetupChoice(
        dailyReminderEnabled:
            settings.notificationSettings.dailyReminderEnabled,
        reminderTime: settings.notificationSettings.reminderTime,
        weeklyDigestEnabled: settings.notificationSettings.weeklyDigestEnabled,
        weeklyDigestTime: settings.notificationSettings.weeklyDigestTime,
      ),
    );
  }

  Future<bool> _syncOptionalReminders(UserSettings settings) async {
    try {
      final expenses = await (_loadExpenses?.call() ??
              Future<List<Expense>>.value(const <Expense>[]))
          .timeout(_reminderSyncTimeout);
      return await _notificationScheduler!
          .syncOptionalReminders(
            settings: settings,
            expenses: expenses,
          )
          .timeout(_reminderSyncTimeout);
    } catch (_) {
      return false;
    }
  }

  List<String> _withRequiredCurrency(
    List<String> currencyCodes,
    String requiredCurrency,
  ) {
    final normalized = <String>[];
    for (final code in [...currencyCodes, requiredCurrency]) {
      final value = code.trim().toUpperCase();
      if (value.isEmpty || normalized.contains(value)) continue;
      normalized.add(value);
    }
    return normalized;
  }
}

const Object _sentinel = Object();
