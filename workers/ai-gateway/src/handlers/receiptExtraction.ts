import { FirebaseJwtVerifier, requireFirebaseUser } from "../auth/firebaseTokenVerifier";
import { GeminiProvider } from "../ai/geminiProvider";
import {
  AiGatewayError,
  AiProvider,
  AiReceiptRequestBody,
  AiRequestType,
  isAiGatewayError,
} from "../ai/providerTypes";
import { getGatewayConfig, WorkerEnv } from "../config";
import { errorResponse, successResponse } from "../http/response";
import {
  dateKeyFromDate,
  D1UsageCounterStore,
  quotaStatusForBlocked,
  QuotaService,
} from "../quota/quotaService";
import {
  D1UsageLogService,
  safeLogUsage,
  UsageLogService,
} from "../quota/usageLogService";
import { validateParseRequestBody } from "./parseExpense";

export interface ReceiptExtractionDependencies {
  provider?: AiProvider;
  quotaService?: QuotaService;
  usageLogService?: UsageLogService;
  tokenVerifier?: FirebaseJwtVerifier;
  now?: () => Date;
}

const requestType: AiRequestType = "receipt_extraction";
const maxReceiptBase64Length = 6 * 1024 * 1024;

export async function handleReceiptExtraction(
  request: Request,
  env: WorkerEnv,
  ctx?: ExecutionContext,
  deps: ReceiptExtractionDependencies = {},
): Promise<Response> {
  const requestId = crypto.randomUUID();
  let uid = "unknown";
  let dateKey = dateKeyFromDate(deps.now?.() ?? new Date());

  try {
    if (request.method !== "POST") {
      throw new AiGatewayError("invalid_request", "Only POST is supported.", 405);
    }
    const config = getGatewayConfig(env);
    const providerName = deps.provider?.provider ?? config.provider;
    const model = deps.provider?.model ?? config.model;
    const quotaService =
      deps.quotaService ?? new QuotaService(new D1UsageCounterStore(config.db));
    const usageLogService =
      deps.usageLogService ?? new D1UsageLogService(config.db);
    const body = validateReceiptRequestBody(await parseJsonBody(request));
    const user = await requireFirebaseUser(
      request.headers.get("authorization"),
      config.firebaseProjectId,
      deps.tokenVerifier,
    );
    uid = user.uid;
    dateKey = dateKeyFromDate(deps.now?.() ?? new Date());

    const quota = await quotaService.consume({
      uid,
      dateKey,
      requestType,
      provider: providerName,
      model,
      userLimit: config.userLimits.receipt_extraction,
      globalLimit: config.globalLimits.receipt_extraction,
    });

    const provider = deps.provider ?? new GeminiProvider(config);
    const providerResult = await provider.extractReceipt(body);
    await logUsage(ctx, usageLogService, {
      uid,
      dateKey,
      requestType,
      status: "success",
      provider: provider.provider,
      model: provider.model,
      requestId,
      inputTokens: providerResult.usage?.inputTokens,
      outputTokens: providerResult.usage?.outputTokens,
      createdAt: new Date().toISOString(),
    });

    return successResponse({
      provider: provider.provider,
      model: provider.model,
      requestId,
      usage: providerResult.usage,
      quota,
      structuredJson: providerResult.structuredJson,
    });
  } catch (error) {
    const config = tryConfig(env);
    const usageLogService =
      deps.usageLogService ??
      (config ? new D1UsageLogService(config.db) : undefined);
    const providerName = deps.provider?.provider ?? config?.provider ?? "gemini";
    const model = deps.provider?.model ?? config?.model ?? "gemini-2.5-flash";
    if (usageLogService) {
      await logUsage(ctx, usageLogService, {
        uid,
        dateKey,
        requestType,
        status:
          isAiGatewayError(error) && error.code === "quota_exceeded"
            ? "quota_blocked"
            : "failure",
        provider: providerName,
        model,
        requestId,
        errorCode: isAiGatewayError(error) ? error.code : undefined,
        createdAt: new Date().toISOString(),
      });
    }
    return errorResponse({
      error,
      provider: providerName,
      model,
      requestId,
      quota:
        isAiGatewayError(error) &&
        error.code === "quota_exceeded" &&
        error.message.includes("request type") &&
        uid !== "unknown"
          ? quotaStatusForBlocked(
              requestType,
              config?.userLimits.receipt_extraction ?? 3,
              dateKey,
            )
          : undefined,
    });
  }
}

export function validateReceiptRequestBody(body: unknown): AiReceiptRequestBody {
  const base = validateParseRequestBody({
    ...(body && typeof body === "object" && !Array.isArray(body) ? body : {}),
    input: "receipt",
  });
  const candidate = body as Record<string, unknown>;
  const imageBase64 = readTrimmedString(candidate.imageBase64);
  if (!imageBase64 || imageBase64.length < 20) {
    throw new AiGatewayError("invalid_request", "Receipt image is required.", 400);
  }
  if (imageBase64.length > maxReceiptBase64Length) {
    throw new AiGatewayError("invalid_request", "Receipt image is too large.", 400);
  }
  const mimeType = readTrimmedString(candidate.mimeType);
  if (!mimeType || !mimeType.startsWith("image/")) {
    throw new AiGatewayError(
      "invalid_request",
      "Valid image mime type is required.",
      400,
    );
  }

  return {
    imageBase64,
    mimeType,
    now: base.now,
    locale: base.locale,
    defaultCurrency: base.defaultCurrency,
    clientRequestId: readTrimmedString(candidate.clientRequestId),
    imageFingerprint: readTrimmedString(candidate.imageFingerprint),
    categories: base.categories,
  };
}

async function parseJsonBody(request: Request): Promise<unknown> {
  try {
    return await request.json();
  } catch {
    throw new AiGatewayError("invalid_request", "Request body must be valid JSON.", 400);
  }
}

function readTrimmedString(value: unknown) {
  return typeof value === "string" && value.trim().length > 0
    ? value.trim()
    : undefined;
}

async function logUsage(
  ctx: ExecutionContext | undefined,
  service: UsageLogService,
  entry: Parameters<typeof safeLogUsage>[1],
) {
  const promise = safeLogUsage(service, entry);
  if (ctx) {
    ctx.waitUntil(promise);
    return;
  }
  await promise;
}

function tryConfig(env: WorkerEnv) {
  try {
    return getGatewayConfig(env);
  } catch {
    return undefined;
  }
}
