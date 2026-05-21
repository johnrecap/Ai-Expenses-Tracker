import { randomUUID } from "node:crypto";
import { requireUserId, TokenVerifier } from "../firebase/authGuard.js";
import { GeminiProvider } from "./geminiProvider.js";
import {
  AiGatewayError,
  AiGatewayRequestBody,
  AiGatewayResponse,
  AiQuotaStatus,
  AiRequestType,
  AiProvider,
} from "./providerTypes.js";
import { QuotaService } from "./quotaService.js";

type QuotaConsumer = {
  consume(
    uid: string,
    dateKey: string,
    provider: string,
    model: string,
    requestType?: AiRequestType,
  ): Promise<AiQuotaStatus | void>;
  logUsage?(entry: Parameters<QuotaService["logUsage"]>[0]): Promise<void>;
};

export interface ParseExpenseDependencies {
  provider?: AiProvider;
  quotaService?: QuotaConsumer;
  tokenVerifier?: TokenVerifier;
  now?: () => Date;
}

export async function handleParseExpense(
  body: unknown,
  authorizationHeader: string | undefined,
  deps: ParseExpenseDependencies = {},
): Promise<{ status: number; body: AiGatewayResponse }> {
  const requestId = randomUUID();
  const providerName = "gemini";
  const model = "gemini-2.5-flash";

  try {
    const request = validateRequestBody(body);
    const uid = await requireUserId(authorizationHeader, deps.tokenVerifier);
    const dateKey = dateOnly(deps.now?.() ?? new Date());
    const quotaService = deps.quotaService ?? QuotaService.fromEnvironment();
    const quotaResult = await quotaService.consume(
      uid,
      dateKey,
      providerName,
      model,
      "parse_text",
    );
    const quota = quotaResult ?? undefined;
    const provider = deps.provider ?? new GeminiProvider({ model });
    const result = await provider.parse(request);
    await logUsage(quotaService, {
      uid,
      requestType: "parse_text",
      dateKey,
      status: "success",
      provider: providerName,
      model,
      requestId,
      inputTokens: result.usage?.inputTokens,
      outputTokens: result.usage?.outputTokens,
    });
    return {
      status: 200,
      body: {
        ok: true,
        provider: providerName,
        model,
        requestId,
        usage: result.usage,
        quota,
        structuredJson: result.structuredJson,
      },
    };
  } catch (error) {
    const gatewayError =
      error instanceof AiGatewayError
        ? error
        : new AiGatewayError(
            "provider_unavailable",
            error instanceof Error ? error.message : "AI gateway failed.",
            500,
          );
    return {
      status: gatewayError.status,
      body: {
        ok: false,
        provider: providerName,
        model,
        requestId,
        errorCode: gatewayError.code,
        errorMessage: gatewayError.message,
      },
    };
  }
}

async function logUsage(
  quotaService: QuotaConsumer,
  entry: Parameters<QuotaService["logUsage"]>[0],
) {
  try {
    await quotaService.logUsage?.(entry);
  } catch {
    // Usage logs must not block AI responses.
  }
}

export function validateRequestBody(body: unknown): AiGatewayRequestBody {
  if (!body || typeof body !== "object" || Array.isArray(body)) {
    throw new AiGatewayError("invalid_request", "Request body is required.", 400);
  }
  const candidate = body as Partial<AiGatewayRequestBody>;
  if (!candidate.input || candidate.input.trim().length === 0) {
    throw new AiGatewayError("invalid_request", "Input is required.", 400);
  }
  if (!candidate.now || Number.isNaN(Date.parse(candidate.now))) {
    throw new AiGatewayError("invalid_request", "Valid now value is required.", 400);
  }
  return {
    input: candidate.input.trim(),
    now: candidate.now,
    locale: candidate.locale ?? "ar-EG",
    defaultCurrency: candidate.defaultCurrency ?? "EGP",
    clientRequestId: candidate.clientRequestId,
    categories: Array.isArray(candidate.categories) ? candidate.categories : [],
    recentExpenses: Array.isArray(candidate.recentExpenses)
      ? candidate.recentExpenses
      : [],
    budgetSummary: candidate.budgetSummary,
  };
}

function dateOnly(date: Date): string {
  return date.toISOString().slice(0, 10);
}
