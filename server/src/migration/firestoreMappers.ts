import { createHash } from "node:crypto";

import type { SyncEntityType, SyncEnvelope } from "../sync/syncService.js";

export type FirestoreCollectionName =
  | "settings"
  | "expenses"
  | "categories"
  | "category_aliases"
  | "budgets"
  | "category_budgets"
  | "recurring_expenses"
  | "saving_goals"
  | "wallets"
  | "transfers"
  | "ai_action_logs";

export interface FirestoreDocumentFixture {
  collection: FirestoreCollectionName;
  id: string;
  path?: string;
  data: Record<string, unknown>;
}

export interface FirestoreUserExport {
  userId: string;
  documents: FirestoreDocumentFixture[];
}

export interface MigrationRecord {
  userId: string;
  entityType: SyncEntityType;
  entityId: string;
  operation: "upsert";
  data: Record<string, unknown>;
  sourcePath: string;
  fieldHash: string;
  clientUpdatedAt: string;
}

const collectionEntityTypes: Record<FirestoreCollectionName, SyncEntityType> = {
  settings: "settings",
  expenses: "expense",
  categories: "category",
  category_aliases: "categoryAlias",
  budgets: "budget",
  category_budgets: "categoryBudget",
  recurring_expenses: "recurringExpense",
  saving_goals: "savingGoal",
  wallets: "walletAccount",
  transfers: "transfer",
  ai_action_logs: "aiActionLog",
};

const identityFields: Partial<Record<FirestoreCollectionName, string>> = {
  expenses: "expenseId",
  categories: "categoryId",
  category_aliases: "aliasId",
  budgets: "budgetId",
  category_budgets: "categoryBudgetId",
  recurring_expenses: "recurringExpenseId",
  saving_goals: "goalId",
  wallets: "walletId",
  transfers: "transferId",
  ai_action_logs: "actionId",
};

export function mapFirestoreDocument(
  userId: string,
  document: FirestoreDocumentFixture,
): MigrationRecord {
  const entityType = collectionEntityTypes[document.collection];
  if (!entityType) {
    throw new Error(`Unsupported Firestore collection: ${document.collection}`);
  }

  const idField = identityFields[document.collection];
  const entityId =
    document.collection === "settings"
      ? userId
      : normalizeId(document.data[idField ?? ""], document.id);
  const sourcePath =
    document.path ?? `users/${userId}/${document.collection}/${document.id}`;
  const data = normalizeFirestoreData({
    ...document.data,
    ...(idField ? { [idField]: entityId } : {}),
    userId,
    legacyFirestorePath: sourcePath,
  });
  const clientUpdatedAt = dateString(data.updatedAt) ?? dateString(data.createdAt);

  return {
    userId,
    entityType,
    entityId,
    operation: "upsert",
    data,
    sourcePath,
    fieldHash: stableRecordHash(data),
    clientUpdatedAt: clientUpdatedAt ?? new Date(0).toISOString(),
  };
}

export function mapFirestoreUserExport(
  exportData: FirestoreUserExport,
): MigrationRecord[] {
  return exportData.documents.map((document) =>
    mapFirestoreDocument(exportData.userId, document),
  );
}

export function toSyncEnvelope(record: MigrationRecord): SyncEnvelope {
  return {
    entityType: record.entityType,
    entityId: record.entityId,
    operation: record.operation,
    data: record.data,
    clientUpdatedAt: record.clientUpdatedAt,
  };
}

export function stableRecordHash(value: unknown): string {
  return createHash("sha256").update(stableStringify(value)).digest("hex");
}

function normalizeId(value: unknown, fallback: string): string {
  return typeof value === "string" && value.trim().length > 0
    ? value.trim()
    : fallback;
}

function normalizeFirestoreData(
  data: Record<string, unknown>,
): Record<string, unknown> {
  return Object.fromEntries(
    Object.entries(data).map(([key, value]) => [key, normalizeValue(value)]),
  );
}

function normalizeValue(value: unknown): unknown {
  if (value instanceof Date) return value.toISOString();
  if (Array.isArray(value)) return value.map(normalizeValue);
  if (value && typeof value === "object") {
    if ("toDate" in value && typeof value.toDate === "function") {
      return value.toDate().toISOString();
    }
    return normalizeFirestoreData(value as Record<string, unknown>);
  }
  return value;
}

function dateString(value: unknown): string | null {
  if (typeof value !== "string") return null;
  const parsed = new Date(value);
  return Number.isNaN(parsed.getTime()) ? null : parsed.toISOString();
}

function stableStringify(value: unknown): string {
  if (Array.isArray(value)) {
    return `[${value.map(stableStringify).join(",")}]`;
  }
  if (value && typeof value === "object") {
    const entries = Object.entries(value as Record<string, unknown>).sort(
      ([a], [b]) => a.localeCompare(b),
    );
    return `{${entries
      .map(([key, entryValue]) => `${JSON.stringify(key)}:${stableStringify(entryValue)}`)
      .join(",")}}`;
  }
  return JSON.stringify(value);
}
