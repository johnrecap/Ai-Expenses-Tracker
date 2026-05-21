import { describe, expect, test } from "vitest";
import { AiGatewayError } from "../src/ai/providerTypes";
import { handleReceiptExtraction } from "../src/handlers/receiptExtraction";
import { InMemoryUsageLogService } from "../src/quota/usageLogService";
import {
  FakeProvider,
  jsonRequest,
  quotaService,
  readJson,
  testEnv,
  validVerifier,
} from "./helpers";

const imageBase64 = "a".repeat(40);

describe("/aiReceipt", () => {
  test("valid image request returns structured receipt", async () => {
    const provider = new FakeProvider();
    const response = await handleReceiptExtraction(
      jsonRequest("/aiReceipt", {
        imageBase64,
        mimeType: "image/jpeg",
        now: "2026-05-16T12:00:00.000Z",
      }),
      testEnv(),
      undefined,
      {
        provider,
        quotaService: quotaService(),
        tokenVerifier: validVerifier,
      },
    );
    const body = await readJson(response);
    expect(response.status).toBe(200);
    expect(body.structuredJson).toMatchObject({
      amount: 150,
      currency: "EGP",
      confidence: 0.85,
    });
    expect(provider.receiptCalls).toBe(1);
  });

  test("missing image returns invalid_request", async () => {
    const provider = new FakeProvider();
    const response = await handleReceiptExtraction(
      jsonRequest("/aiReceipt", {
        mimeType: "image/jpeg",
        now: "2026-05-16T12:00:00.000Z",
      }),
      testEnv(),
      undefined,
      { provider, quotaService: quotaService(), tokenVerifier: validVerifier },
    );
    const body = await readJson(response);
    expect(response.status).toBe(400);
    expect(body.errorCode).toBe("invalid_request");
    expect(provider.receiptCalls).toBe(0);
  });

  test("invalid MIME type returns invalid_request", async () => {
    const provider = new FakeProvider();
    const response = await handleReceiptExtraction(
      jsonRequest("/aiReceipt", {
        imageBase64,
        mimeType: "text/plain",
        now: "2026-05-16T12:00:00.000Z",
      }),
      testEnv(),
      undefined,
      { provider, quotaService: quotaService(), tokenVerifier: validVerifier },
    );
    const body = await readJson(response);
    expect(response.status).toBe(400);
    expect(body.errorCode).toBe("invalid_request");
    expect(provider.receiptCalls).toBe(0);
  });

  test("quota exhausted prevents provider call", async () => {
    const provider = new FakeProvider();
    const quota = quotaService();
    const deps = { provider, quotaService: quota, tokenVerifier: validVerifier };
    await handleReceiptExtraction(
      jsonRequest("/aiReceipt", {
        imageBase64,
        mimeType: "image/png",
        now: "2026-05-16T12:00:00.000Z",
      }),
      testEnv({ AI_RECEIPT_DAILY_USER_LIMIT: "1" }),
      undefined,
      deps,
    );
    const second = await handleReceiptExtraction(
      jsonRequest("/aiReceipt", {
        imageBase64,
        mimeType: "image/png",
        now: "2026-05-16T12:00:00.000Z",
      }),
      testEnv({ AI_RECEIPT_DAILY_USER_LIMIT: "1" }),
      undefined,
      deps,
    );
    const body = await readJson(second);
    expect(body.errorCode).toBe("quota_exceeded");
    expect(body.quota).toMatchObject({
      requestType: "receipt_extraction",
      allowed: false,
      limit: 1,
      used: 1,
      remaining: 0,
    });
    expect(provider.receiptCalls).toBe(1);
  });

  test("provider malformed output returns invalid_provider_output", async () => {
    const provider = new FakeProvider({
      error: new AiGatewayError("invalid_provider_output", "Bad output.", 502),
    });
    const response = await handleReceiptExtraction(
      jsonRequest("/aiReceipt", {
        imageBase64,
        mimeType: "image/png",
        now: "2026-05-16T12:00:00.000Z",
      }),
      testEnv(),
      undefined,
      { provider, quotaService: quotaService(), tokenVerifier: validVerifier },
    );
    expect((await readJson(response)).errorCode).toBe("invalid_provider_output");
  });

  test("raw image is not passed to usage logs", async () => {
    const logs = new InMemoryUsageLogService();
    const response = await handleReceiptExtraction(
      jsonRequest("/aiReceipt", {
        imageBase64,
        mimeType: "image/png",
        now: "2026-05-16T12:00:00.000Z",
      }),
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
    expect(JSON.stringify(logs.entries)).not.toContain(imageBase64);
  });
});
