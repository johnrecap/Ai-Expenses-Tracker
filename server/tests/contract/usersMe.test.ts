import Fastify from "fastify";
import { describe, expect, it } from "vitest";

import { createFirebaseAuthGuard } from "../../src/auth/firebaseAuth.js";
import { registerUserRoutes } from "../../src/users/userRoutes.js";

describe("/v1/users/me", () => {
  it("returns the backend user for an authenticated Firebase identity", async () => {
    const app = Fastify({ logger: false });
    registerUserRoutes(app, {
      authGuard: createFirebaseAuthGuard(async () => ({
        uid: "firebase-uid",
        email: "user@example.com",
      })),
      ensureUser: async (input) => ({
        id: "backend-user-id",
        firebaseUid: input.firebaseUid,
        email: input.email ?? null,
        appDisplayName: "Local Name",
      }),
    });

    const response = await app.inject({
      method: "GET",
      url: "/v1/users/me",
      headers: { authorization: "Bearer token" },
    });

    expect(response.statusCode).toBe(200);
    expect(response.json()).toEqual({
      id: "backend-user-id",
      firebaseUid: "firebase-uid",
      email: "user@example.com",
      appDisplayName: "Local Name",
    });
  });

  it("updates app-local display name through the backend profile route", async () => {
    const app = Fastify({ logger: false });
    registerUserRoutes(app, {
      authGuard: createFirebaseAuthGuard(async () => ({
        uid: "firebase-uid",
      })),
      updateUserProfile: async (input) => ({
        id: "backend-user-id",
        firebaseUid: input.firebaseUid,
        email: null,
        appDisplayName: input.appDisplayName ?? null,
      }),
    });

    const response = await app.inject({
      method: "PATCH",
      url: "/v1/users/me",
      headers: { authorization: "Bearer token" },
      payload: { appDisplayName: "New Name" },
    });

    expect(response.statusCode).toBe(200);
    expect(response.json().appDisplayName).toBe("New Name");
  });
});
