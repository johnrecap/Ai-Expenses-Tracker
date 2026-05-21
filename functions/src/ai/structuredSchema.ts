import {
  AiFinancialAdviceStructuredResponse,
  AiGatewayError,
  AiReceiptStructuredResponse,
  AiStructuredResponse,
} from "./providerTypes.js";

export const supportedIntents = [
  "add_expense",
  "update_expense",
  "delete_expense",
  "search_expenses",
  "summarize_expenses",
  "financial_advice",
] as const;

export const paymentMethods = [
  "Cash",
  "Visa",
  "Wallet",
  "Bank Transfer",
] as const;

export const geminiResponseSchema = {
  type: "OBJECT",
  properties: {
    intent: { type: "STRING", enum: [...supportedIntents] },
    amount: { type: "NUMBER" },
    category: { type: "STRING" },
    categoryId: { type: "STRING" },
    date: { type: "STRING" },
    paymentMethod: { type: "STRING", enum: [...paymentMethods] },
    currency: { type: "STRING" },
    description: { type: "STRING" },
    query: { type: "STRING" },
    period: { type: "STRING", enum: ["weekly", "monthly", "custom"] },
    startDate: { type: "STRING" },
    endDate: { type: "STRING" },
    periodText: { type: "STRING" },
    focusCategory: { type: "STRING" },
    tone: { type: "STRING" },
    confidence: { type: "NUMBER" },
    needsConfirmation: { type: "BOOLEAN" },
    clarifyingQuestion: { type: "STRING" },
  },
  required: ["intent", "confidence", "needsConfirmation"],
};

export const geminiReceiptResponseSchema = {
  type: "OBJECT",
  properties: {
    intent: { type: "STRING", enum: ["add_expense"] },
    amount: { type: "NUMBER" },
    date: { type: "STRING" },
    merchant: { type: "STRING" },
    category: { type: "STRING" },
    categoryId: { type: "STRING" },
    currency: { type: "STRING" },
    description: { type: "STRING" },
    rawText: { type: "STRING" },
    confidence: { type: "NUMBER" },
    needsConfirmation: { type: "BOOLEAN" },
  },
  required: ["intent", "confidence", "needsConfirmation"],
};

export const geminiAdviceResponseSchema = {
  type: "OBJECT",
  properties: {
    period: { type: "STRING", enum: ["week", "month"] },
    groundedSummary: { type: "STRING" },
    advice: { type: "STRING" },
    categoryDrivers: {
      type: "ARRAY",
      items: {
        type: "OBJECT",
        properties: {
          category: { type: "STRING" },
          amount: { type: "NUMBER" },
          currency: { type: "STRING" },
          note: { type: "STRING" },
        },
        required: ["category", "amount"],
      },
    },
    qualityNote: { type: "STRING" },
    confidence: { type: "NUMBER" },
    needsConfirmation: { type: "BOOLEAN" },
  },
  required: [
    "period",
    "groundedSummary",
    "advice",
    "categoryDrivers",
    "confidence",
    "needsConfirmation",
  ],
};

export function parseStructuredResponse(value: unknown): AiStructuredResponse {
  const object = typeof value === "string" ? parseJsonObject(value) : value;
  if (!object || typeof object !== "object" || Array.isArray(object)) {
    throw new AiGatewayError(
      "invalid_provider_output",
      "Provider output must be one JSON object.",
      502,
    );
  }

  const candidate = object as Record<string, unknown>;
  if (!supportedIntents.includes(candidate.intent as never)) {
    throw new AiGatewayError(
      "invalid_provider_output",
      "Provider output contains unsupported intent.",
      502,
    );
  }
  if (typeof candidate.confidence !== "number") {
    throw new AiGatewayError(
      "invalid_provider_output",
      "Provider output is missing numeric confidence.",
      502,
    );
  }

  return {
    ...candidate,
    intent: candidate.intent as string,
    confidence: candidate.confidence,
    needsConfirmation: true,
  } as AiStructuredResponse;
}

export function parseReceiptResponse(value: unknown): AiReceiptStructuredResponse {
  const candidate = parseProviderObject(value);
  if (candidate.intent !== "add_expense") {
    throw new AiGatewayError(
      "invalid_provider_output",
      "Receipt output must use add_expense intent.",
      502,
    );
  }
  if (typeof candidate.confidence !== "number") {
    throw new AiGatewayError(
      "invalid_provider_output",
      "Receipt output is missing numeric confidence.",
      502,
    );
  }
  return {
    ...candidate,
    intent: "add_expense",
    confidence: candidate.confidence,
    needsConfirmation: true,
  } as AiReceiptStructuredResponse;
}

export function parseAdviceResponse(
  value: unknown,
): AiFinancialAdviceStructuredResponse {
  const candidate = parseProviderObject(value);
  if (candidate.period !== "week" && candidate.period !== "month") {
    throw new AiGatewayError(
      "invalid_provider_output",
      "Advice output must include a supported period.",
      502,
    );
  }
  if (typeof candidate.advice !== "string" || candidate.advice.trim() === "") {
    throw new AiGatewayError(
      "invalid_provider_output",
      "Advice output is missing advice text.",
      502,
    );
  }
  if (typeof candidate.confidence !== "number") {
    throw new AiGatewayError(
      "invalid_provider_output",
      "Advice output is missing numeric confidence.",
      502,
    );
  }
  return {
    ...candidate,
    period: candidate.period,
    groundedSummary:
      typeof candidate.groundedSummary === "string"
        ? candidate.groundedSummary
        : "",
    advice: candidate.advice,
    categoryDrivers: Array.isArray(candidate.categoryDrivers)
      ? candidate.categoryDrivers
      : [],
    confidence: candidate.confidence,
    needsConfirmation: true,
  } as AiFinancialAdviceStructuredResponse;
}

function parseProviderObject(value: unknown): Record<string, unknown> {
  const object = typeof value === "string" ? parseJsonObject(value) : value;
  if (!object || typeof object !== "object" || Array.isArray(object)) {
    throw new AiGatewayError(
      "invalid_provider_output",
      "Provider output must be one JSON object.",
      502,
    );
  }
  return object as Record<string, unknown>;
}

function parseJsonObject(text: string): Record<string, unknown> {
  try {
    const decoded = JSON.parse(text);
    if (decoded && typeof decoded === "object" && !Array.isArray(decoded)) {
      return decoded as Record<string, unknown>;
    }
  } catch {
    throw new AiGatewayError(
      "invalid_provider_output",
      "Provider output was not valid JSON.",
      502,
    );
  }
  throw new AiGatewayError(
    "invalid_provider_output",
    "Provider output was not a JSON object.",
    502,
  );
}
