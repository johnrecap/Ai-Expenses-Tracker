import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/services/backup/backup.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('backup contains migrated local finance data and parses it back',
      () async {
    final store = LocalRepositoryStore(
      userId: 'user-1',
      settings: UserSettings.defaults(userId: 'user-1').copyWith(
        baseCurrency: 'EGP',
        supportedCurrencies: const ['EGP', 'USD'],
        conversionRates: const {'USD': 50},
      ),
    );
    final expenses = LocalExpenseRepository(store: store);
    final wallets = LocalWalletAccountRepository(store: store);
    final transfers = LocalTransferRepository(store: store);

    await expenses.createExpense(_expense('expense-1'));
    await wallets.createWallet(
      WalletAccount(
        walletId: 'wallet-1',
        userId: 'user-1',
        name: 'Cash',
        type: WalletAccountType.cash,
        currency: 'EGP',
        openingBalance: 1000,
        isArchived: false,
        createdAt: DateTime(2026, 5),
        updatedAt: DateTime(2026, 5),
      ),
    );
    await transfers.createTransfer(
      Transfer(
        transferId: 'transfer-1',
        userId: 'user-1',
        sourceWalletId: 'wallet-1',
        destinationWalletId: 'wallet-2',
        amount: 100,
        currency: 'EGP',
        feeAmount: 0,
        date: DateTime(2026, 5, 20),
        note: 'Move cash',
        isArchived: false,
        createdAt: DateTime(2026, 5, 20),
        updatedAt: DateTime(2026, 5, 20),
      ),
    );

    final backup = const BackupSerializer().createBackup(
      userId: 'user-1',
      createdAt: DateTime(2026, 5, 20),
      expenses: await expenses.getExpenses(),
      settings: store.settings,
      wallets: await wallets.getWallets(),
      transfers: await transfers.getTransfers(),
    );
    final parsed = BackupDocument.fromJsonString(backup.toJsonString());

    expect(parsed.expenses.single.expenseId, 'expense-1');
    expect(parsed.wallets.single.walletId, 'wallet-1');
    expect(parsed.transfers.single.transferId, 'transfer-1');
    expect(parsed.manifest.counts[BackupCollection.expenses], 1);
  });
}

Expense _expense(String id) {
  final category = Category(
    categoryId: 'food',
    name: 'Food',
    totalExpenses: 0,
    icon: 'restaurant',
    color: 0,
  );
  return Expense(
    expenseId: id,
    userId: 'user-1',
    category: category,
    categoryId: category.categoryId,
    categoryName: category.name,
    date: DateTime(2026, 5, 20),
    amount: 100,
    currency: 'EGP',
  );
}
