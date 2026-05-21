import { describe, expect, test } from "vitest";
import { AiGatewayError } from "../src/ai/providerTypes";
import {
  InMemoryUsageCounterStore,
  QuotaService,
} from "../src/quota/quotaService";
import { handleParseExpense } from "../src/handlers/parseExpense";
import {
  FakeProvider,
  jsonRequest,
  quotaService as handlerQuotaService,
  testEnv,
  validPayload,
} from "./helpers";

function service() {
  return new QuotaService(new InMemoryUsageCounterStore());
}

describe("QuotaService", () => {
  test("first parse request with limit 5 returns remaining 4", async () => {
    const quota = await service().consume({
      uid: "user-a",
      dateKey: "2026-05-16",
      requestType: "parse_text",
      provider: "gemini",
      model: "gemini-2.5-flash",
      userLimit: 5,
    });
    expect(quota.remaining).toBe(4);
  });

  test("5th parse request returns remaining 0 and 6th throws", async () => {
    const quota = service();
    let lastRemaining = -1;
    for (let i = 0; i < 5; i += 1) {
      lastRemaining = (
        await quota.consume({
          uid: "user-a",
          dateKey: "2026-05-16",
          requestType: "parse_text",
          provider: "gemini",
          model: "gemini-2.5-flash",
          userLimit: 5,
        })
      ).remaining;
    }
    expect(lastRemaining).toBe(0);
    await expect(
      quota.consume({
        uid: "user-a",
        dateKey: "2026-05-16",
        requestType: "parse_text",
        provider: "gemini",
        model: "gemini-2.5-flash",
        userLimit: 5,
      }),
    ).rejects.toMatchObject({ code: "quota_exceeded" } as AiGatewayError);
  });

  test("user B is unaffected by user A quota", async () => {
    const quota = service();
    await quota.consume({
      uid: "user-a",
      dateKey: "2026-05-16",
      requestType: "parse_text",
      provider: "gemini",
      model: "gemini-2.5-flash",
      userLimit: 1,
    });
    const userB = await quota.consume({
      uid: "user-b",
      dateKey: "2026-05-16",
      requestType: "parse_text",
      provider: "gemini",
      model: "gemini-2.5-flash",
      userLimit: 1,
    });
    expect(userB.used).toBe(1);
  });

  test("request type counters are independent", async () => {
    const quota = service();
    await quota.consume({
      uid: "user-a",
      dateKey: "2026-05-16",
      requestType: "parse_text",
      provider: "gemini",
      model: "gemini-2.5-flash",
      userLimit: 1,
    });
    const receipt = await quota.consume({
      uid: "user-a",
      dateKey: "2026-05-16",
      requestType: "receipt_extraction",
      provider: "gemini",
      model: "gemini-2.5-flash",
      userLimit: 3,
    });
    expect(receipt.remaining).toBe(2);
  });

  test("new UTC date resets quota", async () => {
    const quota = service();
    const base = {
      uid: "user-a",
      requestType: "financial_advice" as const,
      provider: "gemini",
      model: "gemini-2.5-flash",
      userLimit: 1,
    };
    await quota.consume({ ...base, dateKey: "2026-05-16" });
    const nextDay = await quota.consume({ ...base, dateKey: "2026-05-17" });
    expect(nextDay.used).toBe(1);
  });

  test("no global limit applies when absent", async () => {
    const quota = service();
    await quota.consume({
      uid: "user-a",
      dateKey: "2026-05-16",
      requestType: "parse_text",
      provider: "gemini",
      model: "gemini-2.5-flash",
      userLimit: 5,
    });
    const userB = await quota.consume({
      uid: "user-b",
      dateKey: "2026-05-16",
      requestType: "parse_text",
      provider: "gemini",
      model: "gemini-2.5-flash",
      userLimit: 5,
    });
    expect(userB.remaining).toBe(4);
  });

  test("optional global limit works only when explicitly provided", async () => {
    const quota = service();
    await quota.consume({
      uid: "user-a",
      dateKey: "2026-05-16",
      requestType: "parse_text",
      provider: "gemini",
      model: "gemini-2.5-flash",
      userLimit: 5,
      globalLimit: 1,
    });
    await expect(
      quota.consume({
        uid: "user-b",
        dateKey: "2026-05-16",
        requestType: "parse_text",
        provider: "gemini",
        model: "gemini-2.5-flash",
        userLimit: 5,
        globalLimit: 1,
      }),
    ).rejects.toMatchObject({ code: "quota_exceeded" } as AiGatewayError);
  });

  test("parse handler keeps quota per user end to end", async () => {
    const provider = new FakeProvider();
    const quota = handlerQuotaService();
    for (let i = 0; i < 5; i += 1) {
      const response = await handleParseExpense(
        jsonRequest("/aiParse", {
          input: `spent ${i}`,
          now: "2026-05-16T12:00:00.000Z",
        }),
        testEnv(),
        undefined,
        {
          provider,
          quotaService: quota,
          tokenVerifier: async () => validPayload("user-a"),
        },
      );
      expect(response.status).toBe(200);
    }
    const blocked = await handleParseExpense(
      jsonRequest("/aiParse", {
        input: "spent 6",
        now: "2026-05-16T12:00:00.000Z",
      }),
      testEnv(),
      undefined,
      {
        provider,
        quotaService: quota,
        tokenVerifier: async () => validPayload("user-a"),
      },
    );
    expect(blocked.status).toBe(429);

    const userB = await handleParseExpense(
      jsonRequest("/aiParse", {
        input: "spent 1",
        now: "2026-05-16T12:00:00.000Z",
      }),
      testEnv(),
      undefined,
      {
        provider,
        quotaService: quota,
        tokenVerifier: async () => validPayload("user-b"),
      },
    );
    expect(userB.status).toBe(200);
    expect(provider.parseCalls).toBe(6);
  });
});
