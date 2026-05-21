part of 'settings_cubit.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsSuccess extends SettingsState {
  final UserSettings settings;

  const SettingsSuccess(this.settings);

  @override
  List<Object?> get props => [
        settings.userId,
        settings.languagePreference,
        settings.baseCurrency,
        settings.supportedCurrencies,
        settings.conversionRates,
        settings.defaultPaymentMethod,
        settings.notificationSettings.budgetAlertsEnabled,
        settings.notificationSettings.dailyReminderEnabled,
        settings.notificationSettings.reminderTime,
        settings.notificationSettings.weeklyDigestEnabled,
        settings.notificationSettings.weeklyDigestTime,
        settings.notificationSettings.lastExceededAlertMonth,
        settings.onboardingCompleted,
        settings.onboardingVersion,
        settings.guidedTourCompletedVersion,
        settings.guidedTourSkippedVersion,
        settings.guidedTourLastStepId,
        settings.updatedAt,
      ];
}

class SettingsSaving extends SettingsSuccess {
  const SettingsSaving(super.settings);
}

class SettingsFailure extends SettingsState {
  final String message;

  const SettingsFailure(this.message);

  @override
  List<Object?> get props => [message];
}
