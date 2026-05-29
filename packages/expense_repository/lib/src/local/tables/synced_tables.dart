import 'package:drift/drift.dart';

mixin SyncedColumns on Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get serverRevision => integer().withDefault(const Constant(0))();
  DateTimeColumn get clientUpdatedAt => dateTime().nullable()();
  TextColumn get originDeviceId => text().nullable()();
  TextColumn get legacyFirestorePath => text().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();
}

class LocalUserSettings extends Table {
  TextColumn get userId => text()();
  TextColumn get appDisplayName => text().nullable()();
  TextColumn get languagePreference =>
      text().withDefault(const Constant('system'))();
  TextColumn get baseCurrency => text().withDefault(const Constant('EGP'))();
  TextColumn get supportedCurrenciesJson => text()();
  TextColumn get conversionRatesJson => text()();
  DateTimeColumn get exchangeRatesUpdatedAt => dateTime().nullable()();
  TextColumn get defaultPaymentMethod =>
      text().withDefault(const Constant('cash'))();
  TextColumn get notificationSettingsJson => text()();
  BoolColumn get onboardingCompleted =>
      boolean().withDefault(const Constant(false))();
  IntColumn get onboardingVersion => integer().withDefault(const Constant(0))();
  IntColumn get guidedTourCompletedVersion =>
      integer().withDefault(const Constant(0))();
  IntColumn get guidedTourSkippedVersion =>
      integer().withDefault(const Constant(0))();
  TextColumn get guidedTourLastStepId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get serverRevision => integer().withDefault(const Constant(0))();
  DateTimeColumn get clientUpdatedAt => dateTime().nullable()();
  TextColumn get originDeviceId => text().nullable()();
  TextColumn get legacyFirestorePath => text().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  @override
  Set<Column> get primaryKey => {userId};
}

class LocalCategories extends Table with SyncedColumns {
  TextColumn get name => text()();
  TextColumn get icon => text()();
  IntColumn get color => integer()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalCategoryAliases extends Table with SyncedColumns {
  TextColumn get alias => text()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get locale => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalExpenses extends Table with SyncedColumns {
  TextColumn get categoryId => text().nullable()();
  TextColumn get categoryName => text()();
  TextColumn get categoryIcon => text()();
  IntColumn get categoryColor => integer()();
  TextColumn get categorySnapshotJson => text().nullable()();
  DateTimeColumn get spentAt => dateTime()();
  RealColumn get amount => real()();
  IntColumn get amountMinor => integer().nullable()();
  TextColumn get currency => text()();
  TextColumn get baseCurrencyAtEntry => text().nullable()();
  RealColumn get conversionRateToBase => real().nullable()();
  DateTimeColumn get conversionRateDate => dateTime().nullable()();
  TextColumn get moneySnapshotJson => text().nullable()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get merchant => text().nullable()();
  TextColumn get tagsJson => text().withDefault(const Constant('[]'))();
  TextColumn get paymentMethod => text().withDefault(const Constant('cash'))();
  TextColumn get source => text().withDefault(const Constant('manual'))();
  TextColumn get walletAccountId => text().nullable()();
  TextColumn get walletAccountName => text().nullable()();
  TextColumn get recurringExpenseId => text().nullable()();
  TextColumn get aiActionId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalBudgets extends Table with SyncedColumns {
  TextColumn get month => text()();
  RealColumn get amount => real()();
  TextColumn get currency => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalCategoryBudgets extends Table with SyncedColumns {
  TextColumn get month => text()();
  TextColumn get categoryId => text().nullable()();
  RealColumn get amount => real()();
  TextColumn get currency => text()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalRecurringExpenses extends Table with SyncedColumns {
  TextColumn get categoryId => text().nullable()();
  RealColumn get amount => real()();
  TextColumn get currency => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get paymentMethod => text().withDefault(const Constant('cash'))();
  TextColumn get frequency => text()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get nextDueDate => dateTime().nullable()();
  BoolColumn get isPaused => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalSavingGoals extends Table with SyncedColumns {
  TextColumn get name => text()();
  RealColumn get targetAmount => real()();
  RealColumn get currentAmount => real().withDefault(const Constant(0))();
  TextColumn get currency => text()();
  DateTimeColumn get deadline => dateTime().nullable()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalWalletAccounts extends Table with SyncedColumns {
  TextColumn get name => text()();
  TextColumn get currency => text()();
  RealColumn get openingBalance => real().withDefault(const Constant(0))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalTransfers extends Table with SyncedColumns {
  TextColumn get fromWalletId => text().nullable()();
  TextColumn get toWalletId => text().nullable()();
  RealColumn get amount => real()();
  TextColumn get currency => text()();
  DateTimeColumn get transferredAt => dateTime()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalAiActionLogs extends Table with SyncedColumns {
  TextColumn get status => text()();
  TextColumn get intent => text()();
  TextColumn get provider => text().nullable()();
  TextColumn get model => text().nullable()();
  TextColumn get providerRequestId => text().nullable()();
  IntColumn get inputTokens => integer().nullable()();
  IntColumn get outputTokens => integer().nullable()();
  TextColumn get errorCode => text().nullable()();
  TextColumn get payloadJson => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalSyncChanges extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get operation => text()();
  TextColumn get payloadJson => text().nullable()();
  IntColumn get baseRevision => integer().nullable()();
  DateTimeColumn get clientUpdatedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  TextColumn get lastErrorCode => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
