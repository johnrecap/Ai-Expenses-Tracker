import 'package:expense_repository/expense_repository.dart';

class LocalTransferRepository implements TransferRepository {
  final LocalRepositoryStore store;

  const LocalTransferRepository({required this.store});

  @override
  Future<void> archiveTransfer(String transferId) async {
    final current = store.transfers[transferId];
    if (current == null) return;
    await updateTransfer(
      current.copyWith(isArchived: true, updatedAt: DateTime.now()),
    );
  }

  @override
  Future<void> createTransfer(Transfer transfer) async =>
      updateTransfer(transfer);

  @override
  Future<List<Transfer>> getTransfers({bool includeArchived = false}) async {
    return store.orderedTransfers(includeArchived: includeArchived);
  }

  @override
  Future<void> updateTransfer(Transfer transfer) async {
    final normalized = transfer.copyWith(
      userId: transfer.userId.isEmpty ? store.userId : transfer.userId,
      updatedAt: DateTime.now(),
    );
    store.transfers[normalized.transferId] = normalized;
    store.enqueue(
      store.change(
        entityType: SyncEntityType.transfer,
        entityId: normalized.transferId,
        operation: SyncOperation.upsert,
        data: normalized.toEntity().toDocument(),
      ),
    );
    store.emitTransfers();
  }

  @override
  Stream<List<Transfer>> watchTransfers({bool includeArchived = false}) {
    return store.watchTransfers().map(
          (_) => store.orderedTransfers(includeArchived: includeArchived),
        );
  }
}
