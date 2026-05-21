import 'package:expense_repository/expense_repository.dart';

enum WalletAccountType {
  cash('cash'),
  bank('bank'),
  card('card'),
  mobileWallet('mobile_wallet'),
  other('other');

  const WalletAccountType(this.storageValue);

  final String storageValue;

  static WalletAccountType fromStorageValue(String? value) {
    switch (value) {
      case 'bank':
        return WalletAccountType.bank;
      case 'card':
        return WalletAccountType.card;
      case 'mobile_wallet':
        return WalletAccountType.mobileWallet;
      case 'other':
        return WalletAccountType.other;
      case 'cash':
      default:
        return WalletAccountType.cash;
    }
  }
}

class WalletAccount {
  final String walletId;
  final String userId;
  final String name;
  final WalletAccountType type;
  final String currency;
  final double openingBalance;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WalletAccount({
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

  static final empty = WalletAccount(
    walletId: '',
    userId: '',
    name: '',
    type: WalletAccountType.cash,
    currency: 'EGP',
    openingBalance: 0,
    isArchived: false,
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
  );

  WalletAccount copyWith({
    String? walletId,
    String? userId,
    String? name,
    WalletAccountType? type,
    String? currency,
    double? openingBalance,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WalletAccount(
      walletId: walletId ?? this.walletId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      currency: currency ?? this.currency,
      openingBalance: openingBalance ?? this.openingBalance,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  WalletAccountEntity toEntity() {
    return WalletAccountEntity(
      walletId: walletId,
      userId: userId,
      name: name,
      type: type,
      currency: currency,
      openingBalance: openingBalance,
      isArchived: isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static WalletAccount fromEntity(WalletAccountEntity entity) {
    return WalletAccount(
      walletId: entity.walletId,
      userId: entity.userId,
      name: entity.name,
      type: entity.type,
      currency: entity.currency,
      openingBalance: entity.openingBalance,
      isArchived: entity.isArchived,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
