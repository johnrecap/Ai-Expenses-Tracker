import 'package:expense_repository/expense_repository.dart';

class LocalCategoryAliasRepository implements CategoryAliasRepository {
  final LocalRepositoryStore store;

  const LocalCategoryAliasRepository({
    required this.store,
  });

  @override
  Future<void> deleteAlias(String aliasId) async {
    store.aliases.remove(aliasId);
    store.enqueue(
      SyncChange(
        id: 'alias-$aliasId-${DateTime.now().microsecondsSinceEpoch}',
        userId: store.userId,
        entityType: SyncEntityType.categoryAlias,
        entityId: aliasId,
        operation: SyncOperation.delete,
        data: const {},
        clientUpdatedAt: DateTime.now(),
      ),
    );
    store.emitAliases();
  }

  @override
  Future<List<CategoryAlias>> getAliases() async => store.orderedAliases();

  @override
  Future<void> upsertAlias(CategoryAlias alias) async {
    final normalized = alias.copyWith(
      userId: store.userId,
      updatedAt: DateTime.now(),
    );
    store.aliases[normalized.aliasId] = normalized;
    store.enqueue(
      SyncChange(
        id: 'alias-${normalized.aliasId}-${DateTime.now().microsecondsSinceEpoch}',
        userId: store.userId,
        entityType: SyncEntityType.categoryAlias,
        entityId: normalized.aliasId,
        operation: SyncOperation.upsert,
        data: normalized.toEntity().toDocument(),
        clientUpdatedAt: DateTime.now(),
      ),
    );
    store.emitAliases();
  }

  @override
  Stream<List<CategoryAlias>> watchAliases() => store.watchAliases();
}
