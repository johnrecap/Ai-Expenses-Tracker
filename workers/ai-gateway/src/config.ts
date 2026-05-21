import { AiGatewayError, AiRequestType } from "./ai/providerTypes";

export interface WorkerEnv {
  AI_DB: D1Database;
  GEMINI_API_KEY?: string;
  FIREBASE_PROJECT_ID?: string;
  AI_PROVIDER?: string;
  AI_MODEL?: string;
  AI_PARSE_DAILY_USER_LIMIT?: string;
  AI_RECEIPT_DAILY_USER_LIMIT?: string;
  AI_ADVICE_DAILY_USER_LIMIT?: string;
  AI_PARSE_DAILY_GLOBAL_LIMIT?: string;
  AI_RECEIPT_DAILY_GLOBAL_LIMIT?: string;
  AI_ADVICE_DAILY_GLOBAL_LIMIT?: string;
}

export interface GatewayConfig {
  db: D1Database;
  firebaseProjectId: string;
  provider: "gemini";
  model: string;
  apiKey?: string | undefined;
  userLimits: Record<AiRequestType, number>;
  globalLimits: Partial<Record<AiRequestType, number | undefined>>;
  providerTimeoutMs: number;
}

const defaultUserLimits: Record<AiRequestType, number> = {
  parse_text: 5,
  receipt_extraction: 3,
  financial_advice: 3,
};

export function getGatewayConfig(env: WorkerEnv): GatewayConfig {
  if (!env.AI_DB) {
    throw new AiGatewayError(
      "gateway_misconfigured",
      "AI gateway database is not configured.",
      500,
    );
  }

  const firebaseProjectId = env.FIREBASE_PROJECT_ID?.trim();
  if (!firebaseProjectId) {
    throw new AiGatewayError(
      "gateway_misconfigured",
      "Firebase project id is not configured.",
      500,
    );
  }

  const provider = env.AI_PROVIDER?.trim() || "gemini";
  if (provider !== "gemini") {
    throw new AiGatewayError(
      "gateway_misconfigured",
      "Configured AI provider is not supported.",
      500,
    );
  }

  return {
    db: env.AI_DB,
    firebaseProjectId,
    provider,
    model: env.AI_MODEL?.trim() || "gemini-2.5-flash",
    apiKey: env.GEMINI_API_KEY,
    userLimits: {
      parse_text: parsePositiveInteger(
        env.AI_PARSE_DAILY_USER_LIMIT,
        defaultUserLimits.parse_text,
      ),
      receipt_extraction: parsePositiveInteger(
        env.AI_RECEIPT_DAILY_USER_LIMIT,
        defaultUserLimits.receipt_extraction,
      ),
      financial_advice: parsePositiveInteger(
        env.AI_ADVICE_DAILY_USER_LIMIT,
        defaultUserLimits.financial_advice,
      ),
    },
    globalLimits: {
      // Emergency-only controls. The default product rule is per-user quota,
      // so these remain inactive unless explicitly configured.
      parse_text: parseOptionalPositiveInteger(env.AI_PARSE_DAILY_GLOBAL_LIMIT),
      receipt_extraction: parseOptionalPositiveInteger(
        env.AI_RECEIPT_DAILY_GLOBAL_LIMIT,
      ),
      financial_advice: parseOptionalPositiveInteger(
        env.AI_ADVICE_DAILY_GLOBAL_LIMIT,
      ),
    },
    providerTimeoutMs: 10000,
  };
}

export function requireGeminiApiKey(config: GatewayConfig): string {
  const apiKey = config.apiKey?.trim();
  if (!apiKey) {
    throw new AiGatewayError(
      "gateway_misconfigured",
      "Gemini API key is not configured.",
      500,
    );
  }
  return apiKey;
}

function parsePositiveInteger(value: string | undefined, fallback: number) {
  const parsed = Number.parseInt(value ?? "", 10);
  return Number.isFinite(parsed) && parsed > 0 ? parsed : fallback;
}

function parseOptionalPositiveInteger(value: string | undefined) {
  const parsed = Number.parseInt(value ?? "", 10);
  return Number.isFinite(parsed) && parsed > 0 ? parsed : undefined;
}
