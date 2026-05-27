import Fastify from "fastify";
import { describe, expect, it } from "vitest";

import { registerAccountRoutes } from "../../src/account/accountRoutes.js";
import { InMemoryAccountDeletionService } from "../../src/account/accountDeletionService.js";
import { createFirebaseAuthGuard } from "../../src/auth/firebaseAuth.js";

describe("account deletion route", () => {
  it("requires a recent auth confirmation before accepting deletion", async () => {
    const app = Fastify({ logger: false });
    registerAccountRoutes(app, {
      authGuard: createFirebaseAuthGuard(async () => ({ uid: "user-a" })),
      deletionService: new InMemoryAccountDeletionService(),
    });

    const response = await app.inject({
      method: "DELETE",
      url: "/v1/account",
      headers: { authorization: "Bearer token" },
    });

    expect(response.statusCode).toBe(409);
    expect(response.json().code).toBe("auth/recent-login-required");
  });

  it("accepts deletion when recent auth is confirmed by the app flow", async () => {
    const service = new InMemoryAccountDeletionService();
    const app = Fastify({ logger: false });
    registerAccountRoutes(app, {
      authGuard: createFirebaseAuthGuard(async () => ({ uid: "user-a" })),
      deletionService: service,
    });

    const response = await app.inject({
      method: "DELETE",
      url: "/v1/account",
      headers: {
        authorization: "Bearer token",
        "x-recent-auth-confirmed": "true",
      },
    });

    expect(response.statusCode).toBe(200);
    expect(response.json().status).toBe("accepted");
    expect(service.getRequest("user-a")).not.toBeNull();
  });
});
