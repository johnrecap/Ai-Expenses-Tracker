import test from "node:test";
import assert from "node:assert/strict";
import { handleReceiptExtraction } from "../src/ai/receiptExtraction.js";
import { AiGatewayError, AiProvider } from "../src/ai/providerTypes.js";

const validBody = {
  imageBase64: Buffer.from("fake receipt image bytes").toString("base64"),
  mimeType: "image/jpeg",
  now: "2026-05-16T12:00:00+03:00",
};

test("receipt request uses receipt quota before provider call", async () => {
  let providerCalled = false;
  let requestType = "";
  const provider: AiProvider = {
    async parse() {
      throw new Error("unused");
    },
    async extractReceipt() {
      providerCalled = true;
      return {
        structuredJson: {
          intent: "add_expense",
          amount: 120,
          date: "2026-05-16",
          merchant: "Market",
          category: "Food",
          currency: "EGP",
          confidence: 0.9,
          needsConfirmation: true,
        },
      };
    },
  };

  const result = await handleReceiptExtraction(validBody, "Bearer token", {
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
  assert.equal(requestType, "receipt_extraction");
});

test("receipt quota failure returns before provider call", async () => {
  let providerCalled = false;
  const result = await handleReceiptExtraction(validBody, "Bearer token", {
    provider: {
      async parse() {
        throw new Error("unused");
      },
      async extractReceipt() {
        providerCalled = true;
        throw new Error("must not be called");
      },
    },
    tokenVerifier: async () => ({ uid: "user-1" }),
    quotaService: {
      async consume() {
        throw new AiGatewayError("quota_exceeded", "Receipt limit reached.", 429);
      },
    },
  });

  assert.equal(providerCalled, false);
  assert.equal(result.status, 429);
  assert.equal(result.body.ok, false);
  if (!result.body.ok) assert.equal(result.body.errorCode, "quota_exceeded");
});
