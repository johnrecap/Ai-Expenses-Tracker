import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/expense_repository.dart';

class WalletAccountEntity {
  final String walletId;
  final String userId;
  final String name;
  final WalletAccountType type;
  final String currency;
  final double openingBalance;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WalletAccountEntity({
    required this.walletId,
    required this.userId,
    required this.name,
    required this.type,
    required this.currency,
    required this.openingBalance,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, Object?> toDocument() {
    return {
      'walletId': walletId,
      'userId': userId,
      'name': name,
      'type': type.storageValue,
      'currency': currency,
      'openingBalance': openingBalance,
      'isArchived': isArchived,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  static WalletAccountEntity fromDocument(Map<String, Object?> doc) {
    final now = DateTime.now();
    final createdAt = _dateFromValue(doc['createdAt']) ?? now;

    return WalletAccountEntity(
      walletId: doc['walletId'] as String? ?? '',
      userId: doc['userId'] as String? ?? '',
      name: doc['name'] as String? ?? '',
      type: WalletAccountType.fromStorageValue(doc['type'] as String?),
      currency: doc['currency'] as String? ?? 'EGP',
      openingBalance: _doubleFromValue(doc['openingBalance']) ?? 0,
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
