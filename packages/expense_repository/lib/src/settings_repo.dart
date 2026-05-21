import 'package:expense_repository/expense_repository.dart';

abstract class SettingsRepository {
  Future<UserSettings> getSettings();

  Stream<UserSettings> watchSettings();

  Future<void> saveSettings(UserSettings settings);

  Future<void> updateBaseCurrency(String currencyCode);

  Future<void> updateConversionRates(Map<String, num> conversionRates);

  Future<void> updateExchangeRates({
    required Map<String, num> conversionRates,
    required DateTime exchangeRatesUpdatedAt,
  });

  Future<void> updateLanguagePreference(LanguagePreference languagePreference);

  Future<void> updateDefaultPaymentMethod(PaymentMethod paymentMethod);

  Future<void> updateAppDisplayName(String? displayName) async {
    final current = await getSettings();
    await saveSettings(
      current.copyWith(
        appDisplayName: displayName,
        clearAppDisplayName: displayName == null || displayName.trim().isEmpty,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<UserSettings> ensureDefaultSettings();
}
