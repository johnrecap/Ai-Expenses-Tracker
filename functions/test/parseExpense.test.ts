import test from "node:test";
import assert from "node:assert/strict";
import { handleParseExpense } from "../src/ai/parseExpense.js";
import { AiGatewayError, AiProvider } from "../src/ai/providerTypes.js";

const provider: AiProvider = {
  async parse() {
    return {
      structuredJson: {
        intent: "add_expense",
        amount: 250,
        category: "Food",
        date: "2026-05-15",
        paymentMethod: "Cash",
        currency: "EGP",
        description: "Food",
        confidence: 0.92,
        needsConfirmation: true,
      },
    };
  },
};

const validBody = {
  input: "spent 250 on food",
  now: "2026-05-16T12:00:00+03:00",
};

test("unauthenticated request returns normalized error", async () => {
  const result = await handleParseExpense(validBody, undefined, {
    provider,
    quotaService: { consume: async () => undefined },
  });

  assert.equal(result.status, 401);
  assert.equal(result.body.ok, false);
  if (!result.body.ok) assert.equal(result.body.errorCode, "unauthenticated");
});

test("invalid request returns invalid_request", async () => {
  const result = await handleParseExpense({}, "Bearer token", {
    provider,
    tokenVerifier: async () => ({ uid: "user-1" }),
    quotaService: { consume: async () => undefined },
  });

  assert.equal(result.status, 400);
  assert.equal(result.body.ok, false);
  if (!result.body.ok) assert.equal(result.body.errorCode, "invalid_request");
});

test("quota failure returns before provider call", async () => {
  let providerCalled = false;
  const result = await handleParseExpense(validBody, "Bearer token", {
    provider: {
      async parse() {
        providerCalled = true;
        return provider.parse(validBody);
      },
    },
    tokenVerifier: async () => ({ uid: "user-1" }),
    quotaService: {
      async consume() {
        throw new AiGatewayError("quota_exceeded", "Daily limit reached.", 429);
      },
    },
  });

  assert.equal(providerCalled, false);
  assert.equal(result.status, 429);
  assert.equal(result.body.ok, false);
  if (!result.body.ok) assert.equal(result.body.errorCode, "quota_exceeded");
});

test("successful request returns parser-compatible structuredJson", async () => {
  const result = await handleParseExpense(validBody, "Bearer token", {
    provider,
    tokenVerifier: async () => ({ uid: "user-1" }),
    quotaService: { consume: async () => undefined },
  });

  assert.equal(result.status, 200);
  assert.equal(result.body.ok, true);
  if (result.body.ok) {
    assert.equal("intent" in result.body.structuredJson, true);
    if ("intent" in result.body.structuredJson) {
      assert.equal(result.body.structuredJson.intent, "add_expense");
    }
    assert.equal(result.body.structuredJson.needsConfirmation, true);
  }
});
