import 'dart:convert';

import 'package:expense_repository/expense_repository.dart';

const currentBackupSchemaVersion = 1;

class BackupCollection {
  static const expenses = 'expenses';
  static const categories = 'categories';
  static const budgets = 'budgets';
  static const categoryBudgets = 'categoryBudgets';
  static const recurringExpenses = 'recurringExpenses';
  static const savingGoals = 'savingGoals';
  static const settings = 'settings';
  static const categoryAliases = 'categoryAliases';
  static const wallets = 'wallets';
  static const transfers = 'transfers';

  static const supported = [
    expenses,
    categories,
    budgets,
    categoryBudgets,
    recurringExpenses,
    savingGoals,
    settings,
    categoryAliases,
    wallets,
    transfers,
  ];
}

class BackupParseException implements Exception {
  const BackupParseException(this.message);

  final String message;

  @override
  String toString() => 'BackupParseException: $message';
}

class BackupManifest {
  const BackupManifest({
    required this.schemaVersion,
    required this.appVersion,
    required this.createdAt,
    required this.sourceUserId,
    required this.collections,
    required this.counts,
    this.warnings = const [],
  });

  final int schemaVersion;
  final String appVersion;
  final DateTime createdAt;
  final String sourceUserId;
  final List<String> collections;
  final Map<String, int> counts;
  final List<String> warnings;

  Map<String, Object?> toJson() {
    return {
      'schemaVersion': schemaVersion,
      'appVersion': appVersion,
      'createdAt': createdAt.toIso8601String(),
      'sourceUserId': sourceUserId,
      'collections': collections,
      'counts': counts,
      'warnings': warnings,
    };
  }

  static BackupManifest fromJson(Map<String, Object?> json) {
    final schemaVersion = _intFromValue(json['schemaVersion']);
    if (schemaVersion == null) {
      throw const BackupParseException('Backup schema version is missing.');
    }
    if (schemaVersion < 1 || schemaVersion > currentBackupSchemaVersion) {
      throw BackupParseException(
        'Backup schema version $schemaVersion is not supported.',
      );
    }

    final collections = _stringListFromValue(json['collections']);
    final unsupported = collections
        .where((collection) => !BackupCollection.supported.contains(collection))
        .toList();
    if (unsupported.isNotEmpty) {
      throw BackupParseException(
        'Backup contains unsupported collections: ${unsupported.join(', ')}.',
      );
    }

    return BackupManifest(
      schemaVersion: schemaVersion,
      appVersion: json['appVersion'] as String? ?? 'unknown',
      createdAt: _dateFromValue(json['createdAt']) ?? DateTime.now(),
      sourceUserId: json['sourceUserId'] as String? ?? '',
      collections: collections,
      counts: _intMapFromValue(json['counts']),
      warnings: _stringListFromValue(json['warnings']),
    );
  }
}

class BackupDocument {
  const BackupDocument({
    required this.manifest,
    this.expenses = const [],
    this.categories = const [],
    this.budgets = const [],
    this.categoryBudgets = const [],
    this.recurringExpenses = const [],
    this.savingGoals = const [],
    this.settings,
    this.categoryAliases = const [],
    this.wallets = const [],
    this.transfers = const [],
  });

  final BackupManifest manifest;
  final List<Expense> expenses;
  final List<Category> categories;
  final List<Budget> budgets;
  final List<CategoryBudget> categoryBudgets;
  final List<RecurringExpense> recurringExpenses;
  final List<SavingGoal> savingGoals;
  final UserSettings? settings;
  final List<CategoryAlias> categoryAliases;
  final List<WalletAccount> wallets;
  final List<Transfer> transfers;

  String toJsonString() => jsonEncode(toJson());

  Map<String, Object?> toJson() {
    return {
      'manifest': manifest.toJson(),
      'data': {
        BackupCollection.expenses: expenses
            .map((expense) => _encodeDocument(expense.toEntity().toDocument()))
            .toList(),
        BackupCollection.categories: categories
            .map(
                (category) => _encodeDocument(category.toEntity().toDocument()))
            .toList(),
        BackupCollection.budgets: budgets
            .map((budget) => _encodeDocument(budget.toEntity().toDocument()))
            .toList(),
        BackupCollection.categoryBudgets: categoryBudgets
            .map((budget) => _encodeDocument(budget.toEntity().toDocument()))
            .toList(),
        BackupCollection.recurringExpenses: recurringExpenses
            .map((expense) => _encodeDocument(expense.toEntity().toDocument()))
            .toList(),
        BackupCollection.savingGoals: savingGoals
            .map((goal) => _encodeDocument(goal.toEntity().toDocument()))
            .toList(),
        BackupCollection.settings: settings == null
            ? null
            : _encodeDocument(settings!.toEntity().toDocument()),
        BackupCollection.categoryAliases: categoryAliases
            .map((alias) => _encodeDocument(alias.toEntity().toDocument()))
            .toList(),
        BackupCollection.wallets: wallets
            .map((wallet) => _encodeDocument(wallet.toEntity().toDocument()))
            .toList(),
        BackupCollection.transfers: transfers
            .map(
                (transfer) => _encodeDocument(transfer.toEntity().toDocument()))
            .toList(),
      },
    };
  }

  static BackupDocument fromJsonString(String content) {
    final decoded = jsonDecode(content);
    if (decoded is! Map) {
      throw const BackupParseException('Backup root must be a JSON object.');
    }
    return fromJson(Map<String, Object?>.from(decoded));
  }

  static BackupDocument fromJson(Map<String, Object?> json) {
    final manifestJson = json['manifest'];
    final dataJson = json['data'];
    if (manifestJson is! Map) {
      throw const BackupParseException('Backup manifest is missing.');
    }
    if (dataJson is! Map) {
      throw const BackupParseException('Backup data is missing.');
    }

    final manifest = BackupManifest.fromJson(
      Map<String, Object?>.from(manifestJson),
    );
    final data = Map<String, Object?>.from(dataJson);

    final document = BackupDocument(
      manifest: manifest,
      expenses: _documentsFromValue(data[BackupCollection.expenses])
          .map((doc) => Expense.fromEntity(ExpenseEntity.fromDocument(doc)))
          .toList(),
      categories: _documentsFromValue(data[BackupCollection.categories])
          .map((doc) => Category.fromEntity(CategoryEntity.fromDocument(doc)))
          .toList(),
      budgets: _documentsFromValue(data[BackupCollection.budgets])
          .map((doc) => Budget.fromEntity(BudgetEntity.fromDocument(doc)))
          .toList(),
      categoryBudgets:
          _documentsFromValue(data[BackupCollection.categoryBudgets])
              .map(
                (doc) => CategoryBudget.fromEntity(
                  CategoryBudgetEntity.fromDocument(doc),
                ),
              )
              .toList(),
      recurringExpenses:
          _documentsFromValue(data[BackupCollection.recurringExpenses])
              .map(
                (doc) => RecurringExpense.fromEntity(
                  RecurringExpenseEntity.fromDocument(doc),
                ),
              )
              .toList(),
      savingGoals: _documentsFromValue(data[BackupCollection.savingGoals])
          .map((doc) =>
              SavingGoal.fromEntity(SavingGoalEntity.fromDocument(doc)))
          .toList(),
      settings: _settingsFromValue(data[BackupCollection.settings]),
      categoryAliases:
          _documentsFromValue(data[BackupCollection.categoryAliases])
              .map(
                (doc) => CategoryAlias.fromEntity(
                  CategoryAliasEntity.fromDocument(doc),
                ),
              )
              .toList(),
      wallets: _documentsFromValue(data[BackupCollection.wallets])
          .map((doc) => WalletAccount.fromEntity(
                WalletAccountEntity.fromDocument(doc),
              ))
          .toList(),
      transfers: _documentsFromValue(data[BackupCollection.transfers])
          .map((doc) => Transfer.fromEntity(TransferEntity.fromDocument(doc)))
          .toList(),
    );
    document.validateOwnership(manifest.sourceUserId);
    document.validateManifestCounts();
    return document;
  }

  void validateOwnership(String expectedUserId) {
    final invalid = <String>[];
    void check(String collection, Iterable<String> userIds) {
      if (userIds.any((id) => id.isNotEmpty && id != expectedUserId)) {
        invalid.add(collection);
      }
    }

    check(BackupCollection.expenses, expenses.map((item) => item.userId));
    check(BackupCollection.categories, categories.map((item) => item.userId));
    check(BackupCollection.budgets, budgets.map((item) => item.userId));
    check(
      BackupCollection.categoryBudgets,
      categoryBudgets.map((item) => item.userId),
    );
    check(
      BackupCollection.recurringExpenses,
      recurringExpenses.map((item) => item.userId),
    );
    check(BackupCollection.savingGoals, savingGoals.map((item) => item.userId));
    check(
      BackupCollection.categoryAliases,
      categoryAliases.map((item) => item.userId),
    );
    check(BackupCollection.wallets, wallets.map((item) => item.userId));
    check(BackupCollection.transfers, transfers.map((item) => item.userId));
    if (settings != null && settings!.userId.isNotEmpty) {
      check(BackupCollection.settings, [settings!.userId]);
    }

    if (invalid.isNotEmpty) {
      throw BackupParseException(
        'Backup contains data owned by a different user in: ${invalid.join(', ')}.',
      );
    }
  }

  void validateTargetUser(String targetUserId) {
    if (manifest.sourceUserId.isNotEmpty &&
        manifest.sourceUserId != targetUserId) {
      throw BackupParseException(
        'Backup belongs to ${manifest.sourceUserId}, not $targetUserId.',
      );
    }
  }

  void validateManifestCounts() {
    final actual = _countsFor(this);
    for (final entry in manifest.counts.entries) {
      if (actual[entry.key] != entry.value) {
        throw BackupParseException(
          'Backup count mismatch for ${entry.key}: expected ${entry.value}, found ${actual[entry.key] ?? 0}.',
        );
      }
    }
  }
}

Map<String, int> backupCountsFor(BackupDocument document) {
  return _countsFor(document);
}

Map<String, int> _countsFor(BackupDocument document) {
  return {
    BackupCollection.expenses: document.expenses.length,
    BackupCollection.categories: document.categories.length,
    BackupCollection.budgets: document.budgets.length,
    BackupCollection.categoryBudgets: document.categoryBudgets.length,
    BackupCollection.recurringExpenses: document.recurringExpenses.length,
    BackupCollection.savingGoals: document.savingGoals.length,
    BackupCollection.settings: document.settings == null ? 0 : 1,
    BackupCollection.categoryAliases: document.categoryAliases.length,
    BackupCollection.wallets: document.wallets.length,
    BackupCollection.transfers: document.transfers.length,
  };
}

Object? _encodeDocument(Object? value) {
  if (value is DateTime) return value.toIso8601String();
  if (value is Map) {
    return value.map(
      (key, value) => MapEntry(key.toString(), _encodeDocument(value)),
    );
  }
  if (value is Iterable) {
    return value.map(_encodeDocument).toList();
  }
  return value;
}

List<Map<String, dynamic>> _documentsFromValue(Object? value) {
  if (value == null) return const [];
  if (value is! List) {
    throw const BackupParseException('Backup collection data must be a list.');
  }
  return value.map((item) {
    if (item is! Map) {
      throw const BackupParseException(
        'Backup collection item must be an object.',
      );
    }
    return Map<String, dynamic>.from(item);
  }).toList();
}

UserSettings? _settingsFromValue(Object? value) {
  if (value == null) return null;
  if (value is! Map) {
    throw const BackupParseException('Backup settings must be an object.');
  }
  return UserSettings.fromEntity(
    UserSettingsEntity.fromDocument(Map<String, Object?>.from(value)),
  );
}

int? _intFromValue(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

Map<String, int> _intMapFromValue(Object? value) {
  if (value is! Map) return const {};
  final result = <String, int>{};
  for (final entry in value.entries) {
    result[entry.key.toString()] = _intFromValue(entry.value) ?? 0;
  }
  return result;
}

List<String> _stringListFromValue(Object? value) {
  if (value is! List) return const [];
  return value.whereType<String>().toList();
}

DateTime? _dateFromValue(Object? value) {
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}
