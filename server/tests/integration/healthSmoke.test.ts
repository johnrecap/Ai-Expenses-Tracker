import Fastify from "fastify";
import { describe, expect, it } from "vitest";

import { registerHealthRoutes } from "../../src/observability/healthRoutes.js";

describe("health smoke", () => {
  it("reports ok only when database and auth verifier are available", async () => {
    const app = Fastify({ logger: false });
    registerHealthRoutes(app, {
      checkDatabase: async () => true,
      checkAuthVerifier: async () => true,
    });

    const response = await app.inject({ method: "GET", url: "/health" });

    expect(response.statusCode).toBe(200);
    expect(response.json()).toMatchObject({
      status: "ok",
      database: "ok",
      authVerifier: "ok",
    });
  });

  it("reports degraded when a dependency is unavailable", async () => {
    const app = Fastify({ logger: false });
    registerHealthRoutes(app, {
      checkDatabase: async () => false,
      checkAuthVerifier: async () => true,
    });

    const response = await app.inject({ method: "GET", url: "/health" });

    expect(response.statusCode).toBe(200);
    expect(response.json()).toMatchObject({
      status: "degraded",
      database: "unavailable",
      authVerifier: "ok",
    });
  });
});
