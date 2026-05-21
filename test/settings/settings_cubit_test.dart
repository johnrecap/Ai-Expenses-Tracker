import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/settings/blocs/settings_bloc/settings_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository(this.settings);

  UserSettings settings;
  bool fail = false;

  @override
  Future<UserSettings> ensureDefaultSettings() async {
    if (fail) throw Exception('failed');
    return settings;
  }

  @override
  Future<UserSettings> getSettings() async {
    if (fail) throw Exception('failed');
    return settings;
  }

  @override
  Future<void> saveSettings(UserSettings settings) async {
    if (fail) throw Exception('failed');
    this.settings = settings;
  }

  @override
  Future<void> updateBaseCurrency(String currencyCode) async {
    if (fail) throw Exception('failed');
    settings = settings.copyWith(baseCurrency: currencyCode);
  }

  @override
  Future<void> updateConversionRates(Map<String, num> conversionRates) async {
    if (fail) throw Exception('failed');
    settings = settings.copyWith(conversionRates: conversionRates);
  }

  @override
  Future<void> updateExchangeRates({
    required Map<String, num> conversionRates,
    required DateTime exchangeRatesUpdatedAt,
  }) async {
    if (fail) throw Exception('failed');
    settings = settings.copyWith(
      conversionRates: conversionRates,
      exchangeRatesUpdatedAt: exchangeRatesUpdatedAt,
    );
  }

  @override
  Future<void> updateLanguagePreference(
    LanguagePreference languagePreference,
  ) async {
    if (fail) throw Exception('failed');
    settings = settings.copyWith(languagePreference: languagePreference);
  }

  @override
  Future<void> updateDefaultPaymentMethod(PaymentMethod paymentMethod) async {
    if (fail) throw Exception('failed');
    settings = settings.copyWith(defaultPaymentMethod: paymentMethod);
  }

  @override
  Future<void> updateAppDisplayName(String? displayName) async {
    if (fail) throw Exception('failed');
    settings = settings.copyWith(
      appDisplayName: displayName,
      clearAppDisplayName: displayName == null || displayName.trim().isEmpty,
    );
  }

  @override
  Stream<UserSettings> watchSettings() {
    if (fail) return Stream<UserSettings>.error(Exception('failed'));
    return Stream.value(settings);
  }
}

UserSettings _settings() {
  return UserSettings.defaults(
    userId: 'user-1',
    updatedAt: DateTime(2026, 5, 17),
  );
}

void main() {
  test('loads settings successfully', () async {
    final cubit = SettingsCubit(FakeSettingsRepository(_settings()));

    await cubit.loadSettings();

    expect(cubit.state, isA<SettingsSuccess>());
    await cubit.close();
  });

  test('saves base currency and keeps it supported', () async {
    final repository = FakeSettingsRepository(_settings());
    final cubit = SettingsCubit(repository);

    await cubit.loadSettings();
    await cubit.saveBaseCurrency('usd');

    final state = cubit.state as SettingsSuccess;
    expect(state.settings.baseCurrency, 'USD');
    expect(state.settings.supportedCurrencies, contains('USD'));
    await cubit.close();
  });

  test('saves language preference without changing currency settings',
      () async {
    final repository = FakeSettingsRepository(
      _settings().copyWith(
        baseCurrency: 'USD',
        supportedCurrencies: const ['USD', 'EGP'],
        conversionRates: const {'EGP': 0.02},
        defaultPaymentMethod: PaymentMethod.wallet,
      ),
    );
    final cubit = SettingsCubit(repository);

    await cubit.loadSettings();
    await cubit.saveLanguagePreference(LanguagePreference.arabic);

    final state = cubit.state as SettingsSuccess;
    expect(state.settings.languagePreference, LanguagePreference.arabic);
    expect(state.settings.baseCurrency, 'USD');
    expect(state.settings.supportedCurrencies, ['USD', 'EGP']);
    expect(state.settings.conversionRates, {'EGP': 0.02});
    expect(state.settings.defaultPaymentMethod, PaymentMethod.wallet);
    await cubit.close();
  });

  test('supported currencies update keeps base currency included', () async {
    final repository = FakeSettingsRepository(_settings());
    final cubit = SettingsCubit(repository);

    await cubit.loadSettings();
    await cubit.saveSupportedCurrencies(const ['usd']);

    final state = cubit.state as SettingsSuccess;
    expect(state.settings.supportedCurrencies, contains('EGP'));
    expect(state.settings.supportedCurrencies, contains('USD'));
    await cubit.close();
  });

  test('saves conversion rate without changing language or base currency',
      () async {
    final repository = FakeSettingsRepository(
      _settings().copyWith(
        languagePreference: LanguagePreference.english,
        baseCurrency: 'USD',
        supportedCurrencies: const ['USD', 'EGP'],
      ),
    );
    final cubit = SettingsCubit(repository);

    await cubit.loadSettings();
    await cubit.saveConversionRate('egp', '0.02');

    final state = cubit.state as SettingsSuccess;
    expect(state.settings.languagePreference, LanguagePreference.english);
    expect(state.settings.baseCurrency, 'USD');
    expect(state.settings.supportedCurrencies, ['USD', 'EGP']);
    expect(state.settings.conversionRates, {'EGP': 0.02});
    await cubit.close();
  });

  test('rejects invalid conversion rate and restores previous state', () async {
    final repository = FakeSettingsRepository(
      _settings().copyWith(
        baseCurrency: 'USD',
        supportedCurrencies: const ['USD', 'EGP'],
        conversionRates: const {'EGP': 0.02},
      ),
    );
    final cubit = SettingsCubit(repository);

    await cubit.loadSettings();
    final previous = cubit.state as SettingsSuccess;
    await cubit.saveConversionRate('EGP', '0');

    expect(cubit.state, previous);
    expect(repository.settings.conversionRates, {'EGP': 0.02});
    await cubit.close();
  });

  test('rejects empty supported currency updates', () async {
    final repository = FakeSettingsRepository(_settings());
    final cubit = SettingsCubit(repository);

    await cubit.loadSettings();
    final previous = cubit.state as SettingsSuccess;
    await cubit.saveSupportedCurrencies(const []);

    expect(cubit.state, previous);
    expect(repository.settings.supportedCurrencies, contains('EGP'));
    await cubit.close();
  });

  test('saves default payment method successfully', () async {
    final repository = FakeSettingsRepository(_settings());
    final cubit = SettingsCubit(repository);

    await cubit.loadSettings();
    await cubit.saveDefaultPaymentMethod(PaymentMethod.wallet);

    final state = cubit.state as SettingsSuccess;
    expect(state.settings.defaultPaymentMethod, PaymentMethod.wallet);
    await cubit.close();
  });

  test('saves base currency without changing language preference', () async {
    final repository = FakeSettingsRepository(
      _settings().copyWith(languagePreference: LanguagePreference.english),
    );
    final cubit = SettingsCubit(repository);

    await cubit.loadSettings();
    await cubit.saveBaseCurrency('egp');

    final state = cubit.state as SettingsSuccess;
    expect(state.settings.languagePreference, LanguagePreference.english);
    expect(state.settings.baseCurrency, 'EGP');
    await cubit.close();
  });

  test('save failure restores previous success state', () async {
    final repository = FakeSettingsRepository(_settings());
    final cubit = SettingsCubit(repository);

    await cubit.loadSettings();
    final previous = cubit.state as SettingsSuccess;
    repository.fail = true;
    await cubit.saveDefaultPaymentMethod(PaymentMethod.wallet);

    expect(cubit.state, previous);
    expect(repository.settings.defaultPaymentMethod, PaymentMethod.cash);
    await cubit.close();
  });
}
