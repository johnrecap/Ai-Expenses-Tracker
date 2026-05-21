import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/src/models/notification_settings.dart';

class UserSettingsEntity {
  final String userId;
  final String? appDisplayName;
  final String languagePreference;
  final String baseCurrency;
  final List<String> supportedCurrencies;
  final Map<String, double> conversionRates;
  final String defaultPaymentMethod;
  final NotificationSettings notificationSettings;
  final bool onboardingCompleted;
  final int onboardingVersion;
  final int guidedTourCompletedVersion;
  final int guidedTourSkippedVersion;
  final String? guidedTourLastStepId;
  final DateTime? exchangeRatesUpdatedAt;
  final DateTime updatedAt;

  const UserSettingsEntity({
    required this.userId,
    this.appDisplayName,
    required this.languagePreference,
    required this.baseCurrency,
    required this.supportedCurrencies,
    required this.conversionRates,
    required this.defaultPaymentMethod,
    required this.notificationSettings,
    required this.onboardingCompleted,
    required this.onboardingVersion,
    required this.guidedTourCompletedVersion,
    required this.guidedTourSkippedVersion,
    this.guidedTourLastStepId,
    this.exchangeRatesUpdatedAt,
    required this.updatedAt,
  });

  Map<String, Object?> toDocument() {
    return {
      'userId': userId,
      'appDisplayName': appDisplayName,
      'languagePreference': languagePreference,
      'baseCurrency': baseCurrency,
      'supportedCurrencies': supportedCurrencies,
      'conversionRates': conversionRates,
      'defaultPaymentMethod': defaultPaymentMethod,
      'notificationSettings': notificationSettings.toDocument(),
      'onboardingCompleted': onboardingCompleted,
      'onboardingVersion': onboardingVersion,
      'guidedTourCompletedVersion': guidedTourCompletedVersion,
      'guidedTourSkippedVersion': guidedTourSkippedVersion,
      'guidedTourLastStepId': guidedTourLastStepId,
      'exchangeRatesUpdatedAt': exchangeRatesUpdatedAt,
      'updatedAt': updatedAt,
    };
  }

  static UserSettingsEntity fromDocument(Map<String, Object?> doc) {
    final languagePreference = _languagePreferenceFromDocument(
      doc['languagePreference'],
    );
    final rawBaseCurrency = doc['baseCurrency'];
    final rawSupportedCurrencies = doc['supportedCurrencies'];
    final rawDefaultPaymentMethod = doc['defaultPaymentMethod'];
    final baseCurrency = rawBaseCurrency as String? ?? 'EGP';
    final supportedCurrencies = _supportedCurrenciesFromDocument(
      rawSupportedCurrencies,
    );
    final conversionRates = _conversionRatesFromDocument(
      doc['conversionRates'],
    );
    final defaultPaymentMethod = rawDefaultPaymentMethod as String? ?? 'cash';
    final hasExplicitOnboardingCompleted = doc['onboardingCompleted'] is bool;
    final legacyHasPreferenceFields = rawBaseCurrency is String &&
        rawSupportedCurrencies is List &&
        rawDefaultPaymentMethod is String;
    final legacyHasRequiredChoices = legacyHasPreferenceFields &&
        baseCurrency.trim().isNotEmpty &&
        supportedCurrencies
            .map((currency) => currency.trim().toUpperCase())
            .contains(baseCurrency.trim().toUpperCase()) &&
        defaultPaymentMethod.trim().isNotEmpty;
    final onboardingCompleted = hasExplicitOnboardingCompleted
        ? doc['onboardingCompleted'] as bool
        : legacyHasRequiredChoices;
    final onboardingVersion = _onboardingVersionFromDocument(
      doc['onboardingVersion'],
      fallback: onboardingCompleted ? 1 : 0,
    );

    return UserSettingsEntity(
      userId: doc['userId'] as String? ?? '',
      appDisplayName: _boundedStringOrNullFromDocument(
        doc['appDisplayName'],
        maxLength: 80,
      ),
      languagePreference: languagePreference,
      baseCurrency: baseCurrency,
      supportedCurrencies: supportedCurrencies,
      conversionRates: conversionRates,
      defaultPaymentMethod: defaultPaymentMethod,
      notificationSettings: NotificationSettings.fromDocument(
        doc['notificationSettings'],
      ),
      onboardingCompleted: onboardingCompleted,
      onboardingVersion: onboardingVersion,
      guidedTourCompletedVersion: _versionFromDocument(
        doc['guidedTourCompletedVersion'],
      ),
      guidedTourSkippedVersion: _versionFromDocument(
        doc['guidedTourSkippedVersion'],
      ),
      guidedTourLastStepId: _stringOrNullFromDocument(
        doc['guidedTourLastStepId'],
      ),
      exchangeRatesUpdatedAt: _nullableDateTimeFromDocument(
        doc['exchangeRatesUpdatedAt'],
      ),
      updatedAt: _dateTimeFromDocument(doc['updatedAt']),
    );
  }

  static String _languagePreferenceFromDocument(Object? value) {
    final normalized = value is String ? value.trim().toLowerCase() : '';
    switch (normalized) {
      case 'en':
      case 'ar':
      case 'system':
        return normalized;
      default:
        return 'system';
    }
  }

  static List<String> _supportedCurrenciesFromDocument(Object? value) {
    if (value is List) {
      final currencies = value.whereType<String>().toList();
      if (currencies.isNotEmpty) return currencies;
    }
    return const ['EGP', 'USD', 'EUR', 'SAR', 'AED'];
  }

  static Map<String, double> _conversionRatesFromDocument(Object? value) {
    if (value is! Map) return const {};
    final rates = <String, double>{};
    for (final entry in value.entries) {
      final currency =
          entry.key is String ? (entry.key as String).trim().toUpperCase() : '';
      final rawRate = entry.value;
      if (currency.isEmpty || rawRate is! num || rawRate <= 0) continue;
      rates[currency] = rawRate.toDouble();
    }
    return Map.unmodifiable(rates);
  }

  static int _onboardingVersionFromDocument(
    Object? value, {
    required int fallback,
  }) {
    if (value is int) return value < 0 ? 0 : value;
    if (value is num) return value.toInt() < 0 ? 0 : value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed < 0 ? 0 : parsed;
    }
    return fallback;
  }

  static int _versionFromDocument(Object? value) {
    if (value is int) return value < 0 ? 0 : value;
    if (value is num) return value.toInt() < 0 ? 0 : value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed < 0 ? 0 : parsed;
    }
    return 0;
  }

  static String? _stringOrNullFromDocument(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static String? _boundedStringOrNullFromDocument(
    Object? value, {
    required int maxLength,
  }) {
    final trimmed = _stringOrNullFromDocument(value);
    if (trimmed == null) return null;
    return trimmed.length > maxLength
        ? trimmed.substring(0, maxLength)
        : trimmed;
  }

  static DateTime _dateTimeFromDocument(Object? value) {
    return _nullableDateTimeFromDocument(value) ?? DateTime.now();
  }

  static DateTime? _nullableDateTimeFromDocument(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
