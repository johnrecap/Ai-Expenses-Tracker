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
    serverRevision: number;
  }>;
  rejected: Array<{
    entityType: SyncEntityType;
    entityId: string;
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
}

export class InMemorySyncService implements SyncService {
  private readonly changes: StoredChange[] = [];
  private revision = 0;

  async push(
    userId: string,
    request: SyncPushRequest,
  ): Promise<SyncPushResult> {
    const accepted: SyncPushResult["accepted"] = [];
    const rejected: SyncPushResult["rejected"] = [];

    for (const change of request.changes) {
      if (!change.entityId || !change.entityType) {
        rejected.push({
          entityType: change.entityType,
          entityId: change.entityId,
          code: "sync/invalid-change",
          message: "Sync change is missing entity identity.",
        });
        continue;
      }

      const serverRevision = ++this.revision;
      this.changes.push({
        ...change,
        userId,
        serverRevision,
      });
      accepted.push({
        entityType: change.entityType,
        entityId: change.entityId,
        serverRevision,
      });
    }

    return {
      accepted,
      rejected,
      nextCursor: String(this.revision),
    };
  }

  async pull(
    userId: string,
    cursor = "0",
    limit = 500,
  ): Promise<SyncPullResult> {
    const afterRevision = Number.parseInt(cursor, 10) || 0;
    const safeLimit = Math.min(Math.max(limit, 1), 1000);
    const matching = this.changes
      .filter(
        (change) =>
          change.userId === userId && change.serverRevision > afterRevision,
      )
      .sort((a, b) => a.serverRevision - b.serverRevision);
    const page = matching.slice(0, safeLimit);
    const nextCursor =
      page.length === 0
        ? String(afterRevision)
        : String(page[page.length - 1].serverRevision);

    return {
      changes: page.map(({ userId: _userId, ...change }) => change),
      nextCursor,
      hasMore: matching.length > safeLimit,
    };
  }
}

export const defaultSyncService = new InMemorySyncService();
