import 'package:cloud_firestore/cloud_firestore.dart';

class TransferEntity {
  final String transferId;
  final String userId;
  final String sourceWalletId;
  final String destinationWalletId;
  final double amount;
  final String currency;
  final double feeAmount;
  final String? feeWalletId;
  final DateTime date;
  final String note;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransferEntity({
    required this.transferId,
    required this.userId,
    required this.sourceWalletId,
    required this.destinationWalletId,
    required this.amount,
    required this.currency,
    required this.feeAmount,
    this.feeWalletId,
    required this.date,
    required this.note,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, Object?> toDocument() {
    return {
      'transferId': transferId,
      'userId': userId,
      'sourceWalletId': sourceWalletId,
      'destinationWalletId': destinationWalletId,
      'amount': amount,
      'currency': currency,
      'feeAmount': feeAmount,
      'feeWalletId': feeWalletId,
      'date': date,
      'note': note,
      'isArchived': isArchived,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  static TransferEntity fromDocument(Map<String, Object?> doc) {
    final now = DateTime.now();
    final date = _dateFromValue(doc['date']) ?? now;
    final createdAt = _dateFromValue(doc['createdAt']) ?? date;

    return TransferEntity(
      transferId: doc['transferId'] as String? ?? '',
      userId: doc['userId'] as String? ?? '',
      sourceWalletId: doc['sourceWalletId'] as String? ?? '',
      destinationWalletId: doc['destinationWalletId'] as String? ?? '',
      amount: _doubleFromValue(doc['amount']) ?? 0,
      currency: doc['currency'] as String? ?? 'EGP',
      feeAmount: _doubleFromValue(doc['feeAmount']) ?? 0,
      feeWalletId: doc['feeWalletId'] as String?,
      date: date,
      note: doc['note'] as String? ?? '',
      isArchived: doc['isArchived'] as bool? ?? false,
      createdAt: createdAt,
      updatedAt: _dateFromValue(doc['updatedAt']) ?? createdAt,
    );
  }

  static double? _doubleFromValue(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static DateTime? _dateFromValue(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
