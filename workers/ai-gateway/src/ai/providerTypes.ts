export type AiRequestType =
  | "parse_text"
  | "receipt_extraction"
  | "financial_advice";

export type AiGatewayErrorCode =
  | "unauthenticated"
  | "quota_exceeded"
  | "rate_limited"
  | "provider_timeout"
  | "provider_unavailable"
  | "invalid_provider_output"
  | "gateway_misconfigured"
  | "invalid_request";

export class AiGatewayError extends Error {
  constructor(
    public readonly code: AiGatewayErrorCode,
    message: string,
    public readonly status = 400,
  ) {
    super(message);
    this.name = "AiGatewayError";
    Object.setPrototypeOf(this, new.target.prototype);
  }
}

export function isAiGatewayError(error: unknown): error is AiGatewayError {
  if (error instanceof AiGatewayError) return true;
  if (!error || typeof error !== "object") return false;
  const candidate = error as Record<string, unknown>;
  return (
    typeof candidate.code === "string" &&
    typeof candidate.message === "string" &&
    typeof candidate.status === "number"
  );
}

export interface CategorySnapshot {
  categoryId?: string | undefined;
  name?: string | undefined;
  isArchived?: boolean | undefined;
}

export interface AiGatewayRequestBody {
  input: string;
  now: string;
  locale: string;
  defaultCurrency: string;
  clientRequestId?: string | undefined;
  categories: CategorySnapshot[];
  recentExpenses: Array<Record<string, unknown>>;
  budgetSummary?: Record<string, unknown> | undefined;
}

export interface AiReceiptRequestBody {
  imageBase64: string;
  mimeType: string;
  now: string;
  locale: string;
  defaultCurrency: string;
  clientRequestId?: string | undefined;
  imageFingerprint?: string | undefined;
  categories: CategorySnapshot[];
}

export interface AiFinancialAdviceRequestBody {
  period: "week" | "month";
  now: string;
  locale: string;
  defaultCurrency: string;
  clientRequestId?: string | undefined;
  summary: Record<string, unknown>;
}

export interface AiStructuredResponse {
  intent: string;
  amount?: number | null | undefined;
  category?: string | null | undefined;
  categoryId?: string | null | undefined;
  date?: string | null | undefined;
  paymentMethod?: string | null | undefined;
  currency?: string | null | undefined;
  description?: string | null | undefined;
  categoryConfidence?: number | null | undefined;
  categoryReason?: string | null | undefined;
  suggestedCategoryName?: string | null | undefined;
  suggestedCategoryIcon?: string | null | undefined;
  suggestedCategoryColor?: string | number | null | undefined;
  query?: string | null | undefined;
  period?: string | null | undefined;
  startDate?: string | null | undefined;
  endDate?: string | null | undefined;
  periodText?: string | null | undefined;
  focusCategory?: string | null | undefined;
  tone?: string | null | undefined;
  confidence: number;
  needsConfirmation: true;
  clarifyingQuestion?: string | null | undefined;
}

export interface AiReceiptStructuredResponse {
  intent: "add_expense";
  amount?: number | null | undefined;
  date?: string | null | undefined;
  merchant?: string | null | undefined;
  category?: string | null | undefined;
  categoryId?: string | null | undefined;
  currency?: string | null | undefined;
  description?: string | null | undefined;
  rawText?: string | null | undefined;
  confidence: number;
  needsConfirmation: true;
}

export interface AiFinancialAdviceStructuredResponse {
  period: "week" | "month";
  groundedSummary: string;
  advice: string;
  categoryDrivers: Array<{
    category: string;
    amount: number;
    currency?: string | null | undefined;
    note?: string | null | undefined;
  }>;
  qualityNote?: string | null | undefined;
  confidence: number;
  needsConfirmation: true;
}

export interface AiProviderUsage {
  inputTokens?: number | undefined;
  outputTokens?: number | undefined;
}

export interface AiProviderResult<TStructured> {
  structuredJson: TStructured;
  usage?: AiProviderUsage | undefined;
}

export interface AiProvider {
  readonly provider: string;
  readonly model: string;
  parse(
    request: AiGatewayRequestBody,
  ): Promise<AiProviderResult<AiStructuredResponse>>;
  extractReceipt(
    request: AiReceiptRequestBody,
  ): Promise<AiProviderResult<AiReceiptStructuredResponse>>;
  financialAdvice(
    request: AiFinancialAdviceRequestBody,
  ): Promise<AiProviderResult<AiFinancialAdviceStructuredResponse>>;
}

export interface AiQuotaStatus {
  requestType: AiRequestType;
  allowed: boolean;
  limit: number;
  used: number;
  remaining: number;
  resetAt: string;
}

export type GatewayStructuredJson =
  | AiStructuredResponse
  | AiReceiptStructuredResponse
  | AiFinancialAdviceStructuredResponse;

export interface AiGatewaySuccess {
  ok: true;
  provider: string;
  model: string;
  requestId: string;
  usage?: AiProviderUsage | undefined;
  quota?: AiQuotaStatus | undefined;
  structuredJson: GatewayStructuredJson;
}

export interface AiGatewayFailure {
  ok: false;
  provider?: string | undefined;
  model?: string | undefined;
  requestId: string;
  errorCode: AiGatewayErrorCode;
  errorMessage: string;
  quota?: AiQuotaStatus | undefined;
}

export type AiGatewayResponse = AiGatewaySuccess | AiGatewayFailure;
