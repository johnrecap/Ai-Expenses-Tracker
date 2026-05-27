import { and, desc, eq } from "drizzle-orm";

import { db, type Database } from "../db/client.js";
import { syncChanges } from "../db/schema/index.js";
import type { SyncEntityType } from "../sync/syncService.js";
import { ensureBackendUser } from "../users/userService.js";
import type { MigrationRecord } from "./firestoreMappers.js";
import { stableRecordHash } from "./firestoreMappers.js";

export interface MigrationImportResult {
  inserted: number;
  updated: number;
  skipped: number;
}

export interface MigrationTarget {
  getImportedRecord(
    userId: string,
    entityType: string,
    entityId: string,
  ): Promise<MigrationRecord | null>;
  upsertImportedRecord(record: MigrationRecord): Promise<"inserted" | "updated">;
}

export class InMemoryMigrationTarget implements MigrationTarget {
  private readonly records = new Map<string, MigrationRecord>();

  async getImportedRecord(
    userId: string,
    entityType: string,
    entityId: string,
  ): Promise<MigrationRecord | null> {
    return this.records.get(recordKey(userId, entityType, entityId)) ?? null;
  }

  async upsertImportedRecord(
    record: MigrationRecord,
  ): Promise<"inserted" | "updated"> {
    const key = recordKey(record.userId, record.entityType, record.entityId);
    const existed = this.records.has(key);
    this.records.set(key, record);
    return existed ? "updated" : "inserted";
  }

  allRecords(): MigrationRecord[] {
    return [...this.records.values()];
  }
}

export class PostgresSyncMigrationTarget implements MigrationTarget {
  constructor(private readonly database: Database = db) {}

  async getImportedRecord(
    firebaseUid: string,
    entityType: string,
    entityId: string,
  ): Promise<MigrationRecord | null> {
    const backendUser = await ensureBackendUser({ firebaseUid });
    const [row] = await this.database
      .select()
      .from(syncChanges)
      .where(
        and(
          eq(syncChanges.userId, backendUser.id),
          eq(syncChanges.entityType, entityType),
          eq(syncChanges.entityId, entityId),
        ),
      )
      .orderBy(desc(syncChanges.serverRevision))
      .limit(1);

    return row ? rowToMigrationRecord(firebaseUid, row) : null;
  }

  async upsertImportedRecord(
    record: MigrationRecord,
  ): Promise<"inserted" | "updated"> {
    const existing = await this.getImportedRecord(
      record.userId,
      record.entityType,
      record.entityId,
    );
    const backendUser = await ensureBackendUser({ firebaseUid: record.userId });

    await this.database.insert(syncChanges).values({
      userId: backendUser.id,
      entityType: record.entityType,
      entityId: record.entityId,
      operation: record.operation,
      data: record.data,
      clientUpdatedAt: new Date(record.clientUpdatedAt),
      changedByDeviceId: "firestore-backfill",
    });

    return existing ? "updated" : "inserted";
  }

  async allRecords(firebaseUid: string): Promise<MigrationRecord[]> {
    const backendUser = await ensureBackendUser({ firebaseUid });
    const rows = await this.database
      .select()
      .from(syncChanges)
      .where(eq(syncChanges.userId, backendUser.id))
      .orderBy(syncChanges.serverRevision);

    const latestByEntity = new Map<string, MigrationRecord>();
    for (const row of rows) {
      const record = rowToMigrationRecord(firebaseUid, row);
      latestByEntity.set(
        recordKey(record.userId, record.entityType, record.entityId),
        record,
      );
    }
    return [...latestByEntity.values()];
  }
}

export class MigrationImportService {
  constructor(private readonly target: MigrationTarget) {}

  async importRecords(records: MigrationRecord[]): Promise<MigrationImportResult> {
    const result: MigrationImportResult = { inserted: 0, updated: 0, skipped: 0 };

    for (const record of records) {
      const existing = await this.target.getImportedRecord(
        record.userId,
        record.entityType,
        record.entityId,
      );

      if (existing?.fieldHash === record.fieldHash) {
        result.skipped += 1;
        continue;
      }

      const write = await this.target.upsertImportedRecord(record);
      result[write] += 1;
    }

    return result;
  }
}

function recordKey(userId: string, entityType: string, entityId: string): string {
  return `${userId}:${entityType}:${entityId}`;
}

function rowToMigrationRecord(
  firebaseUid: string,
  row: typeof syncChanges.$inferSelect,
): MigrationRecord {
  const data = row.data ?? {};
  const sourcePath =
    typeof data.legacyFirestorePath === "string"
      ? data.legacyFirestorePath
      : `sync_changes/${row.id}`;
  return {
    userId: firebaseUid,
    entityType: row.entityType as SyncEntityType,
    entityId: row.entityId,
    operation: row.operation as "upsert",
    data,
    sourcePath,
    fieldHash: stableRecordHash(data),
    clientUpdatedAt: (
      row.clientUpdatedAt ??
      row.changedAt ??
      new Date(0)
    ).toISOString(),
  };
}
