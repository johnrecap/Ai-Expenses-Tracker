import 'dart:convert';

import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/services/backup/backup.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('serializes supported collections with manifest counts', () {
    final category = Category(
      categoryId: 'cat-1',
      userId: 'user-1',
      name: 'Food',
      totalExpenses: 1,
      icon: 'restaurant',
      color: 0xff00aa00,
      createdAt: DateTime(2026, 5, 1),
      updatedAt: DateTime(2026, 5, 2),
    );
    final expense = Expense(
      expenseId: 'exp-1',
      userId: 'user-1',
      category: category,
      date: DateTime(2026, 5, 3),
      amount: 42.5,
      description: 'Lunch',
      currency: 'EGP',
      createdAt: DateTime(2026, 5, 3),
      updatedAt: DateTime(2026, 5, 4),
    );
    final settings = UserSettings.defaults(
      userId: 'user-1',
      updatedAt: DateTime(2026, 5, 5),
    );
    final wallet = WalletAccount(
      walletId: 'wallet-1',
      userId: 'user-1',
      name: 'Cash',
      type: WalletAccountType.cash,
      currency: 'EGP',
      openingBalance: 1000,
      isArchived: false,
      createdAt: DateTime(2026, 5, 1),
      updatedAt: DateTime(2026, 5, 2),
    );
    final transfer = Transfer(
      transferId: 'transfer-1',
      userId: 'user-1',
      sourceWalletId: 'wallet-1',
      destinationWalletId: 'wallet-2',
      amount: 100,
      currency: 'EGP',
      feeAmount: 0,
      date: DateTime(2026, 5, 3),
      note: 'Move cash',
      isArchived: false,
      createdAt: DateTime(2026, 5, 3),
      updatedAt: DateTime(2026, 5, 4),
    );

    final backup = const BackupSerializer().createBackup(
      userId: 'user-1',
      createdAt: DateTime(2026, 5, 6),
      appVersion: '1.0.0+1',
      expenses: [expense],
      categories: [category],
      settings: settings,
      wallets: [wallet],
      transfers: [transfer],
    );

    final json = backup.toJson();
    final manifest = json['manifest']! as Map<String, Object?>;
    final counts = manifest['counts']! as Map<String, int>;

    expect(manifest['schemaVersion'], currentBackupSchemaVersion);
    expect(manifest['appVersion'], '1.0.0+1');
    expect(counts[BackupCollection.expenses], 1);
    expect(counts[BackupCollection.categories], 1);
    expect(counts[BackupCollection.settings], 1);
    expect(counts[BackupCollection.wallets], 1);
    expect(counts[BackupCollection.transfers], 1);
    final parsed = BackupDocument.fromJsonString(backup.toJsonString());
    expect(parsed.wallets.single.walletId, wallet.walletId);
    expect(parsed.transfers.single.transferId, transfer.transferId);
    expect(backup.toJsonString(), isA<String>());
  });

  test('parses backup JSON and rejects count mismatches', () {
    final backup = const BackupSerializer().createBackup(
      userId: 'user-1',
      createdAt: DateTime(2026, 5, 6),
    );
    final json = backup.toJson();
    final manifest = json['manifest']! as Map<String, Object?>;
    final originalCounts = manifest['counts']! as Map<String, int>;
    manifest['counts'] = {
      ...originalCounts,
      BackupCollection.expenses: 99,
    };

    expect(
      () => BackupDocument.fromJsonString(jsonEncode(json)),
      throwsA(isA<BackupParseException>()),
    );
  });

  test('restore preview reports adds and duplicate conflicts', () {
    final category = Category(
      categoryId: 'cat-1',
      userId: 'user-1',
      name: 'Food',
      totalExpenses: 0,
      icon: 'restaurant',
      color: 0xff00aa00,
      createdAt: DateTime(2026, 5, 1),
      updatedAt: DateTime(2026, 5, 1),
    );
    final incoming = Expense(
      expenseId: 'exp-1',
      userId: 'user-1',
      category: category,
      date: DateTime(2026, 5, 2),
      amount: 10,
      createdAt: DateTime(2026, 5, 2),
      updatedAt: DateTime(2026, 5, 4),
    );
    final existing = Expense(
      expenseId: 'exp-1',
      userId: 'user-1',
      category: category,
      date: DateTime(2026, 5, 2),
      amount: 8,
      createdAt: DateTime(2026, 5, 2),
      updatedAt: DateTime(2026, 5, 3),
    );
    final wallet = WalletAccount(
      walletId: 'wallet-1',
      userId: 'user-1',
      name: 'Cash',
      type: WalletAccountType.cash,
      currency: 'EGP',
      openingBalance: 0,
      isArchived: false,
      createdAt: DateTime(2026, 5, 1),
      updatedAt: DateTime(2026, 5, 1),
    );
    final backup = const BackupSerializer().createBackup(
      userId: 'user-1',
      createdAt: DateTime(2026, 5, 6),
      expenses: [incoming],
      categories: [category],
      wallets: [wallet],
    );

    final preview = const RestorePreviewBuilder().preview(
      incoming: backup,
      targetUserId: 'user-1',
      existingExpenses: [existing],
    );

    expect(preview.updateCounts[BackupCollection.expenses], 1);
    expect(preview.addCounts[BackupCollection.categories], 1);
    expect(preview.addCounts[BackupCollection.wallets], 1);
    expect(preview.hasConflicts, isTrue);
    expect(preview.conflicts.first.reason, ImportConflictReason.duplicateId);
  });
}
