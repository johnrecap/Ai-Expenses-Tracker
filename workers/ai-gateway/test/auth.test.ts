import { describe, expect, test } from "vitest";
import { AiGatewayError } from "../src/ai/providerTypes";
import {
  readBearerToken,
  requireFirebaseUser,
  validateFirebasePayload,
} from "../src/auth/firebaseTokenVerifier";
import { validPayload } from "./helpers";

describe("Firebase token verification", () => {
  test("missing authorization header returns unauthenticated", () => {
    expect(() => readBearerToken(null)).toThrow(AiGatewayError);
    try {
      readBearerToken(null);
    } catch (error) {
      expect((error as AiGatewayError).code).toBe("unauthenticated");
    }
  });

  test("non-bearer header returns unauthenticated", () => {
    expect(() => readBearerToken("Basic token")).toThrow(AiGatewayError);
  });

  test("wrong issuer is rejected", () => {
    expect(() =>
      validateFirebasePayload(
        { ...validPayload(), iss: "https://example.test" },
        "test-project",
      ),
    ).toThrow(AiGatewayError);
  });

  test("wrong audience is rejected", () => {
    expect(() =>
      validateFirebasePayload({ ...validPayload(), aud: "other" }, "test-project"),
    ).toThrow(AiGatewayError);
  });

  test("expired token is rejected", () => {
    expect(() =>
      validateFirebasePayload(
        { ...validPayload(), exp: Math.floor(Date.now() / 1000) - 1 },
        "test-project",
      ),
    ).toThrow(AiGatewayError);
  });

  test("valid mocked token returns uid", async () => {
    const user = await requireFirebaseUser("Bearer token", "test-project", async () =>
      validPayload("user-2"),
    );
    expect(user.uid).toBe("user-2");
  });
});
