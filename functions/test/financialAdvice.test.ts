import test from "node:test";
import assert from "node:assert/strict";
import { handleFinancialAdvice } from "../src/ai/financialAdvice.js";
import { AiGatewayError, AiProvider } from "../src/ai/providerTypes.js";

const validBody = {
  period: "month",
  now: "2026-05-16T12:00:00+03:00",
  defaultCurrency: "EGP",
  summary: {
    total: 3000,
    currency: "EGP",
    topCategory: "Food",
  },
};

test("advice request uses advice quota before provider call", async () => {
  let providerCalled = false;
  let requestType = "";
  const provider: AiProvider = {
    async parse() {
      throw new Error("unused");
    },
    async financialAdvice() {
      providerCalled = true;
      return {
        structuredJson: {
          period: "month",
          groundedSummary: "You spent 3000 EGP this month.",
          advice: "Set a smaller food budget for the rest of the month.",
          categoryDrivers: [{ category: "Food", amount: 3000, currency: "EGP" }],
          confidence: 0.9,
          needsConfirmation: true,
        },
      };
    },
  };

  const result = await handleFinancialAdvice(validBody, "Bearer token", {
    provider,
    tokenVerifier: async () => ({ uid: "user-1" }),
    quotaService: {
      async consume(_uid, _dateKey, _provider, _model, type) {
        requestType = type ?? "";
      },
    },
  });

  assert.equal(result.status, 200);
  assert.equal(providerCalled, true);
  assert.equal(requestType, "financial_advice");
});

test("advice quota failure returns before provider call", async () => {
  let providerCalled = false;
  const result = await handleFinancialAdvice(validBody, "Bearer token", {
    provider: {
      async parse() {
        throw new Error("unused");
      },
      async financialAdvice() {
        providerCalled = true;
        throw new Error("must not be called");
      },
    },
    tokenVerifier: async () => ({ uid: "user-1" }),
    quotaService: {
      async consume() {
        throw new AiGatewayError("quota_exceeded", "Advice limit reached.", 429);
      },
    },
  });

  assert.equal(providerCalled, false);
  assert.equal(result.status, 429);
  assert.equal(result.body.ok, false);
  if (!result.body.ok) assert.equal(result.body.errorCode, "quota_exceeded");
});
