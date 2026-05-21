import 'models/category_alias.dart';

abstract class CategoryAliasRepository {
  Future<List<CategoryAlias>> getAliases();

  Stream<List<CategoryAlias>> watchAliases();

  Future<void> upsertAlias(CategoryAlias alias);

  Future<void> deleteAlias(String aliasId);
}
