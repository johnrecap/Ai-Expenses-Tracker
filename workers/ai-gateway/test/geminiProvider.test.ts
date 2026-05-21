import { describe, expect, test } from "vitest";
import { AiGatewayError } from "../src/ai/providerTypes";
import { FetchLike, GeminiProvider } from "../src/ai/geminiProvider";
import { GatewayConfig } from "../src/config";

function config(overrides: Partial<GatewayConfig> = {}): GatewayConfig {
  return {
    db: {} as D1Database,
    firebaseProjectId: "test-project",
    provider: "gemini",
    model: "gemini-2.5-flash",
    apiKey: "test-key",
    userLimits: {
      parse_text: 5,
      receipt_extraction: 3,
      financial_advice: 3,
    },
    globalLimits: {},
    providerTimeoutMs: 1000,
    ...overrides,
  };
}

function response(body: Record<string, unknown>, status = 200) {
  return {
    ok: status >= 200 && status < 300,
    status,
    async json() {
      return body;
    },
    async text() {
      return JSON.stringify(body);
    },
  };
}

const validGeminiBody = {
  candidates: [
    {
      content: {
        parts: [
          {
            text: JSON.stringify({
              intent: "add_expense",
              amount: 50,
              confidence: 0.9,
              needsConfirmation: true,
            }),
          },
        ],
      },
    },
  ],
  usageMetadata: {
    promptTokenCount: 11,
    candidatesTokenCount: 7,
  },
};

describe("GeminiProvider", () => {
  test("parses successful Gemini JSON and usage metadata", async () => {
    const fetchImpl: FetchLike = async () => response(validGeminiBody);
    const provider = new GeminiProvider(config(), fetchImpl);
    const result = await provider.parse({
      input: "spent 50",
      now: "2026-05-16T12:00:00.000Z",
      locale: "ar-EG",
      defaultCurrency: "EGP",
      categories: [],
      recentExpenses: [],
    });
    expect(result.structuredJson.intent).toBe("add_expense");
    expect(result.usage?.inputTokens).toBe(11);
    expect(result.usage?.outputTokens).toBe(7);
  });

  test("maps provider 429 to rate_limited", async () => {
    const fetchImpl: FetchLike = async () => response({ error: "quota" }, 429);
    const provider = new GeminiProvider(config(), fetchImpl);
    await expect(
      provider.parse({
        input: "spent 50",
        now: "2026-05-16T12:00:00.000Z",
        locale: "ar-EG",
        defaultCurrency: "EGP",
        categories: [],
        recentExpenses: [],
      }),
    ).rejects.toMatchObject({ code: "rate_limited" } as AiGatewayError);
  });

  test("maps provider auth rejection to gateway_misconfigured", async () => {
    const fetchImpl: FetchLike = async () => response({ error: "bad key" }, 400);
    const provider = new GeminiProvider(config(), fetchImpl);
    await expect(
      provider.parse({
        input: "spent 50",
        now: "2026-05-16T12:00:00.000Z",
        locale: "ar-EG",
        defaultCurrency: "EGP",
        categories: [],
        recentExpenses: [],
      }),
    ).rejects.toMatchObject({
      code: "gateway_misconfigured",
    } as AiGatewayError);
  });


  test("maps timeout to provider_timeout", async () => {
    const fetchImpl: FetchLike = (_input, init) =>
      new Promise((_resolve, reject) => {
        init.signal?.addEventListener("abort", () => {
          reject(new DOMException("Aborted", "AbortError"));
        });
      });
    const provider = new GeminiProvider(
      config({ providerTimeoutMs: 1 }),
      fetchImpl,
    );
    await expect(
      provider.parse({
        input: "spent 50",
        now: "2026-05-16T12:00:00.000Z",
        locale: "ar-EG",
        defaultCurrency: "EGP",
        categories: [],
        recentExpenses: [],
      }),
    ).rejects.toMatchObject({ code: "provider_timeout" } as AiGatewayError);
  });

  test("rejects prose or markdown provider output", async () => {
    const fetchImpl: FetchLike = async () =>
      response({
        candidates: [
          {
            content: {
              parts: [{ text: "```json\n{}\n```" }],
            },
          },
        ],
      });
    const provider = new GeminiProvider(config(), fetchImpl);
    await expect(
      provider.parse({
        input: "spent 50",
        now: "2026-05-16T12:00:00.000Z",
        locale: "ar-EG",
        defaultCurrency: "EGP",
        categories: [],
        recentExpenses: [],
      }),
    ).rejects.toMatchObject({
      code: "invalid_provider_output",
    } as AiGatewayError);
  });

  test("missing API key maps to gateway_misconfigured", () => {
    expect(
      () =>
        new GeminiProvider({
          db: {} as D1Database,
          firebaseProjectId: "test-project",
          provider: "gemini",
          model: "gemini-2.5-flash",
          userLimits: {
            parse_text: 5,
            receipt_extraction: 3,
            financial_advice: 3,
          },
          globalLimits: {},
          providerTimeoutMs: 1000,
        }),
    ).toThrow(AiGatewayError);
  });
});
