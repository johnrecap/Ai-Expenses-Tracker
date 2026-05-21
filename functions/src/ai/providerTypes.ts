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
  }
}

export interface AiGatewayRequestBody {
  input: string;
  now: string;
  locale?: string;
  defaultCurrency?: string;
  clientRequestId?: string;
  categories?: Array<{
    categoryId?: string;
    name?: string;
    isArchived?: boolean;
  }>;
  recentExpenses?: Array<Record<string, unknown>>;
  budgetSummary?: Record<string, unknown>;
}

export type AiRequestType =
  | "parse_text"
  | "receipt_extraction"
  | "financial_advice";

export interface AiStructuredResponse {
  intent: string;
  amount?: number | null;
  category?: string | null;
  categoryId?: string | null;
  date?: string | null;
  paymentMethod?: string | null;
  currency?: string | null;
  description?: string | null;
  query?: string | null;
  period?: string | null;
  startDate?: string | null;
  endDate?: string | null;
  periodText?: string | null;
  focusCategory?: string | null;
  tone?: string | null;
  confidence: number;
  needsConfirmation: boolean;
  clarifyingQuestion?: string | null;
}

export interface AiProviderUsage {
  inputTokens?: number;
  outputTokens?: number;
}

export interface AiProviderResult {
  structuredJson: AiStructuredResponse;
  usage?: AiProviderUsage;
}

export interface AiReceiptRequestBody {
  imageBase64: string;
  mimeType: string;
  now: string;
  locale?: string;
  defaultCurrency?: string;
  clientRequestId?: string;
  imageFingerprint?: string;
  categories?: Array<{
    categoryId?: string;
    name?: string;
    isArchived?: boolean;
  }>;
}

export interface AiReceiptStructuredResponse {
  intent: "add_expense";
  amount?: number | null;
  date?: string | null;
  merchant?: string | null;
  category?: string | null;
  categoryId?: string | null;
  currency?: string | null;
  description?: string | null;
  rawText?: string | null;
  confidence: number;
  needsConfirmation: boolean;
}

export interface AiReceiptProviderResult {
  structuredJson: AiReceiptStructuredResponse;
  usage?: AiProviderUsage;
}

export interface AiFinancialAdviceRequestBody {
  period: "week" | "month";
  now: string;
  locale?: string;
  defaultCurrency?: string;
  clientRequestId?: string;
  summary: Record<string, unknown>;
}

export interface AiFinancialAdviceStructuredResponse {
  period: "week" | "month";
  groundedSummary: string;
  advice: string;
  categoryDrivers: Array<{
    category: string;
    amount: number;
    currency?: string | null;
    note?: string | null;
  }>;
  qualityNote?: string | null;
  confidence: number;
  needsConfirmation: boolean;
}

export interface AiFinancialAdviceProviderResult {
  structuredJson: AiFinancialAdviceStructuredResponse;
  usage?: AiProviderUsage;
}

export interface AiProvider {
  parse(request: AiGatewayRequestBody): Promise<AiProviderResult>;
  extractReceipt?(
    request: AiReceiptRequestBody,
  ): Promise<AiReceiptProviderResult>;
  financialAdvice?(
    request: AiFinancialAdviceRequestBody,
  ): Promise<AiFinancialAdviceProviderResult>;
}

export interface AiQuotaStatus {
  requestType: AiRequestType;
  allowed: boolean;
  limit: number;
  used: number;
  remaining: number;
  resetAt: string;
}

export interface AiGatewaySuccess {
  ok: true;
  provider: string;
  model: string;
  requestId: string;
  usage?: AiProviderUsage;
  quota?: AiQuotaStatus;
  structuredJson:
    | AiStructuredResponse
    | AiReceiptStructuredResponse
    | AiFinancialAdviceStructuredResponse;
}

export interface AiGatewayFailure {
  ok: false;
  provider?: string;
  model?: string;
  requestId: string;
  errorCode: AiGatewayErrorCode;
  errorMessage: string;
  quota?: AiQuotaStatus;
}

export type AiGatewayResponse = AiGatewaySuccess | AiGatewayFailure;
