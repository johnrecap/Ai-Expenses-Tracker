import 'package:expense_repository/expense_repository.dart';

class LocalWalletAccountRepository implements WalletAccountRepository {
  final LocalRepositoryStore store;

  const LocalWalletAccountRepository({required this.store});

  @override
  Future<void> archiveWallet(String walletId) async {
    final current = store.wallets[walletId];
    if (current == null) return;
    await updateWallet(
        current.copyWith(isArchived: true, updatedAt: DateTime.now()));
  }

  @override
  Future<void> createWallet(WalletAccount wallet) async => updateWallet(wallet);

  @override
  Future<List<WalletAccount>> getWallets({bool includeArchived = false}) async {
    return store.orderedWallets(includeArchived: includeArchived);
  }

  @override
  Future<void> updateWallet(WalletAccount wallet) async {
    final normalized = wallet.copyWith(
      userId: wallet.userId.isEmpty ? store.userId : wallet.userId,
      updatedAt: DateTime.now(),
    );
    store.wallets[normalized.walletId] = normalized;
    store.enqueue(
      store.change(
        entityType: SyncEntityType.walletAccount,
        entityId: normalized.walletId,
        operation: SyncOperation.upsert,
        data: normalized.toEntity().toDocument(),
      ),
    );
    store.emitWallets();
  }

  @override
  Stream<List<WalletAccount>> watchWallets({bool includeArchived = false}) {
    return store.watchWallets().map(
          (_) => store.orderedWallets(includeArchived: includeArchived),
        );
  }
}
