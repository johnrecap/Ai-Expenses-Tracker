import { describe, expect, test } from "vitest";
import { validPayload } from "./helpers";
import { handleFinancialAdvice } from "../src/handlers/financialAdvice";
import { handleParseExpense } from "../src/handlers/parseExpense";
import { handleReceiptExtraction } from "../src/handlers/receiptExtraction";
import { InMemoryUsageLogService } from "../src/quota/usageLogService";
import worker from "../src/index";
import {
  FakeProvider,
  jsonRequest,
  quotaService,
  readJson,
  testEnv,
  validVerifier,
} from "./helpers";

describe("Worker router contract", () => {
  test("OPTIONS returns CORS headers", async () => {
    const response = await worker.fetch(
      new Request("https://gateway.test/aiParse", { method: "OPTIONS" }),
      testEnv(),
      {} as ExecutionContext,
    );
    expect(response.status).toBe(204);
    expect(response.headers.get("Access-Control-Allow-Headers")).toContain(
      "Authorization",
    );
  });

  test("unknown endpoint returns JSON 404", async () => {
    const response = await worker.fetch(
      new Request("https://gateway.test/nope", { method: "POST" }),
      testEnv(),
      {} as ExecutionContext,
    );
    const body = await readJson(response);
    expect(response.status).toBe(404);
    expect(body.ok).toBe(false);
    expect(body.errorCode).toBe("invalid_request");
  });

  test("all protected endpoints reject missing auth without provider calls", async () => {
    const provider = new FakeProvider();
    const env = testEnv();
    const quota = quotaService();
    const responses = await Promise.all([
      handleParseExpense(
        jsonRequest(
          "/aiParse",
          { input: "spent 50", now: "2026-05-16T12:00:00.000Z" },
          "",
        ),
        env,
        undefined,
        { provider, quotaService: quota, tokenVerifier: validVerifier },
      ),
      handleReceiptExtraction(
        jsonRequest(
          "/aiReceipt",
          {
            imageBase64: "a".repeat(40),
            mimeType: "image/png",
            now: "2026-05-16T12:00:00.000Z",
          },
          "",
        ),
        env,
        undefined,
        { provider, quotaService: quota, tokenVerifier: validVerifier },
      ),
      handleFinancialAdvice(
        jsonRequest(
          "/aiAdvice",
          {
            period: "month",
            now: "2026-05-16T12:00:00.000Z",
            summary: { total: 100 },
          },
          "",
        ),
        env,
        undefined,
        { provider, quotaService: quota, tokenVerifier: validVerifier },
      ),
    ]);

    for (const response of responses) {
      expect(response.status).toBe(401);
      expect((await readJson(response)).errorCode).toBe("unauthenticated");
    }
    expect(provider.parseCalls + provider.receiptCalls + provider.adviceCalls).toBe(0);
  });

  test("wrong-project token is rejected and raw token is not echoed", async () => {
    const provider = new FakeProvider();
    const rawToken = "raw-token-value";
    const response = await handleParseExpense(
      jsonRequest(
        "/aiParse",
        { input: "spent 50", now: "2026-05-16T12:00:00.000Z" },
        rawToken,
      ),
      testEnv(),
      undefined,
      {
        provider,
        quotaService: quotaService(),
        tokenVerifier: async () => ({
          ...validPayload(),
          aud: "wrong-project",
        }),
      },
    );
    const text = await response.text();
    expect(response.status).toBe(401);
    expect(text).not.toContain(rawToken);
    expect(provider.parseCalls).toBe(0);
  });

  test("secret values never appear in success or error responses", async () => {
    const secret = "test-secret-value";
    const provider = new FakeProvider();
    const success = await handleParseExpense(
      jsonRequest("/aiParse", {
        input: "spent 50",
        now: "2026-05-16T12:00:00.000Z",
      }),
      testEnv({ GEMINI_API_KEY: secret }),
      undefined,
      {
        provider,
        quotaService: quotaService(),
        tokenVerifier: validVerifier,
      },
    );
    expect(await success.text()).not.toContain(secret);

    const failed = await handleParseExpense(
      jsonRequest("/aiParse", {
        input: "spent 50",
        now: "2026-05-16T12:00:00.000Z",
      }),
      testEnv({ GEMINI_API_KEY: secret }),
      undefined,
      {
        provider: new FakeProvider({
          error: new Error(`provider URL contained ${secret}`),
        }),
        quotaService: quotaService(),
        tokenVerifier: validVerifier,
      },
    );
    expect(await failed.text()).not.toContain(secret);
  });

  test("usage logs do not contain raw authorization headers", async () => {
    const logs = new InMemoryUsageLogService();
    const response = await handleParseExpense(
      jsonRequest(
        "/aiParse",
        { input: "spent 50", now: "2026-05-16T12:00:00.000Z" },
        "sensitive-token",
      ),
      testEnv(),
      undefined,
      {
        provider: new FakeProvider(),
        quotaService: quotaService(),
        usageLogService: logs,
        tokenVerifier: validVerifier,
      },
    );
    expect(response.status).toBe(200);
    expect(JSON.stringify(logs.entries)).not.toContain("sensitive-token");
  });
});
