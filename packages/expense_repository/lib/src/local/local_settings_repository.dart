import 'package:expense_repository/expense_repository.dart';

class LocalSettingsRepository implements SettingsRepository {
  final LocalRepositoryStore store;

  const LocalSettingsRepository({
    required this.store,
  });

  @override
  Future<UserSettings> ensureDefaultSettings() async {
    store.emitSettings();
    return store.settings;
  }

  @override
  Future<UserSettings> getSettings() async => store.settings;

  @override
  Future<void> saveSettings(UserSettings settings) async {
    store.settings = settings.copyWith(
      userId: store.userId,
      updatedAt: DateTime.now(),
    );
    store.enqueue(_change(store.settings));
    store.emitSettings();
  }

  @override
  Future<void> updateBaseCurrency(String currencyCode) async {
    await saveSettings(
      store.settings.copyWith(
        baseCurrency: currencyCode,
        conversionRates: const {},
        clearExchangeRatesUpdatedAt: true,
      ),
    );
  }

  @override
  Future<void> updateAppDisplayName(String? displayName) async {
    await saveSettings(
      store.settings.copyWith(
        appDisplayName: displayName,
        clearAppDisplayName: displayName == null || displayName.trim().isEmpty,
      ),
    );
  }

  @override
  Future<void> updateConversionRates(Map<String, num> conversionRates) async {
    await saveSettings(
        store.settings.copyWith(conversionRates: conversionRates));
  }

  @override
  Future<void> updateDefaultPaymentMethod(PaymentMethod paymentMethod) async {
    await saveSettings(
      store.settings.copyWith(defaultPaymentMethod: paymentMethod),
    );
  }

  @override
  Future<void> updateExchangeRates({
    required Map<String, num> conversionRates,
    required DateTime exchangeRatesUpdatedAt,
  }) async {
    await saveSettings(
      store.settings.copyWith(
        conversionRates: conversionRates,
        exchangeRatesUpdatedAt: exchangeRatesUpdatedAt,
      ),
    );
  }

  @override
  Future<void> updateLanguagePreference(
    LanguagePreference languagePreference,
  ) async {
    await saveSettings(
      store.settings.copyWith(languagePreference: languagePreference),
    );
  }

  @override
  Stream<UserSettings> watchSettings() => store.watchSettings();

  SyncChange _change(UserSettings settings) {
    return SyncChange(
      id: 'settings-${DateTime.now().microsecondsSinceEpoch}',
      userId: store.userId,
      entityType: SyncEntityType.settings,
      entityId: store.userId,
      operation: SyncOperation.upsert,
      data: {
        'userId': settings.userId,
        'baseCurrency': settings.baseCurrency,
        'supportedCurrencies': settings.supportedCurrencies,
        'languagePreference': settings.languagePreference.storageValue,
      },
      clientUpdatedAt: DateTime.now(),
    );
  }
}
