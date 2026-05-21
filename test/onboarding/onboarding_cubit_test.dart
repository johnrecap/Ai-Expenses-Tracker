import 'dart:async';

import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/onboarding/onboarding.dart';
import 'package:expenses_tracker/services/notifications/notifications.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('validates required essentials before continuing', () async {
    final repository = _FakeSettingsRepository(_settings());
    final cubit = OnboardingCubit(settingsRepository: repository);

    await cubit.load();
    cubit.continueFromEssentials();

    expect(cubit.state.failure, OnboardingFailure.requiredChoicesMissing);
    expect(cubit.state.step, OnboardingStep.essentials);

    await cubit.close();
  });

  test('saves selected essentials and completion metadata', () async {
    final repository = _FakeSettingsRepository(_settings());
    final cubit = OnboardingCubit(settingsRepository: repository);

    await cubit.load();
    cubit.selectLanguage(LanguagePreference.arabic);
    cubit.selectBaseCurrency('usd');
    cubit.selectPaymentMethod(PaymentMethod.wallet);
    cubit.continueFromEssentials();
    cubit.continueFromAiIntro();
    await cubit.skipReminders();

    expect(cubit.state.step, OnboardingStep.complete);
    expect(repository.settings.languagePreference, LanguagePreference.arabic);
    expect(repository.settings.baseCurrency, 'USD');
    expect(repository.settings.supportedCurrencies, contains('USD'));
    expect(repository.settings.defaultPaymentMethod, PaymentMethod.wallet);
    expect(repository.settings.onboardingCompleted, isTrue);
    expect(
      repository.settings.onboardingVersion,
      UserSettings.currentOnboardingVersion,
    );

    await cubit.close();
  });

  test('save failure keeps selections available for retry', () async {
    final repository = _FakeSettingsRepository(_settings());
    final cubit = OnboardingCubit(settingsRepository: repository);

    await cubit.load();
    cubit.selectLanguage(LanguagePreference.english);
    cubit.selectBaseCurrency('eur');
    cubit.selectPaymentMethod(PaymentMethod.visa);
    cubit.continueFromEssentials();
    cubit.continueFromAiIntro();
    repository.failOnSave = true;
    await cubit.finish();

    expect(cubit.state.failure, OnboardingFailure.saveFailed);
    expect(cubit.state.step, OnboardingStep.reminders);
    expect(cubit.state.selectedLanguagePreference, LanguagePreference.english);
    expect(cubit.state.selectedBaseCurrency, 'EUR');
    expect(cubit.state.selectedPaymentMethod, PaymentMethod.visa);
    expect(repository.settings.onboardingCompleted, isFalse);

    await cubit.close();
  });

  test('declined reminders complete setup without scheduling', () async {
    final repository = _FakeSettingsRepository(_settings());
    final scheduler = _FakeNotificationScheduler();
    final cubit = OnboardingCubit(
      settingsRepository: repository,
      notificationScheduler: scheduler,
      loadExpenses: () async => const [],
    );

    await cubit.load();
    cubit.selectLanguage(LanguagePreference.english);
    cubit.selectBaseCurrency('egp');
    cubit.selectPaymentMethod(PaymentMethod.cash);
    cubit.continueFromEssentials();
    cubit.continueFromAiIntro();
    await cubit.finish();

    expect(repository.settings.onboardingCompleted, isTrue);
    expect(
        repository.settings.notificationSettings.dailyReminderEnabled, isFalse);
    expect(
        repository.settings.notificationSettings.weeklyDigestEnabled, isFalse);
    expect(scheduler.syncCalls, 0);

    await cubit.close();
  });

  test('permission denial disables reminder choices without blocking setup',
      () async {
    final repository = _FakeSettingsRepository(_settings());
    final scheduler = _FakeNotificationScheduler(syncResult: false);
    final cubit = OnboardingCubit(
      settingsRepository: repository,
      notificationScheduler: scheduler,
      loadExpenses: () async => const [],
    );

    await cubit.load();
    cubit.selectLanguage(LanguagePreference.english);
    cubit.selectBaseCurrency('sar');
    cubit.selectPaymentMethod(PaymentMethod.bankTransfer);
    cubit.continueFromEssentials();
    cubit.continueFromAiIntro();
    cubit.setDailyReminderEnabled(true);
    cubit.setWeeklyDigestEnabled(true);
    await cubit.finish();

    expect(cubit.state.step, OnboardingStep.complete);
    expect(cubit.state.warning, OnboardingWarning.remindersDisabled);
    expect(repository.settings.onboardingCompleted, isTrue);
    expect(
        repository.settings.notificationSettings.dailyReminderEnabled, isFalse);
    expect(
        repository.settings.notificationSettings.weeklyDigestEnabled, isFalse);
    expect(scheduler.syncCalls, 1);

    await cubit.close();
  });

  test('reminder scheduling timeout disables reminders without blocking setup',
      () async {
    final repository = _FakeSettingsRepository(_settings());
    final scheduler = _FakeNotificationScheduler(neverCompletes: true);
    final cubit = OnboardingCubit(
      settingsRepository: repository,
      notificationScheduler: scheduler,
      loadExpenses: () async => const [],
      reminderSyncTimeout: const Duration(milliseconds: 10),
    );

    await cubit.load();
    cubit.selectLanguage(LanguagePreference.english);
    cubit.selectBaseCurrency('usd');
    cubit.selectPaymentMethod(PaymentMethod.cash);
    cubit.continueFromEssentials();
    cubit.continueFromAiIntro();
    cubit.setDailyReminderEnabled(true);
    await cubit.finish();

    expect(cubit.state.step, OnboardingStep.complete);
    expect(cubit.state.isSaving, isFalse);
    expect(cubit.state.warning, OnboardingWarning.remindersDisabled);
    expect(repository.settings.onboardingCompleted, isTrue);
    expect(
        repository.settings.notificationSettings.dailyReminderEnabled, isFalse);
    expect(scheduler.syncCalls, 1);

    await cubit.close();
  });

  test('AI intro navigation does not require an AI provider or gateway',
      () async {
    final repository = _FakeSettingsRepository(_settings());
    final cubit = OnboardingCubit(settingsRepository: repository);

    await cubit.load();
    cubit.selectLanguage(LanguagePreference.english);
    cubit.selectBaseCurrency('usd');
    cubit.selectPaymentMethod(PaymentMethod.wallet);
    cubit.continueFromEssentials();
    cubit.continueFromAiIntro();

    expect(cubit.state.step, OnboardingStep.reminders);
    expect(repository.settings.onboardingCompleted, isFalse);

    await cubit.close();
  });
}

UserSettings _settings() {
  return UserSettings.defaults(
    userId: 'user-1',
    updatedAt: DateTime(2026, 5, 18),
  );
}

class _FakeSettingsRepository implements SettingsRepository {
  _FakeSettingsRepository(this.settings);

  UserSettings settings;
  bool failOnSave = false;

  @override
  Future<UserSettings> ensureDefaultSettings() async => settings;

  @override
  Future<UserSettings> getSettings() async => settings;

  @override
  Future<void> saveSettings(UserSettings settings) async {
    if (failOnSave) throw Exception('save failed');
    this.settings = settings;
  }

  @override
  Future<void> updateBaseCurrency(String currencyCode) async {
    settings = settings.copyWith(baseCurrency: currencyCode);
  }

  @override
  Future<void> updateConversionRates(Map<String, num> conversionRates) async {
    settings = settings.copyWith(conversionRates: conversionRates);
  }

  @override
  Future<void> updateExchangeRates({
    required Map<String, num> conversionRates,
    required DateTime exchangeRatesUpdatedAt,
  }) async {
    settings = settings.copyWith(
      conversionRates: conversionRates,
      exchangeRatesUpdatedAt: exchangeRatesUpdatedAt,
    );
  }

  @override
  Future<void> updateDefaultPaymentMethod(PaymentMethod paymentMethod) async {
    settings = settings.copyWith(defaultPaymentMethod: paymentMethod);
  }

  @override
  Future<void> updateAppDisplayName(String? displayName) async {
    settings = settings.copyWith(
      appDisplayName: displayName,
      clearAppDisplayName: displayName == null || displayName.trim().isEmpty,
    );
  }

  @override
  Future<void> updateLanguagePreference(
    LanguagePreference languagePreference,
  ) async {
    settings = settings.copyWith(languagePreference: languagePreference);
  }

  @override
  Stream<UserSettings> watchSettings() => Stream.value(settings);
}

class _FakeNotificationScheduler extends NotificationScheduler {
  _FakeNotificationScheduler({
    this.syncResult = true,
    this.neverCompletes = false,
  }) : super(notificationService: _NoopNotificationService());

  final bool syncResult;
  final bool neverCompletes;
  int syncCalls = 0;

  @override
  Future<bool> syncOptionalReminders({
    required UserSettings settings,
    required List<Expense> expenses,
    DateTime? now,
  }) async {
    syncCalls += 1;
    if (neverCompletes) return Completer<bool>().future;
    return syncResult;
  }
}

class _NoopNotificationService implements AppNotificationService {
  @override
  Future<void> cancel(int id) async {}

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermissions() async => true;

  @override
  Future<bool> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    return true;
  }

  @override
  Future<bool> scheduleWeekly({
    required int id,
    required String title,
    required String body,
    required int weekday,
    required int hour,
    required int minute,
  }) async {
    return true;
  }

  @override
  Future<bool> showImmediate({
    required int id,
    required String title,
    required String body,
    required AppNotificationChannel channel,
  }) async {
    return true;
  }
}
