import 'package:expense_repository/expense_repository.dart';

class Transfer {
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

  const Transfer({
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

  static final empty = Transfer(
    transferId: '',
    userId: '',
    sourceWalletId: '',
    destinationWalletId: '',
    amount: 0,
    currency: 'EGP',
    feeAmount: 0,
    date: DateTime.fromMillisecondsSinceEpoch(0),
    note: '',
    isArchived: false,
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
  );

  Transfer copyWith({
    String? transferId,
    String? userId,
    String? sourceWalletId,
    String? destinationWalletId,
    double? amount,
    String? currency,
    double? feeAmount,
    String? feeWalletId,
    bool clearFeeWalletId = false,
    DateTime? date,
    String? note,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transfer(
      transferId: transferId ?? this.transferId,
      userId: userId ?? this.userId,
      sourceWalletId: sourceWalletId ?? this.sourceWalletId,
      destinationWalletId: destinationWalletId ?? this.destinationWalletId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      feeAmount: feeAmount ?? this.feeAmount,
      feeWalletId: clearFeeWalletId ? null : feeWalletId ?? this.feeWalletId,
      date: date ?? this.date,
      note: note ?? this.note,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  TransferEntity toEntity() {
    return TransferEntity(
      transferId: transferId,
      userId: userId,
      sourceWalletId: sourceWalletId,
      destinationWalletId: destinationWalletId,
      amount: amount,
      currency: currency,
      feeAmount: feeAmount,
      feeWalletId: feeWalletId,
      date: date,
      note: note,
      isArchived: isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static Transfer fromEntity(TransferEntity entity) {
    return Transfer(
      transferId: entity.transferId,
      userId: entity.userId,
      sourceWalletId: entity.sourceWalletId,
      destinationWalletId: entity.destinationWalletId,
      amount: entity.amount,
      currency: entity.currency,
      feeAmount: entity.feeAmount,
      feeWalletId: entity.feeWalletId,
      date: entity.date,
      note: entity.note,
      isArchived: entity.isArchived,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
