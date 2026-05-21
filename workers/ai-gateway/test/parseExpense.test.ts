import { describe, expect, test } from "vitest";
import { AiGatewayError } from "../src/ai/providerTypes";
import { handleParseExpense } from "../src/handlers/parseExpense";
import { InMemoryUsageLogService } from "../src/quota/usageLogService";
import {
  FakeProvider,
  jsonRequest,
  quotaService,
  readJson,
  testEnv,
  validVerifier,
} from "./helpers";

describe("/aiParse", () => {
  test("successful request returns provider, model, requestId, quota, and structuredJson", async () => {
    const provider = new FakeProvider();
    const logs = new InMemoryUsageLogService();
    const response = await handleParseExpense(
      jsonRequest("/aiParse", {
        input: "صرفت 250 جنيه على أكل",
        now: "2026-05-16T12:00:00.000Z",
      }),
      testEnv(),
      undefined,
      {
        provider,
        quotaService: quotaService(),
        usageLogService: logs,
        tokenVerifier: validVerifier,
      },
    );
    const body = await readJson(response);
    expect(response.status).toBe(200);
    expect(body.ok).toBe(true);
    expect(body.provider).toBe("gemini");
    expect(body.model).toBe("gemini-2.5-flash");
    expect(body.requestId).toBeTruthy();
    expect(body.quota).toMatchObject({ remaining: 4 });
    expect(body.structuredJson).toMatchObject({ intent: "add_expense" });
    expect(provider.parseCalls).toBe(1);
    expect(logs.entries[0]?.status).toBe("success");
  });

  test("empty input returns invalid_request before provider call", async () => {
    const provider = new FakeProvider();
    const response = await handleParseExpense(
      jsonRequest("/aiParse", {
        input: " ",
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
    expect(response.status).toBe(400);
    expect(body.errorCode).toBe("invalid_request");
    expect(provider.parseCalls).toBe(0);
  });

  test("missing token returns unauthenticated and does not call provider", async () => {
    const provider = new FakeProvider();
    const response = await handleParseExpense(
      jsonRequest(
        "/aiParse",
        {
          input: "spent 250",
          now: "2026-05-16T12:00:00.000Z",
        },
        "",
      ),
      testEnv(),
      undefined,
      {
        provider,
        quotaService: quotaService(),
        tokenVerifier: validVerifier,
      },
    );
    const body = await readJson(response);
    expect(response.status).toBe(401);
    expect(body.errorCode).toBe("unauthenticated");
    expect(provider.parseCalls).toBe(0);
  });

  test("quota exhausted returns quota_exceeded and does not call provider", async () => {
    const provider = new FakeProvider();
    const quota = quotaService();
    const deps = {
      provider,
      quotaService: quota,
      tokenVerifier: validVerifier,
    };
    const first = await handleParseExpense(
      jsonRequest("/aiParse", {
        input: "spent 250",
        now: "2026-05-16T12:00:00.000Z",
      }),
      testEnv({ AI_PARSE_DAILY_USER_LIMIT: "1" }),
      undefined,
      deps,
    );
    expect(first.status).toBe(200);
    const second = await handleParseExpense(
      jsonRequest("/aiParse", {
        input: "spent 300",
        now: "2026-05-16T12:00:00.000Z",
      }),
      testEnv({ AI_PARSE_DAILY_USER_LIMIT: "1" }),
      undefined,
      deps,
    );
    const body = await readJson(second);
    expect(second.status).toBe(429);
    expect(body.errorCode).toBe("quota_exceeded");
    expect(body.quota).toMatchObject({
      requestType: "parse_text",
      allowed: false,
      limit: 1,
      used: 1,
      remaining: 0,
    });
    expect(provider.parseCalls).toBe(1);
  });

  test("provider malformed output becomes invalid_provider_output", async () => {
    const provider = new FakeProvider({
      error: new AiGatewayError(
        "invalid_provider_output",
        "Provider output must be one JSON object.",
        502,
      ),
    });
    const response = await handleParseExpense(
      jsonRequest("/aiParse", {
        input: "spent 250",
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
    expect(response.status).toBe(502);
    expect(body.errorCode).toBe("invalid_provider_output");
  });
});
