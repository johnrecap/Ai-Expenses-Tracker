import { buildExpensePrompt } from "./promptBuilder.js";
import {
  AiFinancialAdviceRequestBody,
  AiFinancialAdviceProviderResult,
  AiGatewayError,
  AiGatewayRequestBody,
  AiProviderUsage,
  AiProvider,
  AiProviderResult,
  AiReceiptProviderResult,
  AiReceiptRequestBody,
} from "./providerTypes.js";
import {
  geminiAdviceResponseSchema,
  geminiReceiptResponseSchema,
  geminiResponseSchema,
  parseAdviceResponse,
  parseReceiptResponse,
  parseStructuredResponse,
} from "./structuredSchema.js";

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
  constructor(
    private readonly options: {
      apiKey?: string;
      model?: string;
      timeoutMs?: number;
      fetchImpl?: FetchLike;
    } = {},
  ) {}

  get provider() {
    return "gemini";
  }

  get model() {
    return this.options.model ?? "gemini-2.5-flash";
  }

  async parse(request: AiGatewayRequestBody): Promise<AiProviderResult> {
    const result = await this.generateJson(
      [{ text: buildExpensePrompt(request) }],
      geminiResponseSchema,
      0.1,
    );
    return {
      structuredJson: parseStructuredResponse(result.text),
      usage: result.usage,
    };
  }

  async extractReceipt(
    request: AiReceiptRequestBody,
  ): Promise<AiReceiptProviderResult> {
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
  ): Promise<AiFinancialAdviceProviderResult> {
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
    const apiKey = this.options.apiKey ?? process.env.GEMINI_API_KEY;
    if (!apiKey) {
      throw new AiGatewayError(
        "gateway_misconfigured",
        "Gemini API key is not configured.",
        500,
      );
    }

    const controller = new AbortController();
    const timer = setTimeout(
      () => controller.abort(),
      this.options.timeoutMs ?? 10000,
    );

    try {
      const response = await (this.options.fetchImpl ?? fetch)(
        `https://generativelanguage.googleapis.com/v1beta/models/${this.model}:generateContent?key=${apiKey}`,
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
        throw mapProviderError(response.status, await response.text());
      }

      const decoded = (await response.json()) as Record<string, unknown>;
      const text = extractText(decoded);
      return {
        text,
        usage: {
          inputTokens: readNumber(decoded, "promptTokenCount"),
          outputTokens: readNumber(decoded, "candidatesTokenCount"),
        },
      };
    } catch (error) {
      if (error instanceof AiGatewayError) throw error;
      if (error instanceof Error && error.name === "AbortError") {
        throw new AiGatewayError(
          "provider_timeout",
          "Gemini request timed out.",
          504,
        );
      }
      throw new AiGatewayError(
        "provider_unavailable",
        error instanceof Error ? error.message : "Gemini provider failed.",
        502,
      );
    } finally {
      clearTimeout(timer);
    }
  }
}

function buildReceiptPrompt(request: AiReceiptRequestBody): string {
  const categories = (request.categories ?? [])
    .filter((category) => !category.isArchived)
    .map((category) => category.name)
    .filter((name): name is string => typeof name === "string" && name.length > 0)
    .join(", ");
  return [
    "Extract one expense from this receipt image.",
    "Return only JSON matching the schema.",
    "Use ISO date yyyy-MM-dd. If unsure, use null for the field and lower confidence.",
    `Today is ${request.now}. Locale is ${request.locale ?? "ar-EG"}.`,
    `Default currency is ${request.defaultCurrency ?? "EGP"}.`,
    categories ? `Known categories: ${categories}.` : "",
    "Set needsConfirmation to true. Never invent missing amount/date/category.",
  ].join("\n");
}

function buildAdvicePrompt(request: AiFinancialAdviceRequestBody): string {
  return [
    "You are a concise financial assistant for an expense tracker.",
    "Use only the provided summary as facts. Do not invent transactions.",
    "Return short practical advice in the user's locale.",
    `Period: ${request.period}. Today: ${request.now}. Locale: ${request.locale ?? "ar-EG"}.`,
    `Default currency: ${request.defaultCurrency ?? "EGP"}.`,
    `Spending summary JSON: ${JSON.stringify(request.summary)}`,
    "Return JSON matching the schema and keep advice under 60 words.",
  ].join("\n");
}

function mapProviderError(status: number, body: string): AiGatewayError {
  if (status === 429) {
    return new AiGatewayError("rate_limited", "Gemini rate limit reached.", 429);
  }
  if (status === 400 || status === 403) {
    return new AiGatewayError(
      "gateway_misconfigured",
      `Gemini request rejected: ${body}`,
      500,
    );
  }
  return new AiGatewayError(
    "provider_unavailable",
    `Gemini provider error ${status}.`,
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

function readNumber(decoded: Record<string, unknown>, key: string): number | undefined {
  const usage = decoded.usageMetadata as Record<string, unknown> | undefined;
  const value = usage?.[key];
  return typeof value === "number" ? value : undefined;
}
