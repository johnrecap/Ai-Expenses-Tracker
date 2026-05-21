enum PaymentMethod {
  cash,
  visa,
  wallet,
  bankTransfer;

  String get storageValue {
    switch (this) {
      case PaymentMethod.cash:
        return 'cash';
      case PaymentMethod.visa:
        return 'visa';
      case PaymentMethod.wallet:
        return 'wallet';
      case PaymentMethod.bankTransfer:
        return 'bank_transfer';
    }
  }

  String get label {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.visa:
        return 'Visa';
      case PaymentMethod.wallet:
        return 'Wallet';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
    }
  }

  static PaymentMethod fromStorageValue(String? value) {
    switch (value) {
      case 'visa':
        return PaymentMethod.visa;
      case 'wallet':
        return PaymentMethod.wallet;
      case 'bank_transfer':
        return PaymentMethod.bankTransfer;
      case 'cash':
      default:
        return PaymentMethod.cash;
    }
  }
}
