import {
  boolean,
  date,
  index,
  integer,
  jsonb,
  numeric,
  pgTable,
  serial,
  text,
  timestamp,
  uniqueIndex,
  uuid,
} from "drizzle-orm/pg-core";

import { syncColumns } from "./common.js";
import { users } from "./users.js";

const userReference = () =>
  uuid("user_id")
    .notNull()
    .references(() => users.id, { onDelete: "cascade" });

export const userSettings = pgTable("user_settings", {
  userId: uuid("user_id")
    .primaryKey()
    .references(() => users.id, { onDelete: "cascade" }),
  appDisplayName: text("app_display_name"),
  languagePreference: text("language_preference").notNull().default("system"),
  baseCurrency: text("base_currency").notNull().default("EGP"),
  supportedCurrencies: jsonb("supported_currencies")
    .$type<string[]>()
    .notNull()
    .default(["EGP", "USD", "EUR", "SAR", "AED"]),
  conversionRates: jsonb("conversion_rates")
    .$type<Record<string, number>>()
    .notNull()
    .default({}),
  exchangeRatesUpdatedAt: timestamp("exchange_rates_updated_at", {
    withTimezone: true,
  }),
  defaultPaymentMethod: text("default_payment_method")
    .notNull()
    .default("cash"),
  notificationSettings: jsonb("notification_settings")
    .$type<Record<string, unknown>>()
    .notNull()
    .default({}),
  onboardingCompleted: boolean("onboarding_completed").notNull().default(false),
  onboardingVersion: integer("onboarding_version").notNull().default(0),
  guidedTourCompletedVersion: integer("guided_tour_completed_version")
    .notNull()
    .default(0),
  guidedTourSkippedVersion: integer("guided_tour_skipped_version")
    .notNull()
    .default(0),
  guidedTourLastStepId: text("guided_tour_last_step_id"),
  ...syncColumns,
});

export const categories = pgTable(
  "categories",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    userId: userReference(),
    name: text("name").notNull(),
    icon: text("icon").notNull(),
    color: integer("color").notNull(),
    isArchived: boolean("is_archived").notNull().default(false),
    ...syncColumns,
  },
  (table) => ({
    userIdIdx: index("categories_user_id_idx").on(table.userId),
    userNameUnique: uniqueIndex("categories_user_name_unique").on(
      table.userId,
      table.name,
    ),
  }),
);

export const categoryAliases = pgTable(
  "category_aliases",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    userId: userReference(),
    alias: text("alias").notNull(),
    categoryId: uuid("category_id").references(() => categories.id, {
      onDelete: "set null",
    }),
    locale: text("locale"),
    ...syncColumns,
  },
  (table) => ({
    userAliasIdx: index("category_aliases_user_alias_idx").on(
      table.userId,
      table.alias,
    ),
  }),
);

export const walletAccounts = pgTable(
  "wallet_accounts",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    userId: userReference(),
    name: text("name").notNull(),
    currency: text("currency").notNull(),
    openingBalance: numeric("opening_balance", {
      precision: 18,
      scale: 4,
    })
      .notNull()
      .default("0"),
    isArchived: boolean("is_archived").notNull().default(false),
    ...syncColumns,
  },
  (table) => ({
    userIdIdx: index("wallet_accounts_user_id_idx").on(table.userId),
  }),
);

export const recurringExpenses = pgTable(
  "recurring_expenses",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    userId: userReference(),
    categoryId: uuid("category_id").references(() => categories.id, {
      onDelete: "set null",
    }),
    amount: numeric("amount", { precision: 18, scale: 4 }).notNull(),
    currency: text("currency").notNull(),
    description: text("description").notNull().default(""),
    paymentMethod: text("payment_method").notNull().default("cash"),
    frequency: text("frequency").notNull(),
    startDate: date("start_date").notNull(),
    nextDueDate: date("next_due_date"),
    isPaused: boolean("is_paused").notNull().default(false),
    isArchived: boolean("is_archived").notNull().default(false),
    ...syncColumns,
  },
  (table) => ({
    userDueIdx: index("recurring_expenses_user_due_idx").on(
      table.userId,
      table.nextDueDate,
    ),
  }),
);

export const aiActionLogs = pgTable(
  "ai_action_logs",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    userId: userReference(),
    status: text("status").notNull(),
    intent: text("intent").notNull(),
    provider: text("provider"),
    model: text("model"),
    providerRequestId: text("provider_request_id"),
    inputTokens: integer("input_tokens"),
    outputTokens: integer("output_tokens"),
    errorCode: text("error_code"),
    payload: jsonb("payload").$type<Record<string, unknown>>(),
    ...syncColumns,
  },
  (table) => ({
    userCreatedIdx: index("ai_action_logs_user_created_idx").on(
      table.userId,
      table.createdAt,
    ),
  }),
);

export const expenses = pgTable(
  "expenses",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    userId: userReference(),
    categoryId: uuid("category_id").references(() => categories.id, {
      onDelete: "set null",
    }),
    categoryName: text("category_name").notNull(),
    categoryIcon: text("category_icon").notNull(),
    categoryColor: integer("category_color").notNull(),
    categorySnapshot:
      jsonb("category_snapshot").$type<Record<string, unknown>>(),
    spentAt: timestamp("spent_at", { withTimezone: true }).notNull(),
    amount: numeric("amount", { precision: 18, scale: 4 }).notNull(),
    amountMinor: integer("amount_minor"),
    currency: text("currency").notNull(),
    baseCurrencyAtEntry: text("base_currency_at_entry"),
    conversionRateToBase: numeric("conversion_rate_to_base", {
      precision: 24,
      scale: 10,
    }),
    conversionRateDate: date("conversion_rate_date"),
    moneySnapshot: jsonb("money_snapshot").$type<Record<string, unknown>>(),
    description: text("description").notNull().default(""),
    merchant: text("merchant"),
    tags: jsonb("tags").$type<string[]>().notNull().default([]),
    paymentMethod: text("payment_method").notNull().default("cash"),
    source: text("source").notNull().default("manual"),
    walletAccountId: uuid("wallet_account_id").references(
      () => walletAccounts.id,
      { onDelete: "set null" },
    ),
    walletAccountName: text("wallet_account_name"),
    recurringExpenseId: uuid("recurring_expense_id").references(
      () => recurringExpenses.id,
      { onDelete: "set null" },
    ),
    aiActionId: uuid("ai_action_id").references(() => aiActionLogs.id, {
      onDelete: "set null",
    }),
    ...syncColumns,
  },
  (table) => ({
    userDateIdx: index("expenses_user_date_idx").on(
      table.userId,
      table.spentAt,
    ),
    userCurrencyIdx: index("expenses_user_currency_idx").on(
      table.userId,
      table.currency,
    ),
  }),
);

export const budgets = pgTable(
  "budgets",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    userId: userReference(),
    month: text("month").notNull(),
    amount: numeric("amount", { precision: 18, scale: 4 }).notNull(),
    currency: text("currency").notNull(),
    ...syncColumns,
  },
  (table) => ({
    userMonthIdx: index("budgets_user_month_idx").on(table.userId, table.month),
  }),
);

export const categoryBudgets = pgTable(
  "category_budgets",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    userId: userReference(),
    month: text("month").notNull(),
    categoryId: uuid("category_id").references(() => categories.id, {
      onDelete: "set null",
    }),
    amount: numeric("amount", { precision: 18, scale: 4 }).notNull(),
    currency: text("currency").notNull(),
    isArchived: boolean("is_archived").notNull().default(false),
    ...syncColumns,
  },
  (table) => ({
    userMonthCategoryIdx: index("category_budgets_user_month_category_idx").on(
      table.userId,
      table.month,
      table.categoryId,
    ),
  }),
);

export const savingGoals = pgTable(
  "saving_goals",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    userId: userReference(),
    name: text("name").notNull(),
    targetAmount: numeric("target_amount", {
      precision: 18,
      scale: 4,
    }).notNull(),
    currentAmount: numeric("current_amount", {
      precision: 18,
      scale: 4,
    })
      .notNull()
      .default("0"),
    currency: text("currency").notNull(),
    deadline: date("deadline"),
    isArchived: boolean("is_archived").notNull().default(false),
    ...syncColumns,
  },
  (table) => ({
    userIdIdx: index("saving_goals_user_id_idx").on(table.userId),
  }),
);

export const transfers = pgTable(
  "transfers",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    userId: userReference(),
    fromWalletId: uuid("from_wallet_id").references(() => walletAccounts.id, {
      onDelete: "set null",
    }),
    toWalletId: uuid("to_wallet_id").references(() => walletAccounts.id, {
      onDelete: "set null",
    }),
    amount: numeric("amount", { precision: 18, scale: 4 }).notNull(),
    currency: text("currency").notNull(),
    transferredAt: timestamp("transferred_at", {
      withTimezone: true,
    }).notNull(),
    note: text("note"),
    ...syncColumns,
  },
  (table) => ({
    userDateIdx: index("transfers_user_date_idx").on(
      table.userId,
      table.transferredAt,
    ),
  }),
);

export const exchangeRates = pgTable(
  "exchange_rates",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    baseCurrency: text("base_currency").notNull(),
    targetCurrency: text("target_currency").notNull(),
    rate: numeric("rate", { precision: 24, scale: 10 }).notNull(),
    rateDate: date("rate_date").notNull(),
    provider: text("provider").notNull(),
    fetchedAt: timestamp("fetched_at", { withTimezone: true })
      .notNull()
      .defaultNow(),
  },
  (table) => ({
    rateUnique: uniqueIndex("exchange_rates_base_target_date_unique").on(
      table.baseCurrency,
      table.targetCurrency,
      table.rateDate,
    ),
  }),
);

export const syncChanges = pgTable(
  "sync_changes",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    userId: userReference(),
    entityType: text("entity_type").notNull(),
    entityId: text("entity_id").notNull(),
    clientChangeId: text("client_change_id"),
    operation: text("operation").notNull(),
    data: jsonb("data").$type<Record<string, unknown>>().notNull().default({}),
    clientUpdatedAt: timestamp("client_updated_at", { withTimezone: true }),
    baseRevision: integer("base_revision"),
    serverRevision: serial("server_revision").notNull(),
    changedAt: timestamp("changed_at", { withTimezone: true })
      .notNull()
      .defaultNow(),
    changedByDeviceId: text("changed_by_device_id"),
  },
  (table) => ({
    userRevisionIdx: index("sync_changes_user_revision_idx").on(
      table.userId,
      table.serverRevision,
    ),
    userEntityIdx: index("sync_changes_user_entity_idx").on(
      table.userId,
      table.entityType,
      table.entityId,
    ),
    entityIdx: index("sync_changes_entity_idx").on(
      table.entityType,
      table.entityId,
    ),
    clientChangeUnique: uniqueIndex("sync_changes_user_client_change_unique")
      .on(table.userId, table.changedByDeviceId, table.clientChangeId),
  }),
);
