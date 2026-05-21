import test from "node:test";
import assert from "node:assert/strict";
import { GeminiProvider } from "../src/ai/geminiProvider.js";
import { AiGatewayError } from "../src/ai/providerTypes.js";

const request = {
  input: "spent 250 on food yesterday cash",
  now: "2026-05-16T12:00:00+03:00",
};

test("normalizes a Gemini success response", async () => {
  const provider = new GeminiProvider({
    apiKey: "test-key",
    fetchImpl: async () => ({
      ok: true,
      status: 200,
      text: async () => "",
      json: async () => ({
        usageMetadata: {
          promptTokenCount: 12,
          candidatesTokenCount: 8,
        },
        candidates: [
          {
            content: {
              parts: [
                {
                  text: JSON.stringify({
                    intent: "add_expense",
                    amount: 250,
                    category: "Food",
                    date: "2026-05-15",
                    paymentMethod: "Cash",
                    currency: "EGP",
                    description: "Food",
                    confidence: 0.92,
                    needsConfirmation: true,
                  }),
                },
              ],
            },
          },
        ],
      }),
    }),
  });

  const result = await provider.parse(request);

  assert.equal(result.structuredJson.intent, "add_expense");
  assert.equal(result.structuredJson.needsConfirmation, true);
  assert.equal(result.usage?.inputTokens, 12);
});

test("rejects prose provider output", async () => {
  const provider = new GeminiProvider({
    apiKey: "test-key",
    fetchImpl: async () => ({
      ok: true,
      status: 200,
      text: async () => "",
      json: async () => ({
        candidates: [{ content: { parts: [{ text: "Sure, I can help." }] } }],
      }),
    }),
  });

  await assert.rejects(
    () => provider.parse(request),
    (error) =>
      error instanceof AiGatewayError &&
      error.code === "invalid_provider_output",
  );
});

test("maps Gemini 429 to rate_limited", async () => {
  const provider = new GeminiProvider({
    apiKey: "test-key",
    fetchImpl: async () => ({
      ok: false,
      status: 429,
      text: async () => "rate limit",
      json: async () => ({}),
    }),
  });

  await assert.rejects(
    () => provider.parse(request),
    (error) => error instanceof AiGatewayError && error.code === "rate_limited",
  );
});

test("maps aborted Gemini request to provider_timeout", async () => {
  const provider = new GeminiProvider({
    apiKey: "test-key",
    timeoutMs: 1,
    fetchImpl: async () => {
      const error = new Error("aborted");
      error.name = "AbortError";
      throw error;
    },
  });

  await assert.rejects(
    () => provider.parse(request),
    (error) =>
      error instanceof AiGatewayError && error.code === "provider_timeout",
  );
});
