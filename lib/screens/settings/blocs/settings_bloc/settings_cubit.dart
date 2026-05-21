import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _settingsRepository;

  SettingsCubit(this._settingsRepository) : super(SettingsInitial());

  Future<void> loadSettings() async {
    emit(SettingsLoading());
    try {
      final settings = await _settingsRepository.getSettings();
      emit(SettingsSuccess(settings));
    } catch (_) {
      emit(const SettingsFailure('Failed to load settings.'));
    }
  }

  Future<void> saveBaseCurrency(String currencyCode) async {
    final current = state;
    if (current is! SettingsSuccess) return;
    final normalizedCurrency = currencyCode.trim().toUpperCase();

    final updated = current.settings.copyWith(
      baseCurrency: normalizedCurrency,
      supportedCurrencies: _withRequiredCurrency(
        current.settings.supportedCurrencies,
        normalizedCurrency,
      ),
      conversionRates: const {},
      clearExchangeRatesUpdatedAt: true,
      updatedAt: DateTime.now(),
    );
    emit(SettingsSaving(updated));
    try {
      await _settingsRepository.saveSettings(updated);
      emit(SettingsSuccess(updated));
    } catch (_) {
      emit(const SettingsFailure('Failed to save base currency.'));
      emit(current);
    }
  }

  Future<void> saveLanguagePreference(
    LanguagePreference languagePreference,
  ) async {
    final current = state;
    if (current is! SettingsSuccess) return;

    final updated = current.settings.copyWith(
      languagePreference: languagePreference,
      updatedAt: DateTime.now(),
    );
    emit(SettingsSaving(updated));
    try {
      await _settingsRepository.saveSettings(updated);
      emit(SettingsSuccess(updated));
    } catch (_) {
      emit(const SettingsFailure('Failed to save language preference.'));
      emit(current);
    }
  }

  Future<void> saveSupportedCurrencies(List<String> currencyCodes) async {
    final current = state;
    if (current is! SettingsSuccess) return;

    final normalized = _withRequiredCurrency(
      currencyCodes,
      current.settings.baseCurrency,
    );
    if (currencyCodes
        .map((currency) => currency.trim())
        .where((currency) => currency.isNotEmpty)
        .isEmpty) {
      emit(const SettingsFailure('Select at least one currency.'));
      emit(current);
      return;
    }

    final updated = current.settings.copyWith(
      supportedCurrencies: normalized,
      conversionRates: _filterRatesToSupported(
        current.settings.conversionRates,
        current.settings.baseCurrency,
        normalized,
      ),
      updatedAt: DateTime.now(),
    );
    emit(SettingsSaving(updated));
    try {
      await _settingsRepository.saveSettings(updated);
      emit(SettingsSuccess(updated));
    } catch (_) {
      emit(const SettingsFailure('Failed to save supported currencies.'));
      emit(current);
    }
  }

  Future<void> saveDefaultPaymentMethod(PaymentMethod paymentMethod) async {
    final current = state;
    if (current is! SettingsSuccess) return;

    final updated = current.settings.copyWith(
      defaultPaymentMethod: paymentMethod,
      updatedAt: DateTime.now(),
    );
    emit(SettingsSaving(updated));
    try {
      await _settingsRepository.saveSettings(updated);
      emit(SettingsSuccess(updated));
    } catch (_) {
      emit(const SettingsFailure('Failed to save payment method.'));
      emit(current);
    }
  }

  Future<void> saveConversionRate(String currencyCode, String input) async {
    final current = state;
    if (current is! SettingsSuccess) return;

    final normalizedCurrency = currencyCode.trim().toUpperCase();
    if (normalizedCurrency == current.settings.baseCurrency ||
        !current.settings.supportedCurrencies.contains(normalizedCurrency)) {
      emit(const SettingsFailure('Select a supported non-base currency.'));
      emit(current);
      return;
    }

    final normalizedInput = input.trim().replaceAll(',', '.');
    final rate = double.tryParse(normalizedInput);
    if (rate == null || rate <= 0) {
      emit(const SettingsFailure('Enter a rate greater than zero.'));
      emit(current);
      return;
    }

    final rates = Map<String, num>.from(current.settings.conversionRates);
    rates[normalizedCurrency] = rate;
    final updated = current.settings.copyWith(
      conversionRates: rates,
      updatedAt: DateTime.now(),
    );
    emit(SettingsSaving(updated));
    try {
      await _settingsRepository.saveSettings(updated);
      emit(SettingsSuccess(updated));
    } catch (_) {
      emit(const SettingsFailure('Failed to save exchange rate.'));
      emit(current);
    }
  }

  Future<void> saveNotificationSettings(
    NotificationSettings notificationSettings,
  ) async {
    final current = state;
    if (current is! SettingsSuccess) return;

    final updated = current.settings.copyWith(
      notificationSettings: notificationSettings,
      updatedAt: DateTime.now(),
    );
    emit(SettingsSaving(updated));
    try {
      await _settingsRepository.saveSettings(updated);
      emit(SettingsSuccess(updated));
    } catch (_) {
      emit(const SettingsFailure('Failed to save notification settings.'));
      emit(current);
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

  Map<String, num> _filterRatesToSupported(
    Map<String, num> conversionRates,
    String baseCurrency,
    List<String> supportedCurrencies,
  ) {
    final normalizedBase = baseCurrency.trim().toUpperCase();
    final supported = supportedCurrencies
        .map((currency) => currency.trim().toUpperCase())
        .toSet();
    return Map<String, num>.from(conversionRates)
      ..removeWhere(
        (currency, rate) =>
            currency.trim().toUpperCase() == normalizedBase ||
            !supported.contains(currency.trim().toUpperCase()) ||
            rate <= 0,
      );
  }
}
