import 'package:expense_repository/expense_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('wallet account entity round-trips and exposes user-scoped path', () {
    final wallet = WalletAccount(
      walletId: 'wallet-1',
      userId: 'user-1',
      name: 'Main cash',
      type: WalletAccountType.cash,
      currency: 'egp',
      openingBalance: 250.5,
      isArchived: false,
      createdAt: DateTime(2026, 5, 1),
      updatedAt: DateTime(2026, 5, 2),
    );

    final document = wallet.toEntity().toDocument();
    final parsed = WalletAccount.fromEntity(
      WalletAccountEntity.fromDocument(document),
    );

    expect(parsed.walletId, wallet.walletId);
    expect(parsed.userId, wallet.userId);
    expect(parsed.name, wallet.name);
    expect(parsed.type, WalletAccountType.cash);
    expect(parsed.currency, wallet.currency);
    expect(parsed.openingBalance, wallet.openingBalance);
    expect(FirebaseWalletAccountRepository.walletsPathFor('user-1'),
        'users/user-1/wallets');
    expect(
      () => FirebaseWalletAccountRepository(userId: ''),
      throwsArgumentError,
    );
  });

  test('transfer entity round-trips and exposes user-scoped path', () {
    final transfer = Transfer(
      transferId: 'transfer-1',
      userId: 'user-1',
      sourceWalletId: 'cash',
      destinationWalletId: 'bank',
      amount: 100,
      currency: 'EGP',
      feeAmount: 2.5,
      feeWalletId: 'cash',
      date: DateTime(2026, 5, 3),
      note: 'Deposit',
      isArchived: false,
      createdAt: DateTime(2026, 5, 3),
      updatedAt: DateTime(2026, 5, 4),
    );

    final document = transfer.toEntity().toDocument();
    final parsed = Transfer.fromEntity(TransferEntity.fromDocument(document));

    expect(parsed.transferId, transfer.transferId);
    expect(parsed.userId, transfer.userId);
    expect(parsed.sourceWalletId, transfer.sourceWalletId);
    expect(parsed.destinationWalletId, transfer.destinationWalletId);
    expect(parsed.amount, transfer.amount);
    expect(parsed.feeWalletId, transfer.feeWalletId);
    expect(FirebaseTransferRepository.transfersPathFor('user-1'),
        'users/user-1/transfers');
    expect(
      () => FirebaseTransferRepository(userId: ''),
      throwsArgumentError,
    );
  });
}
