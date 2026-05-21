import 'package:expense_repository/expense_repository.dart';

abstract class WalletAccountRepository {
  Future<void> createWallet(WalletAccount wallet);
  Future<void> updateWallet(WalletAccount wallet);
  Future<void> archiveWallet(String walletId);
  Stream<List<WalletAccount>> watchWallets({bool includeArchived = false});
  Future<List<WalletAccount>> getWallets({bool includeArchived = false});
}
