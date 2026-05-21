import 'package:expense_repository/expense_repository.dart';

abstract class TransferRepository {
  Future<void> createTransfer(Transfer transfer);
  Future<void> updateTransfer(Transfer transfer);
  Future<void> archiveTransfer(String transferId);
  Stream<List<Transfer>> watchTransfers({bool includeArchived = false});
  Future<List<Transfer>> getTransfers({bool includeArchived = false});
}
