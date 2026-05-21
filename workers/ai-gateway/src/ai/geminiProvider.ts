import { requireGeminiApiKey, GatewayConfig } from "../config";
import { buildAdvicePrompt, buildExpensePrompt, buildReceiptPrompt } from "./promptBuilder";
import {
  AiFinancialAdviceRequestBody,
  AiFinancialAdviceStructuredResponse,
  AiGatewayError,
  AiGatewayRequestBody,
  AiProvider,
  AiProviderResult,
  AiProviderUsage,
  AiReceiptRequestBody,
  AiReceiptStructuredResponse,
  AiStructuredResponse,
  isAiGatewayError,
} from "./providerTypes";
import {
  geminiAdviceResponseSchema,
  geminiReceiptResponseSchema,
  geminiResponseSchema,
  parseAdviceResponse,
  parseReceiptResponse,
  parseStructuredResponse,
} from "./structuredSchema";

export type FetchLike = (
  input: string,
  init: {
    method: string;
    headers: Record<string, string>;
    body: string;
    signal?: AbortSignal;
  },
) => Promise<{
  ok: boolean;
  status: number;
  json(): Promise<unknown>;
  text(): Promise<string>;
}>;

export class GeminiProvider implements AiProvider {
  readonly provider = "gemini";
  readonly model: string;

  private readonly apiKey: string;
  private readonly timeoutMs: number;
  private readonly fetchImpl: FetchLike;

  constructor(
    config: GatewayConfig,
    fetchImpl: FetchLike = (input, init) => fetch(input, init),
  ) {
    this.apiKey = requireGeminiApiKey(config);
    this.model = config.model;
    this.timeoutMs = config.providerTimeoutMs;
    this.fetchImpl = fetchImpl;
  }

  async parse(
    request: AiGatewayRequestBody,
  ): Promise<AiProviderResult<AiStructuredResponse>> {
    const result = await this.generateJson(
      [{ text: buildExpensePrompt(request) }],
      geminiResponseSchema,
      0.1,
    );
    return {
      structuredJson: parseStructuredResponse(result.text, {
        input: request.input,
        now: request.now,
        locale: request.locale,
        defaultCurrency: request.defaultCurrency,
        categories: request.categories,
      }),
      usage: result.usage,
    };
  }

  async extractReceipt(
    request: AiReceiptRequestBody,
  ): Promise<AiProviderResult<AiReceiptStructuredResponse>> {
    const result = await this.generateJson(
      [
        { text: buildReceiptPrompt(request) },
        {
          inlineData: {
            mimeType: request.mimeType,
            data: request.imageBase64,
          },
        },
      ],
      geminiReceiptResponseSchema,
      0.05,
    );
    return {
      structuredJson: parseReceiptResponse(result.text),
      usage: result.usage,
    };
  }

  async financialAdvice(
    request: AiFinancialAdviceRequestBody,
  ): Promise<AiProviderResult<AiFinancialAdviceStructuredResponse>> {
    const result = await this.generateJson(
      [{ text: buildAdvicePrompt(request) }],
      geminiAdviceResponseSchema,
      0.2,
    );
    return {
      structuredJson: parseAdviceResponse(result.text),
      usage: result.usage,
    };
  }

  private async generateJson(
    parts: Array<Record<string, unknown>>,
    responseSchema: Record<string, unknown>,
    temperature: number,
  ): Promise<{ text: string; usage?: AiProviderUsage }> {
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), this.timeoutMs);

    try {
      const response = await this.fetchImpl(
        `https://generativelanguage.googleapis.com/v1beta/models/${this.model}:generateContent?key=${encodeURIComponent(this.apiKey)}`,
        {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          signal: controller.signal,
          body: JSON.stringify({
            contents: [
              {
                role: "user",
                parts,
              },
            ],
            generationConfig: {
              responseMimeType: "application/json",
              responseSchema,
              temperature,
            },
          }),
        },
      );

      if (!response.ok) {
        console.warn(
          JSON.stringify({
            event: "gemini_provider_non_ok",
            status: response.status,
            model: this.model,
          }),
        );
        throw mapProviderError(response.status);
      }

      const decoded = (await response.json()) as Record<string, unknown>;
      return {
        text: extractText(decoded),
        usage: {
          inputTokens: readUsageNumber(decoded, "promptTokenCount"),
          outputTokens: readUsageNumber(decoded, "candidatesTokenCount"),
        },
      };
    } catch (error) {
      if (isAiGatewayError(error)) throw error;
      if (error instanceof Error && error.name === "AbortError") {
        throw new AiGatewayError(
          "provider_timeout",
          "Gemini request timed out.",
          504,
        );
      }
      console.error(
        JSON.stringify({
          event: "gemini_provider_failure",
          name: error instanceof Error ? error.name : typeof error,
          message: error instanceof Error ? error.message : "unknown",
          model: this.model,
        }),
      );
      throw new AiGatewayError(
        "provider_unavailable",
        "Gemini provider is unavailable.",
        502,
      );
    } finally {
      clearTimeout(timer);
    }
  }
}

function mapProviderError(status: number): AiGatewayError {
  if (status === 429) {
    return new AiGatewayError("rate_limited", "Gemini rate limit reached.", 429);
  }
  if (status === 400 || status === 401 || status === 403) {
    return new AiGatewayError(
      "gateway_misconfigured",
      "Gemini request was rejected. Check provider configuration.",
      500,
    );
  }
  return new AiGatewayError(
    "provider_unavailable",
    `Gemini provider returned status ${status}.`,
    502,
  );
}

function extractText(decoded: Record<string, unknown>): string {
  const candidates = decoded.candidates;
  if (!Array.isArray(candidates)) {
    throw new AiGatewayError(
      "invalid_provider_output",
      "Gemini response is missing candidates.",
      502,
    );
  }
  const first = candidates[0] as Record<string, unknown> | undefined;
  const content = first?.content as Record<string, unknown> | undefined;
  const parts = content?.parts;
  if (!Array.isArray(parts)) {
    throw new AiGatewayError(
      "invalid_provider_output",
      "Gemini response is missing content parts.",
      502,
    );
  }
  return parts
    .map((part) => (part as Record<string, unknown>).text)
    .filter((text): text is string => typeof text === "string")
    .join("");
}

function readUsageNumber(
  decoded: Record<string, unknown>,
  key: string,
): number | undefined {
  const usage = decoded.usageMetadata as Record<string, unknown> | undefined;
  const value = usage?.[key];
  return typeof value === "number" ? value : undefined;
}
