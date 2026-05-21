import 'package:expense_repository/src/entities/entities.dart';
import 'package:expense_repository/src/models/language_preference.dart';
import 'package:expense_repository/src/models/notification_settings.dart';
import 'package:expense_repository/src/models/payment_method.dart';

class UserSettings {
  static const currentOnboardingVersion = 1;
  static const defaultBaseCurrency = 'EGP';
  static const defaultSupportedCurrencies = ['EGP', 'USD', 'EUR', 'SAR', 'AED'];
  static const defaultPaymentMethodValue = PaymentMethod.cash;
  static const defaultLanguagePreference = LanguagePreference.system;

  final String userId;
  final String? appDisplayName;
  final LanguagePreference languagePreference;
  final String baseCurrency;
  final List<String> supportedCurrencies;
  final Map<String, double> conversionRates;
  final PaymentMethod defaultPaymentMethod;
  final NotificationSettings notificationSettings;
  final bool onboardingCompleted;
  final int onboardingVersion;
  final int guidedTourCompletedVersion;
  final int guidedTourSkippedVersion;
  final String? guidedTourLastStepId;
  final DateTime? exchangeRatesUpdatedAt;
  final DateTime updatedAt;

  UserSettings({
    required this.userId,
    String? appDisplayName,
    this.languagePreference = defaultLanguagePreference,
    required String baseCurrency,
    required List<String> supportedCurrencies,
    Map<String, num>? conversionRates,
    required this.defaultPaymentMethod,
    NotificationSettings? notificationSettings,
    this.onboardingCompleted = false,
    this.onboardingVersion = 0,
    this.guidedTourCompletedVersion = 0,
    this.guidedTourSkippedVersion = 0,
    this.guidedTourLastStepId,
    this.exchangeRatesUpdatedAt,
    required this.updatedAt,
  })  : appDisplayName = _normalizeDisplayName(appDisplayName),
        baseCurrency = _normalizeCurrency(baseCurrency, defaultBaseCurrency),
        supportedCurrencies = _normalizeSupportedCurrencies(
          supportedCurrencies,
          baseCurrency,
        ),
        conversionRates = _normalizeConversionRates(
          conversionRates,
          baseCurrency,
          supportedCurrencies,
        ),
        notificationSettings =
            notificationSettings ?? const NotificationSettings.defaults();

  factory UserSettings.defaults({
    required String userId,
    bool onboardingCompleted = false,
    int onboardingVersion = 0,
    DateTime? updatedAt,
  }) {
    return UserSettings(
      userId: userId,
      appDisplayName: null,
      languagePreference: defaultLanguagePreference,
      baseCurrency: defaultBaseCurrency,
      supportedCurrencies: defaultSupportedCurrencies,
      conversionRates: const {},
      defaultPaymentMethod: defaultPaymentMethodValue,
      notificationSettings: const NotificationSettings.defaults(),
      onboardingCompleted: onboardingCompleted,
      onboardingVersion: onboardingVersion,
      guidedTourCompletedVersion: 0,
      guidedTourSkippedVersion: 0,
      exchangeRatesUpdatedAt: null,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  bool get hasRequiredOnboardingChoices {
    final normalizedCurrency = _normalizeCurrency(
      baseCurrency,
      defaultBaseCurrency,
    );
    return normalizedCurrency.isNotEmpty &&
        supportedCurrencies
            .map((currency) => currency.trim().toUpperCase())
            .contains(normalizedCurrency);
  }

  bool get requiresOnboarding {
    return !onboardingCompleted ||
        onboardingVersion < currentOnboardingVersion ||
        !hasRequiredOnboardingChoices;
  }

  UserSettings copyWith({
    String? userId,
    String? appDisplayName,
    bool clearAppDisplayName = false,
    LanguagePreference? languagePreference,
    String? baseCurrency,
    List<String>? supportedCurrencies,
    Map<String, num>? conversionRates,
    PaymentMethod? defaultPaymentMethod,
    NotificationSettings? notificationSettings,
    bool? onboardingCompleted,
    int? onboardingVersion,
    int? guidedTourCompletedVersion,
    int? guidedTourSkippedVersion,
    String? guidedTourLastStepId,
    bool clearGuidedTourLastStepId = false,
    DateTime? exchangeRatesUpdatedAt,
    bool clearExchangeRatesUpdatedAt = false,
    DateTime? updatedAt,
  }) {
    return UserSettings(
      userId: userId ?? this.userId,
      appDisplayName:
          clearAppDisplayName ? null : appDisplayName ?? this.appDisplayName,
      languagePreference: languagePreference ?? this.languagePreference,
      baseCurrency: baseCurrency ?? this.baseCurrency,
      supportedCurrencies: supportedCurrencies ?? this.supportedCurrencies,
      conversionRates: conversionRates ?? this.conversionRates,
      defaultPaymentMethod: defaultPaymentMethod ?? this.defaultPaymentMethod,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      onboardingVersion: onboardingVersion ?? this.onboardingVersion,
      guidedTourCompletedVersion:
          guidedTourCompletedVersion ?? this.guidedTourCompletedVersion,
      guidedTourSkippedVersion:
          guidedTourSkippedVersion ?? this.guidedTourSkippedVersion,
      guidedTourLastStepId: clearGuidedTourLastStepId
          ? null
          : guidedTourLastStepId ?? this.guidedTourLastStepId,
      exchangeRatesUpdatedAt: clearExchangeRatesUpdatedAt
          ? null
          : exchangeRatesUpdatedAt ?? this.exchangeRatesUpdatedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool shouldShowGuidedTourVersion(int currentVersion) {
    return onboardingCompleted &&
        guidedTourCompletedVersion < currentVersion &&
        guidedTourSkippedVersion < currentVersion;
  }

  UserSettingsEntity toEntity() {
    return UserSettingsEntity(
      userId: userId,
      appDisplayName: appDisplayName,
      languagePreference: languagePreference.storageValue,
      baseCurrency: baseCurrency,
      supportedCurrencies: supportedCurrencies,
      conversionRates: conversionRates,
      defaultPaymentMethod: defaultPaymentMethod.storageValue,
      notificationSettings: notificationSettings,
      onboardingCompleted: onboardingCompleted,
      onboardingVersion: onboardingVersion,
      guidedTourCompletedVersion: guidedTourCompletedVersion,
      guidedTourSkippedVersion: guidedTourSkippedVersion,
      guidedTourLastStepId: guidedTourLastStepId,
      exchangeRatesUpdatedAt: exchangeRatesUpdatedAt,
      updatedAt: updatedAt,
    );
  }

  static UserSettings fromEntity(UserSettingsEntity entity) {
    return UserSettings(
      userId: entity.userId,
      appDisplayName: entity.appDisplayName,
      languagePreference:
          LanguagePreference.fromStorageValue(entity.languagePreference),
      baseCurrency: entity.baseCurrency,
      supportedCurrencies: entity.supportedCurrencies,
      conversionRates: entity.conversionRates,
      defaultPaymentMethod:
          PaymentMethod.fromStorageValue(entity.defaultPaymentMethod),
      notificationSettings: entity.notificationSettings,
      onboardingCompleted: entity.onboardingCompleted,
      onboardingVersion: entity.onboardingVersion,
      guidedTourCompletedVersion: entity.guidedTourCompletedVersion,
      guidedTourSkippedVersion: entity.guidedTourSkippedVersion,
      guidedTourLastStepId: entity.guidedTourLastStepId,
      exchangeRatesUpdatedAt: entity.exchangeRatesUpdatedAt,
      updatedAt: entity.updatedAt,
    );
  }

  static String _normalizeCurrency(String value, String fallback) {
    final normalized = value.trim().toUpperCase();
    return normalized.isEmpty ? fallback : normalized;
  }

  static String? _normalizeDisplayName(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed.length > 80 ? trimmed.substring(0, 80) : trimmed;
  }

  static List<String> _normalizeSupportedCurrencies(
    List<String> values,
    String baseCurrency,
  ) {
    final normalized = <String>[];
    final requiredCurrency = _normalizeCurrency(
      baseCurrency,
      defaultBaseCurrency,
    );
    for (final code in [...values, requiredCurrency]) {
      final currency = code.trim().toUpperCase();
      if (currency.isEmpty || normalized.contains(currency)) continue;
      normalized.add(currency);
    }
    return normalized.isEmpty ? [requiredCurrency] : normalized;
  }

  static Map<String, double> _normalizeConversionRates(
    Map<String, num>? values,
    String baseCurrency,
    List<String> supportedCurrencies,
  ) {
    if (values == null || values.isEmpty) return const {};
    final normalizedBase =
        _normalizeCurrency(baseCurrency, defaultBaseCurrency);
    final supported = _normalizeSupportedCurrencies(
      supportedCurrencies,
      normalizedBase,
    ).toSet();
    final normalized = <String, double>{};
    for (final entry in values.entries) {
      final currency = _normalizeCurrency(entry.key, '');
      final rate = entry.value.toDouble();
      if (currency.isEmpty ||
          currency == normalizedBase ||
          !supported.contains(currency) ||
          rate <= 0) {
        continue;
      }
      normalized[currency] = rate;
    }
    return Map.unmodifiable(normalized);
  }
}
