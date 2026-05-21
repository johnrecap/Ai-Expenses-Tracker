import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/expense_repository.dart';

class FirebaseSettingsRepository implements SettingsRepository {
  static const settingsDocumentId = 'profile';

  final String userId;
  final FirebaseFirestore _firestore;

  FirebaseSettingsRepository({
    required this.userId,
    FirebaseFirestore? firestore,
  })  : _firestore = _resolveFirestore(userId, firestore),
        assert(userId.isNotEmpty, 'FirebaseSettingsRepository requires userId');

  static FirebaseFirestore _resolveFirestore(
    String userId,
    FirebaseFirestore? firestore,
  ) {
    if (userId.trim().isEmpty) {
      throw ArgumentError.value(userId, 'userId', 'userId cannot be empty');
    }
    return firestore ?? FirebaseFirestore.instance;
  }

  static String settingsPathFor(String userId) => 'users/$userId/settings';

  DocumentReference<Map<String, dynamic>> get _settingsDocument =>
      _firestore.collection(settingsPathFor(userId)).doc(settingsDocumentId);

  @override
  Future<UserSettings> getSettings() async {
    try {
      final snapshot = await _settingsDocument.get();
      if (!snapshot.exists || snapshot.data() == null) {
        return ensureDefaultSettings();
      }
      return UserSettings.fromEntity(
        UserSettingsEntity.fromDocument(snapshot.data()!),
      );
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }

  @override
  Stream<UserSettings> watchSettings() {
    return _settingsDocument.snapshots().asyncMap((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return ensureDefaultSettings();
      }
      return UserSettings.fromEntity(
        UserSettingsEntity.fromDocument(snapshot.data()!),
      );
    });
  }

  @override
  Future<void> saveSettings(UserSettings settings) async {
    try {
      await _settingsDocument.set(settings.toEntity().toDocument());
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }

  @override
  Future<void> updateBaseCurrency(String currencyCode) async {
    final current = await getSettings();
    return saveSettings(
      current.copyWith(
        baseCurrency: currencyCode.trim().toUpperCase(),
        conversionRates: _ratesWithoutBase(
          current.conversionRates,
          currencyCode,
        ),
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> updateConversionRates(Map<String, num> conversionRates) async {
    final current = await getSettings();
    return saveSettings(
      current.copyWith(
        conversionRates: conversionRates,
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> updateExchangeRates({
    required Map<String, num> conversionRates,
    required DateTime exchangeRatesUpdatedAt,
  }) async {
    final current = await getSettings();
    return saveSettings(
      current.copyWith(
        conversionRates: conversionRates,
        exchangeRatesUpdatedAt: exchangeRatesUpdatedAt,
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> updateLanguagePreference(
    LanguagePreference languagePreference,
  ) async {
    final current = await getSettings();
    return saveSettings(
      current.copyWith(
        languagePreference: languagePreference,
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> updateDefaultPaymentMethod(PaymentMethod paymentMethod) async {
    final current = await getSettings();
    return saveSettings(
      current.copyWith(
        defaultPaymentMethod: paymentMethod,
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> updateAppDisplayName(String? displayName) async {
    final current = await getSettings();
    return saveSettings(
      current.copyWith(
        appDisplayName: displayName,
        clearAppDisplayName: displayName == null || displayName.trim().isEmpty,
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<UserSettings> ensureDefaultSettings() async {
    final defaults = UserSettings.defaults(userId: userId);
    await saveSettings(defaults);
    return defaults;
  }

  Map<String, num> _ratesWithoutBase(
    Map<String, num> conversionRates,
    String baseCurrency,
  ) {
    final normalizedBase = baseCurrency.trim().toUpperCase();
    return Map<String, num>.from(conversionRates)
      ..removeWhere(
          (currency, _) => currency.trim().toUpperCase() == normalizedBase);
  }
}
