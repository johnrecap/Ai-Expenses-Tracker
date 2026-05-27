import { describe, expect, it } from "vitest";

import { createFirebaseAuthGuard } from "../../src/auth/firebaseAuth.js";

describe("createFirebaseAuthGuard", () => {
  it("accepts a valid bearer token and attaches the Firebase user", async () => {
    const guard = createFirebaseAuthGuard(async (token) => ({
      uid: `uid-${token}`,
      email: "user@example.com",
    }));
    const request = {
      headers: { authorization: "Bearer token-123" },
    } as any;
    const reply = createReply();

    await guard(request, reply as any);

    expect(reply.statusCode).toBeUndefined();
    expect(request.firebaseUser).toEqual({
      uid: "uid-token-123",
      email: "user@example.com",
    });
  });

  it("rejects missing tokens", async () => {
    const guard = createFirebaseAuthGuard(async () => ({ uid: "uid" }));
    const request = { headers: {} } as any;
    const reply = createReply();

    await guard(request, reply as any);

    expect(reply.statusCode).toBe(401);
    expect(reply.payload.code).toBe("auth/missing-token");
  });

  it("rejects invalid tokens", async () => {
    const guard = createFirebaseAuthGuard(async () => {
      throw new Error("bad token");
    });
    const request = {
      headers: { authorization: "Bearer invalid" },
    } as any;
    const reply = createReply();

    await guard(request, reply as any);

    expect(reply.statusCode).toBe(401);
    expect(reply.payload.code).toBe("auth/invalid-token");
  });
});

function createReply() {
  return {
    statusCode: undefined as number | undefined,
    payload: undefined as any,
    code(statusCode: number) {
      this.statusCode = statusCode;
      return this;
    },
    send(payload: any) {
      this.payload = payload;
      return this;
    },
  };
}
