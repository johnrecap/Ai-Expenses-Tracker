import { and, asc, eq, gt } from "drizzle-orm";

import { db, type Database } from "../db/client.js";
import { syncChanges } from "../db/schema/index.js";
import { ensureBackendUser } from "../users/userService.js";

export type SyncEntityType =
  | "settings"
  | "expense"
  | "category"
  | "categoryAlias"
  | "budget"
  | "categoryBudget"
  | "recurringExpense"
  | "savingGoal"
  | "walletAccount"
  | "transfer"
  | "aiActionLog";

export type SyncOperation = "upsert" | "delete";

export interface SyncEnvelope {
  entityType: SyncEntityType;
  entityId: string;
  clientChangeId?: string;
  operation: SyncOperation;
  data: Record<string, unknown>;
  clientUpdatedAt: string;
  baseRevision?: number | null;
  serverRevision?: number;
}

export interface SyncPushRequest {
  deviceId: string;
  changes: SyncEnvelope[];
}

export interface SyncPushResult {
  accepted: Array<{
    entityType: SyncEntityType;
    entityId: string;
    clientChangeId?: string;
    serverRevision: number;
  }>;
  rejected: Array<{
    entityType: SyncEntityType;
    entityId: string;
    clientChangeId?: string;
    code: string;
    message: string;
  }>;
  nextCursor: string;
}

export interface SyncPullResult {
  changes: SyncEnvelope[];
  nextCursor: string;
  hasMore: boolean;
}

export interface SyncService {
  push(userId: string, request: SyncPushRequest): Promise<SyncPushResult>;
  pull(
    userId: string,
    cursor?: string,
    limit?: number,
  ): Promise<SyncPullResult>;
}

interface StoredChange extends SyncEnvelope {
  userId: string;
  serverRevision: number;
  changedByDeviceId?: string | null;
}

export interface SyncChangeRepository {
  append(
    firebaseUid: string,
    deviceId: string,
    changes: SyncEnvelope[],
  ): Promise<StoredChange[]>;
  pull(
    firebaseUid: string,
    afterRevision: number,
    limit: number,
  ): Promise<StoredChange[]>;
}

export class DurableSyncService implements SyncService {
  constructor(private readonly repository: SyncChangeRepository) {}

  async push(
    userId: string,
    request: SyncPushRequest,
  ): Promise<SyncPushResult> {
    const accepted: SyncPushResult["accepted"] = [];
    const rejected: SyncPushResult["rejected"] = [];
    const validChanges: SyncEnvelope[] = [];

    for (const change of request.changes) {
      if (!change.entityId || !change.entityType) {
        rejected.push({
          entityType: change.entityType,
          entityId: change.entityId,
          clientChangeId: change.clientChangeId,
          code: "sync/invalid-change",
          message: "Sync change is missing entity identity.",
        });
        continue;
      }
      validChanges.push(change);
    }

    const storedChanges =
      validChanges.length === 0
        ? []
        : await this.repository.append(userId, request.deviceId, validChanges);

    for (const stored of storedChanges) {
      accepted.push({
        entityType: stored.entityType,
        entityId: stored.entityId,
        clientChangeId: stored.clientChangeId,
        serverRevision: stored.serverRevision,
      });
    }

    const nextCursor =
      accepted.length === 0
        ? "0"
        : String(accepted[accepted.length - 1].serverRevision);

    return {
      accepted,
      rejected,
      nextCursor,
    };
  }

  async pull(
    userId: string,
    cursor = "0",
    limit = 500,
  ): Promise<SyncPullResult> {
    const afterRevision = Number.parseInt(cursor, 10) || 0;
    const safeLimit = Math.min(Math.max(limit, 1), 1000);
    const matching = await this.repository.pull(
      userId,
      afterRevision,
      safeLimit + 1,
    );
    const page = matching.slice(0, safeLimit);
    const nextCursor =
      page.length === 0
        ? String(afterRevision)
        : String(page[page.length - 1].serverRevision);

    return {
      changes: page.map(
        ({ userId: _userId, changedByDeviceId: _deviceId, ...change }) =>
          change,
      ),
      nextCursor,
      hasMore: matching.length > safeLimit,
    };
  }
}

export class InMemorySyncChangeRepository implements SyncChangeRepository {
  private readonly changes: StoredChange[] = [];
  private revision = 0;

  async append(
    userId: string,
    deviceId: string,
    changes: SyncEnvelope[],
  ): Promise<StoredChange[]> {
    const storedChanges: StoredChange[] = [];
    for (const change of changes) {
      const existing = this.findExisting(userId, deviceId, change);
      if (existing) {
        storedChanges.push(existing);
        continue;
      }
      const serverRevision = ++this.revision;
      const stored = {
        ...change,
        userId,
        serverRevision,
        changedByDeviceId: deviceId,
      };
      this.changes.push(stored);
      storedChanges.push(stored);
    }
    return storedChanges;
  }

  async pull(
    userId: string,
    afterRevision: number,
    limit: number,
  ): Promise<StoredChange[]> {
    return this.changes
      .filter(
        (change) =>
          change.userId === userId && change.serverRevision > afterRevision,
      )
      .sort((a, b) => a.serverRevision - b.serverRevision)
      .slice(0, limit);
  }

  private findExisting(
    userId: string,
    deviceId: string,
    change: SyncEnvelope,
  ): StoredChange | undefined {
    if (!change.clientChangeId) return undefined;
    return this.changes.find(
      (stored) =>
        stored.userId === userId &&
        stored.changedByDeviceId === deviceId &&
        stored.clientChangeId === change.clientChangeId,
    );
  }
}

export class InMemorySyncService extends DurableSyncService {
  constructor(repository = new InMemorySyncChangeRepository()) {
    super(repository);
  }
}

export class PostgresSyncChangeRepository implements SyncChangeRepository {
  constructor(private readonly database: Database = db) {}

  async append(
    firebaseUid: string,
    deviceId: string,
    changes: SyncEnvelope[],
  ): Promise<StoredChange[]> {
    const backendUser = await ensureBackendUser({ firebaseUid });

    return this.database.transaction(async (tx) => {
      const stored: StoredChange[] = [];
      for (const change of changes) {
        if (change.clientChangeId) {
          const [existing] = await tx
            .select()
            .from(syncChanges)
            .where(
              and(
                eq(syncChanges.userId, backendUser.id),
                eq(syncChanges.changedByDeviceId, deviceId),
                eq(syncChanges.clientChangeId, change.clientChangeId),
              ),
            )
            .limit(1);
          if (existing) {
            stored.push(mapSyncChangeRow(firebaseUid, existing));
            continue;
          }
        }
        const [row] = await tx
          .insert(syncChanges)
          .values({
            userId: backendUser.id,
            entityType: change.entityType,
            entityId: change.entityId,
            clientChangeId: change.clientChangeId ?? null,
            operation: change.operation,
            data: change.data,
            clientUpdatedAt: new Date(change.clientUpdatedAt),
            baseRevision: change.baseRevision ?? null,
            changedByDeviceId: deviceId,
          })
          .returning();
        stored.push(mapSyncChangeRow(firebaseUid, row));
      }
      return stored;
    });
  }

  async pull(
    firebaseUid: string,
    afterRevision: number,
    limit: number,
  ): Promise<StoredChange[]> {
    const backendUser = await ensureBackendUser({ firebaseUid });
    const rows = await this.database
      .select()
      .from(syncChanges)
      .where(
        and(
          eq(syncChanges.userId, backendUser.id),
          gt(syncChanges.serverRevision, afterRevision),
        ),
      )
      .orderBy(asc(syncChanges.serverRevision))
      .limit(limit);

    return rows.map((row) => mapSyncChangeRow(firebaseUid, row));
  }
}

function mapSyncChangeRow(
  firebaseUid: string,
  row: typeof syncChanges.$inferSelect,
): StoredChange {
  return {
    userId: firebaseUid,
    entityType: row.entityType as SyncEntityType,
    entityId: row.entityId,
    operation: row.operation as SyncOperation,
    clientChangeId: row.clientChangeId ?? undefined,
    data: row.data,
    clientUpdatedAt: (
      row.clientUpdatedAt ??
      row.changedAt ??
      new Date()
    ).toISOString(),
    baseRevision: row.baseRevision,
    serverRevision: row.serverRevision,
    changedByDeviceId: row.changedByDeviceId,
  };
}

export const defaultSyncService = new DurableSyncService(
  new PostgresSyncChangeRepository(),
);
