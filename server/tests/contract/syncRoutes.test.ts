import Fastify from "fastify";
import { describe, expect, it } from "vitest";

import { createFirebaseAuthGuard } from "../../src/auth/firebaseAuth.js";
import { registerSyncRoutes } from "../../src/sync/syncRoutes.js";
import { InMemorySyncService } from "../../src/sync/syncService.js";

describe("sync routes", () => {
  it("accepts pushed changes and returns them from pull", async () => {
    const app = Fastify({ logger: false });
    registerSyncRoutes(app, {
      authGuard: createFirebaseAuthGuard(async () => ({ uid: "user-a" })),
      syncService: new InMemorySyncService(),
    });

    const push = await app.inject({
      method: "POST",
      url: "/v1/sync/push",
      headers: { authorization: "Bearer token" },
      payload: {
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
      },
    });

    expect(push.statusCode).toBe(200);
    expect(push.json().accepted).toHaveLength(1);

    const pull = await app.inject({
      method: "GET",
      url: "/v1/sync/pull?cursor=0",
      headers: { authorization: "Bearer token" },
    });

    expect(pull.statusCode).toBe(200);
    expect(pull.json().changes).toHaveLength(1);
    expect(pull.json().changes[0].entityId).toBe("expense-1");
  });

  it("does not return changes across Firebase users", async () => {
    const service = new InMemorySyncService();
    const appA = Fastify({ logger: false });
    registerSyncRoutes(appA, {
      authGuard: createFirebaseAuthGuard(async () => ({ uid: "user-a" })),
      syncService: service,
    });
    const appB = Fastify({ logger: false });
    registerSyncRoutes(appB, {
      authGuard: createFirebaseAuthGuard(async () => ({ uid: "user-b" })),
      syncService: service,
    });

    await appA.inject({
      method: "POST",
      url: "/v1/sync/push",
      headers: { authorization: "Bearer token" },
      payload: {
        deviceId: "device-a",
        changes: [
          {
            entityType: "expense",
            entityId: "expense-1",
            operation: "upsert",
            data: {},
            clientUpdatedAt: "2026-05-26T10:00:00.000Z",
          },
        ],
      },
    });

    const pull = await appB.inject({
      method: "GET",
      url: "/v1/sync/pull?cursor=0",
      headers: { authorization: "Bearer token" },
    });

    expect(pull.statusCode).toBe(200);
    expect(pull.json().changes).toEqual([]);
  });
});
