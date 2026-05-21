import 'package:expense_repository/expense_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('defaults missing settings fields for Firestore documents', () {
    final entity = UserSettingsEntity.fromDocument(const {});

    expect(entity.userId, '');
    expect(entity.appDisplayName, isNull);
    expect(entity.languagePreference, 'system');
    expect(entity.baseCurrency, 'EGP');
    expect(entity.supportedCurrencies, ['EGP', 'USD', 'EUR', 'SAR', 'AED']);
    expect(entity.conversionRates, isEmpty);
    expect(entity.defaultPaymentMethod, 'cash');
    expect(entity.onboardingCompleted, isFalse);
    expect(entity.onboardingVersion, 0);
  });

  test('round-trips complete user settings through entity document data', () {
    final settings = UserSettings(
      userId: 'user-1',
      appDisplayName: ' Local Name ',
      languagePreference: LanguagePreference.arabic,
      baseCurrency: 'USD',
      supportedCurrencies: const ['USD', 'EGP'],
      conversionRates: const {'EGP': 0.02},
      defaultPaymentMethod: PaymentMethod.visa,
      onboardingCompleted: true,
      onboardingVersion: UserSettings.currentOnboardingVersion,
      guidedTourCompletedVersion: 1,
      guidedTourSkippedVersion: 0,
      guidedTourLastStepId: 'ai_assistant',
      exchangeRatesUpdatedAt: DateTime(2026, 5, 19, 8),
      updatedAt: DateTime(2026, 5, 15),
    );

    final document = settings.toEntity().toDocument();
    final entity = UserSettingsEntity.fromDocument(document);
    final roundTripped = UserSettings.fromEntity(entity);

    expect(roundTripped.userId, 'user-1');
    expect(roundTripped.appDisplayName, 'Local Name');
    expect(roundTripped.languagePreference, LanguagePreference.arabic);
    expect(roundTripped.baseCurrency, 'USD');
    expect(roundTripped.supportedCurrencies, ['USD', 'EGP']);
    expect(roundTripped.conversionRates, {'EGP': 0.02});
    expect(roundTripped.defaultPaymentMethod, PaymentMethod.visa);
    expect(roundTripped.onboardingCompleted, isTrue);
    expect(
        roundTripped.onboardingVersion, UserSettings.currentOnboardingVersion);
    expect(roundTripped.guidedTourCompletedVersion, 1);
    expect(roundTripped.guidedTourSkippedVersion, 0);
    expect(roundTripped.guidedTourLastStepId, 'ai_assistant');
    expect(roundTripped.exchangeRatesUpdatedAt, DateTime(2026, 5, 19, 8));
    expect(roundTripped.updatedAt, DateTime(2026, 5, 15));
  });

  test('stores app-local display name independently from auth profile', () {
    final settings = UserSettings.defaults(userId: 'user-1').copyWith(
      appDisplayName: '  App Local Name  ',
    );

    final document = settings.toEntity().toDocument();
    final roundTripped = UserSettings.fromEntity(
      UserSettingsEntity.fromDocument(document),
    );

    expect(document['appDisplayName'], 'App Local Name');
    expect(roundTripped.appDisplayName, 'App Local Name');
    expect(
      roundTripped.copyWith(clearAppDisplayName: true).appDisplayName,
      isNull,
    );
  });

  test('defaults missing exchange rate refresh timestamp to null', () {
    final settings = UserSettings.fromEntity(
      UserSettingsEntity.fromDocument(const {
        'userId': 'user-1',
        'baseCurrency': 'EGP',
        'supportedCurrencies': ['EGP', 'USD'],
        'conversionRates': {'USD': 50},
        'defaultPaymentMethod': 'cash',
      }),
    );

    expect(settings.exchangeRatesUpdatedAt, isNull);
    expect(settings.conversionRates, {'USD': 50});
  });

  test('defaults and sanitizes guided tour persistence fields', () {
    final legacy = UserSettings.fromEntity(
      UserSettingsEntity.fromDocument(const {
        'guidedTourCompletedVersion': -3,
        'guidedTourSkippedVersion': '2',
        'guidedTourLastStepId': '  ',
      }),
    );

    expect(legacy.guidedTourCompletedVersion, 0);
    expect(legacy.guidedTourSkippedVersion, 2);
    expect(legacy.guidedTourLastStepId, isNull);
    expect(legacy.shouldShowGuidedTourVersion(1), isFalse);

    final ready = legacy.copyWith(
      onboardingCompleted: true,
      onboardingVersion: UserSettings.currentOnboardingVersion,
    );

    expect(ready.shouldShowGuidedTourVersion(3), isTrue);
  });

  test('treats legacy valid explicit preferences as onboarding complete', () {
    final entity = UserSettingsEntity.fromDocument(const {
      'languagePreference': 'ar',
      'baseCurrency': 'usd',
      'supportedCurrencies': ['usd'],
      'defaultPaymentMethod': 'wallet',
    });
    final settings = UserSettings.fromEntity(entity);

    expect(settings.onboardingCompleted, isTrue);
    expect(settings.onboardingVersion, UserSettings.currentOnboardingVersion);
    expect(settings.requiresOnboarding, isFalse);
  });

  test('keeps explicit incomplete onboarding state for new default profiles',
      () {
    final entity = UserSettingsEntity.fromDocument(const {
      'languagePreference': 'system',
      'baseCurrency': 'EGP',
      'supportedCurrencies': ['EGP', 'USD'],
      'defaultPaymentMethod': 'cash',
      'onboardingCompleted': false,
      'onboardingVersion': 0,
    });
    final settings = UserSettings.fromEntity(entity);

    expect(settings.onboardingCompleted, isFalse);
    expect(settings.onboardingVersion, 0);
    expect(settings.requiresOnboarding, isTrue);
  });

  test('defaults unknown language preference to system', () {
    final entity = UserSettingsEntity.fromDocument(const {
      'languagePreference': 'fr',
      'baseCurrency': 'usd',
      'supportedCurrencies': ['usd'],
      'defaultPaymentMethod': 'visa',
    });
    final settings = UserSettings.fromEntity(entity);

    expect(settings.languagePreference, LanguagePreference.system);
    expect(settings.baseCurrency, 'USD');
    expect(settings.supportedCurrencies, ['USD']);
    expect(settings.defaultPaymentMethod, PaymentMethod.visa);
    expect(settings.requiresOnboarding, isFalse);
  });

  test('normalizes conversion rates and drops invalid entries', () {
    final settings = UserSettings.fromEntity(
      UserSettingsEntity.fromDocument(const {
        'baseCurrency': 'usd',
        'supportedCurrencies': ['usd', 'egp', 'eur'],
        'conversionRates': {
          'egp': 0.02,
          'EUR': 1.1,
          'USD': 1,
          'GBP': 1.3,
          'SAR': 0,
          'AED': -1,
          'bad': '2',
        },
        'defaultPaymentMethod': 'cash',
      }),
    );

    expect(settings.baseCurrency, 'USD');
    expect(settings.supportedCurrencies, ['USD', 'EGP', 'EUR']);
    expect(settings.conversionRates, {'EGP': 0.02, 'EUR': 1.1});
  });

  test('copyWith keeps rates unless explicitly replaced', () {
    final settings = UserSettings.defaults(userId: 'user-1').copyWith(
      baseCurrency: 'USD',
      supportedCurrencies: const ['USD', 'EGP'],
      conversionRates: const {'EGP': 0.02},
    );

    expect(
      settings
          .copyWith(languagePreference: LanguagePreference.english)
          .conversionRates,
      {'EGP': 0.02},
    );
    expect(
      settings.copyWith(conversionRates: const {'EGP': 0.03}).conversionRates,
      {'EGP': 0.03},
    );
    expect(
      settings
          .copyWith(exchangeRatesUpdatedAt: DateTime(2026, 5, 19))
          .exchangeRatesUpdatedAt,
      DateTime(2026, 5, 19),
    );
    expect(
      settings
          .copyWith(
            exchangeRatesUpdatedAt: DateTime(2026, 5, 19),
          )
          .copyWith(clearExchangeRatesUpdatedAt: true)
          .exchangeRatesUpdatedAt,
      isNull,
    );
  });

  test('builds user-scoped settings path', () {
    expect(
      FirebaseSettingsRepository.settingsPathFor('user-a'),
      'users/user-a/settings',
    );
  });
}
