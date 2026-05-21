import test from "node:test";
import assert from "node:assert/strict";
import { AiGatewayError } from "../src/ai/providerTypes.js";
import { InMemoryQuotaStore, QuotaService } from "../src/ai/quotaService.js";

test("allows requests under configured limits", async () => {
  const quota = new QuotaService(new InMemoryQuotaStore(), {
    dailyUserLimit: 2,
    dailyGlobalLimit: 2,
  });

  await quota.consume("user-1", "2026-05-16", "gemini", "gemini-2.5-flash");
});

test("rejects requests after user limit", async () => {
  const quota = new QuotaService(new InMemoryQuotaStore(), {
    dailyUserLimit: 1,
    dailyGlobalLimit: 10,
  });

  await quota.consume("user-1", "2026-05-16", "gemini", "gemini-2.5-flash");
  await assert.rejects(
    () => quota.consume("user-1", "2026-05-16", "gemini", "gemini-2.5-flash"),
    (error) => error instanceof AiGatewayError && error.code === "quota_exceeded",
  );
});

test("does not apply a project-wide limit unless configured", async () => {
  const quota = new QuotaService(new InMemoryQuotaStore(), {
    dailyUserLimit: 1,
  });

  await quota.consume("user-1", "2026-05-16", "gemini", "gemini-2.5-flash");
  await quota.consume("user-2", "2026-05-16", "gemini", "gemini-2.5-flash");
});

test("rejects after configured project-wide limit", async () => {
  const quota = new QuotaService(new InMemoryQuotaStore(), {
    dailyUserLimit: 10,
    dailyGlobalLimit: 1,
  });

  await quota.consume("user-1", "2026-05-16", "gemini", "gemini-2.5-flash");
  await assert.rejects(
    () => quota.consume("user-2", "2026-05-16", "gemini", "gemini-2.5-flash"),
    (error) => error instanceof AiGatewayError && error.code === "quota_exceeded",
  );
});

test("tracks request types independently and resets by date key", async () => {
  const quota = new QuotaService(new InMemoryQuotaStore(), {
    dailyUserLimit: 1,
    dailyGlobalLimit: 10,
    requestTypeLimits: {
      receipt_extraction: 1,
      financial_advice: 1,
    },
  });

  await quota.consume(
    "user-1",
    "2026-05-16",
    "gemini",
    "gemini-2.5-flash",
    "receipt_extraction",
  );
  await quota.consume(
    "user-1",
    "2026-05-16",
    "gemini",
    "gemini-2.5-flash",
    "financial_advice",
  );

  await assert.rejects(
    () =>
      quota.consume(
        "user-1",
        "2026-05-16",
        "gemini",
        "gemini-2.5-flash",
        "receipt_extraction",
      ),
    (error) => error instanceof AiGatewayError && error.code === "quota_exceeded",
  );

  await quota.consume(
    "user-1",
    "2026-05-17",
    "gemini",
    "gemini-2.5-flash",
    "receipt_extraction",
  );
});
