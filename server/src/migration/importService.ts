import type { MigrationRecord } from "./firestoreMappers.js";

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
