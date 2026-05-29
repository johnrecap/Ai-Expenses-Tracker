import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/src/models/models.dart';

class MoneySnapshotEntity {
  const MoneySnapshotEntity({
    required this.sourceAmount,
    required this.sourceCurrency,
    required this.targetCurrency,
    required this.conversionRate,
    required this.convertedAmount,
    required this.capturedAt,
    this.rateUpdatedAt,
    required this.rateSource,
    required this.rateFreshness,
  });

  final double sourceAmount;
  final String sourceCurrency;
  final String targetCurrency;
  final double conversionRate;
  final double convertedAmount;
  final DateTime capturedAt;
  final DateTime? rateUpdatedAt;
  final String rateSource;
  final String rateFreshness;

  Map<String, Object?> toDocument() {
    return {
      'sourceAmount': sourceAmount,
      'sourceCurrency': sourceCurrency,
      'targetCurrency': targetCurrency,
      'conversionRate': conversionRate,
      'convertedAmount': convertedAmount,
      'capturedAt': capturedAt,
      'rateUpdatedAt': rateUpdatedAt,
      'rateSource': rateSource,
      'rateFreshness': rateFreshness,
    };
  }

  MoneySnapshot toModel() {
    return MoneySnapshot(
      sourceAmount: sourceAmount,
      sourceCurrency: sourceCurrency,
      targetCurrency: targetCurrency,
      conversionRate: conversionRate,
      convertedAmount: convertedAmount,
      capturedAt: capturedAt,
      rateUpdatedAt: rateUpdatedAt,
      rateSource: rateSource,
      rateFreshness: rateFreshness,
    );
  }

  static MoneySnapshotEntity fromModel(MoneySnapshot snapshot) {
    return MoneySnapshotEntity(
      sourceAmount: snapshot.sourceAmount,
      sourceCurrency: snapshot.sourceCurrency,
      targetCurrency: snapshot.targetCurrency,
      conversionRate: snapshot.conversionRate,
      convertedAmount: snapshot.convertedAmount,
      capturedAt: snapshot.capturedAt,
      rateUpdatedAt: snapshot.rateUpdatedAt,
      rateSource: snapshot.rateSource,
      rateFreshness: snapshot.rateFreshness,
    );
  }

  static MoneySnapshotEntity? fromDocument(Object? value) {
    if (value is! Map) return null;
    final doc = Map<String, dynamic>.from(value);
    final sourceAmount = _doubleFromValue(doc['sourceAmount']);
    final sourceCurrency = doc['sourceCurrency'] as String?;
    final targetCurrency = doc['targetCurrency'] as String?;
    final conversionRate = _doubleFromValue(doc['conversionRate']);
    final convertedAmount = _doubleFromValue(doc['convertedAmount']);
    final capturedAt = _dateFromValue(doc['capturedAt']);

    if (sourceAmount == null ||
        sourceCurrency == null ||
        targetCurrency == null ||
        conversionRate == null ||
        convertedAmount == null ||
        capturedAt == null ||
        sourceCurrency.trim().isEmpty ||
        targetCurrency.trim().isEmpty ||
        conversionRate <= 0 ||
        !conversionRate.isFinite ||
        !convertedAmount.isFinite ||
        !sourceAmount.isFinite) {
      return null;
    }

    return MoneySnapshotEntity(
      sourceAmount: sourceAmount,
      sourceCurrency: sourceCurrency,
      targetCurrency: targetCurrency,
      conversionRate: conversionRate,
      convertedAmount: convertedAmount,
      capturedAt: capturedAt,
      rateUpdatedAt: _dateFromValue(doc['rateUpdatedAt']),
      rateSource: (doc['rateSource'] as String?)?.trim().isNotEmpty == true
          ? (doc['rateSource'] as String).trim()
          : MoneySnapshot.defaultRateSource,
      rateFreshness:
          (doc['rateFreshness'] as String?)?.trim().isNotEmpty == true
              ? (doc['rateFreshness'] as String).trim()
              : MoneySnapshot.defaultRateFreshness,
    );
  }

  static DateTime? _dateFromValue(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static double? _doubleFromValue(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.trim().replaceAll(',', '.'));
    }
    return null;
  }
}
