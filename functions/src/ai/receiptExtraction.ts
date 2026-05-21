import { randomUUID } from "node:crypto";
import { requireUserId, TokenVerifier } from "../firebase/authGuard.js";
import { GeminiProvider } from "./geminiProvider.js";
import {
  AiGatewayError,
  AiGatewayResponse,
  AiProvider,
  AiQuotaStatus,
  AiRequestType,
  AiReceiptRequestBody,
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

export interface ReceiptExtractionDependencies {
  provider?: AiProvider;
  quotaService?: QuotaConsumer;
  tokenVerifier?: TokenVerifier;
  now?: () => Date;
}

export async function handleReceiptExtraction(
  body: unknown,
  authorizationHeader: string | undefined,
  deps: ReceiptExtractionDependencies = {},
): Promise<{ status: number; body: AiGatewayResponse }> {
  const requestId = randomUUID();
  const providerName = "gemini";
  const model = "gemini-2.5-flash";
  let uid: string | undefined;
  const dateKey = dateOnly(deps.now?.() ?? new Date());
  const quotaService = deps.quotaService ?? QuotaService.fromEnvironment();

  try {
    const request = validateReceiptRequestBody(body);
    uid = await requireUserId(authorizationHeader, deps.tokenVerifier);
    const quotaResult = await quotaService.consume(
      uid,
      dateKey,
      providerName,
      model,
      "receipt_extraction",
    );
    const quota = quotaResult ?? undefined;
    const provider = deps.provider ?? new GeminiProvider({ model });
    if (!provider.extractReceipt) {
      throw new AiGatewayError(
        "gateway_misconfigured",
        "Receipt extraction provider is not configured.",
        500,
      );
    }
    const result = await provider.extractReceipt(request);
    await logUsage(quotaService, {
      uid,
      requestType: "receipt_extraction",
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
            error instanceof Error ? error.message : "Receipt AI failed.",
            500,
          );
    await logUsage(quotaService, {
      uid: uid ?? "unknown",
      requestType: "receipt_extraction",
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

export function validateReceiptRequestBody(body: unknown): AiReceiptRequestBody {
  if (!body || typeof body !== "object" || Array.isArray(body)) {
    throw new AiGatewayError("invalid_request", "Request body is required.", 400);
  }
  const candidate = body as Partial<AiReceiptRequestBody>;
  if (!candidate.imageBase64 || candidate.imageBase64.trim().length < 20) {
    throw new AiGatewayError("invalid_request", "Receipt image is required.", 400);
  }
  if (!candidate.mimeType || !candidate.mimeType.startsWith("image/")) {
    throw new AiGatewayError("invalid_request", "Valid image mime type is required.", 400);
  }
  if (!candidate.now || Number.isNaN(Date.parse(candidate.now))) {
    throw new AiGatewayError("invalid_request", "Valid now value is required.", 400);
  }
  return {
    imageBase64: candidate.imageBase64.trim(),
    mimeType: candidate.mimeType,
    now: candidate.now,
    locale: candidate.locale ?? "ar-EG",
    defaultCurrency: candidate.defaultCurrency ?? "EGP",
    clientRequestId: candidate.clientRequestId,
    imageFingerprint: candidate.imageFingerprint,
    categories: Array.isArray(candidate.categories) ? candidate.categories : [],
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
