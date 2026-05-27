import { describe, expect, it } from "vitest";

import { InMemorySyncService } from "../../src/sync/syncService.js";

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
});
