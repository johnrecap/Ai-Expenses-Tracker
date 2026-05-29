import { describe, expect, it } from "vitest";

import {
  DurableSyncService,
  InMemorySyncChangeRepository,
  InMemorySyncService,
} from "../../src/sync/syncService.js";

describe("sync conflict baseline", () => {
  it("assigns increasing revisions so clients can detect stale pushes later", async () => {
    const service = new InMemorySyncService();

    const first = await service.push("user-a", {
      deviceId: "device-a",
      changes: [
        {
          entityType: "expense",
          entityId: "expense-1",
          operation: "upsert",
          data: { amount: 100 },
          clientUpdatedAt: "2026-05-26T10:00:00.000Z",
        },
      ],
    });
    const second = await service.push("user-a", {
      deviceId: "device-b",
      changes: [
        {
          entityType: "expense",
          entityId: "expense-1",
          operation: "upsert",
          data: { amount: 200 },
          clientUpdatedAt: "2026-05-26T10:01:00.000Z",
          baseRevision: first.accepted[0].serverRevision,
        },
      ],
    });

    expect(second.accepted[0].serverRevision).toBeGreaterThan(
      first.accepted[0].serverRevision,
    );
  });

  it("keeps accepted changes available when the service is recreated with the same durable store", async () => {
    const repository = new InMemorySyncChangeRepository();
    const firstService = new DurableSyncService(repository);

    await firstService.push("user-a", {
      deviceId: "device-a",
      changes: [
        {
          entityType: "expense",
          entityId: "expense-1",
          operation: "upsert",
          data: { amount: 100, currency: "EGP" },
          clientUpdatedAt: "2026-05-26T10:00:00.000Z",
        },
      ],
    });

    const recreatedService = new DurableSyncService(repository);
    const pull = await recreatedService.pull("user-a", "0");

    expect(pull.changes).toHaveLength(1);
    expect(pull.changes[0]).toMatchObject({
      entityType: "expense",
      entityId: "expense-1",
      operation: "upsert",
      data: { amount: 100, currency: "EGP" },
    });
  });

  it("does not pull another user's changes from the shared durable store", async () => {
    const repository = new InMemorySyncChangeRepository();
    const service = new DurableSyncService(repository);

    await service.push("user-a", {
      deviceId: "device-a",
      changes: [
        {
          entityType: "category",
          entityId: "category-1",
          operation: "upsert",
          data: { name: "Food" },
          clientUpdatedAt: "2026-05-26T10:00:00.000Z",
        },
      ],
    });

    await expect(service.pull("user-b", "0")).resolves.toMatchObject({
      changes: [],
      hasMore: false,
      nextCursor: "0",
    });
  });

  it("stores delete operations as pullable tombstones", async () => {
    const service = new DurableSyncService(new InMemorySyncChangeRepository());

    const push = await service.push("user-a", {
      deviceId: "device-a",
      changes: [
        {
          entityType: "expense",
          entityId: "expense-1",
          operation: "delete",
          data: { deletedAt: "2026-05-26T10:02:00.000Z" },
          clientUpdatedAt: "2026-05-26T10:02:00.000Z",
          baseRevision: 7,
        },
      ],
    });
    const pull = await service.pull("user-a", "0");

    expect(push.accepted[0].serverRevision).toBeGreaterThan(0);
    expect(pull.changes[0]).toMatchObject({
      entityType: "expense",
      entityId: "expense-1",
      operation: "delete",
      baseRevision: 7,
      data: { deletedAt: "2026-05-26T10:02:00.000Z" },
    });
  });

  it("treats repeated client change ids from the same device as idempotent", async () => {
    const service = new DurableSyncService(new InMemorySyncChangeRepository());
    const change = {
      entityType: "expense" as const,
      entityId: "expense-1",
      clientChangeId: "change-1",
      operation: "upsert" as const,
      data: { amount: 100, currency: "EGP" },
      clientUpdatedAt: "2026-05-26T10:00:00.000Z",
    };

    const first = await service.push("user-a", {
      deviceId: "device-a",
      changes: [change],
    });
    const retry = await service.push("user-a", {
      deviceId: "device-a",
      changes: [change],
    });
    const pull = await service.pull("user-a", "0");

    expect(retry.accepted[0].serverRevision).toBe(
      first.accepted[0].serverRevision,
    );
    expect(retry.accepted[0].clientChangeId).toBe("change-1");
    expect(pull.changes).toHaveLength(1);
  });
});
