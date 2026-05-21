import { randomUUID } from "node:crypto";
import { requireUserId, TokenVerifier } from "../firebase/authGuard.js";
import { GeminiProvider } from "./geminiProvider.js";
import {
  AiFinancialAdviceRequestBody,
  AiGatewayError,
  AiGatewayResponse,
  AiProvider,
  AiQuotaStatus,
  AiRequestType,
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

export interface FinancialAdviceDependencies {
  provider?: AiProvider;
  quotaService?: QuotaConsumer;
  tokenVerifier?: TokenVerifier;
  now?: () => Date;
}

export async function handleFinancialAdvice(
  body: unknown,
  authorizationHeader: string | undefined,
  deps: FinancialAdviceDependencies = {},
): Promise<{ status: number; body: AiGatewayResponse }> {
  const requestId = randomUUID();
  const providerName = "gemini";
  const model = "gemini-2.5-flash";
  let uid: string | undefined;
  const dateKey = dateOnly(deps.now?.() ?? new Date());
  const quotaService = deps.quotaService ?? QuotaService.fromEnvironment();

  try {
    const request = validateAdviceRequestBody(body);
    uid = await requireUserId(authorizationHeader, deps.tokenVerifier);
    const quotaResult = await quotaService.consume(
      uid,
      dateKey,
      providerName,
      model,
      "financial_advice",
    );
    const quota = quotaResult ?? undefined;
    const provider = deps.provider ?? new GeminiProvider({ model });
    if (!provider.financialAdvice) {
      throw new AiGatewayError(
        "gateway_misconfigured",
        "Financial advice provider is not configured.",
        500,
      );
    }
    const result = await provider.financialAdvice(request);
    await logUsage(quotaService, {
      uid,
      requestType: "financial_advice",
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
            error instanceof Error ? error.message : "Financial advice AI failed.",
            500,
          );
    await logUsage(quotaService, {
      uid: uid ?? "unknown",
      requestType: "financial_advice",
      dateKey,
      status: gatewayError.code === "quota_exceeded" ? "quota_blocked" : "failure",
      provider: providerName,
      model,
      requestId,
      errorCode: gatewayError.code,
    });
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

export function validateAdviceRequestBody(
  body: unknown,
): AiFinancialAdviceRequestBody {
  if (!body || typeof body !== "object" || Array.isArray(body)) {
    throw new AiGatewayError("invalid_request", "Request body is required.", 400);
  }
  const candidate = body as Partial<AiFinancialAdviceRequestBody>;
  if (candidate.period !== "week" && candidate.period !== "month") {
    throw new AiGatewayError("invalid_request", "Supported period is required.", 400);
  }
  if (!candidate.now || Number.isNaN(Date.parse(candidate.now))) {
    throw new AiGatewayError("invalid_request", "Valid now value is required.", 400);
  }
  if (
    !candidate.summary ||
    typeof candidate.summary !== "object" ||
    Array.isArray(candidate.summary)
  ) {
    throw new AiGatewayError("invalid_request", "Spending summary is required.", 400);
  }
  return {
    period: candidate.period,
    now: candidate.now,
    locale: candidate.locale ?? "ar-EG",
    defaultCurrency: candidate.defaultCurrency ?? "EGP",
    clientRequestId: candidate.clientRequestId,
    summary: candidate.summary,
  };
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

function dateOnly(date: Date): string {
  return date.toISOString().slice(0, 10);
}
