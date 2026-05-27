import 'package:expense_repository/expense_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalDatabaseSchema', () {
    test('declares initial schema version and synced entity tables', () {
      expect(LocalDatabaseSchema.schemaVersion, 1);
      expect(LocalDatabaseSchema.syncedEntityTables, isNotEmpty);
      expect(
        LocalDatabaseSchema.syncedEntityTables.map((type) => type.toString()),
        containsAll([
          'LocalUserSettings',
          'LocalExpenses',
          'LocalCategories',
          'LocalSyncChanges',
        ]),
      );
    });
  });
}
