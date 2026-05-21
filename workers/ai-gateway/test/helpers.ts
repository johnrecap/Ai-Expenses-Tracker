import type { JWTPayload } from "jose";
import {
  AiFinancialAdviceRequestBody,
  AiFinancialAdviceStructuredResponse,
  AiGatewayRequestBody,
  AiProvider,
  AiProviderResult,
  AiReceiptRequestBody,
  AiReceiptStructuredResponse,
  AiStructuredResponse,
} from "../src/ai/providerTypes";
import { WorkerEnv } from "../src/config";
import { InMemoryUsageCounterStore, QuotaService } from "../src/quota/quotaService";

export function testEnv(overrides: Partial<WorkerEnv> = {}): WorkerEnv {
  return {
    AI_DB: {} as D1Database,
    FIREBASE_PROJECT_ID: "test-project",
    AI_PROVIDER: "gemini",
    AI_MODEL: "gemini-2.5-flash",
    AI_PARSE_DAILY_USER_LIMIT: "5",
    AI_RECEIPT_DAILY_USER_LIMIT: "3",
    AI_ADVICE_DAILY_USER_LIMIT: "3",
    ...overrides,
  };
}

export function validPayload(uid = "user-1"): JWTPayload {
  return {
    iss: "https://securetoken.google.com/test-project",
    aud: "test-project",
    exp: Math.floor(Date.now() / 1000) + 3600,
    sub: uid,
    email: `${uid}@example.test`,
  };
}

export const validVerifier = async () => validPayload();

export function jsonRequest(
  path: string,
  body: Record<string, unknown>,
  token = "token",
): Request {
  return new Request(`https://gateway.test${path}`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    body: JSON.stringify(body),
  });
}

export async function readJson(response: Response) {
  return (await response.json()) as Record<string, unknown>;
}

export function quotaService() {
  return new QuotaService(new InMemoryUsageCounterStore());
}

export class FakeProvider implements AiProvider {
  readonly provider = "gemini";
  readonly model = "gemini-2.5-flash";
  parseCalls = 0;
  receiptCalls = 0;
  adviceCalls = 0;

  constructor(
    private readonly overrides: {
      parse?: AiProviderResult<AiStructuredResponse>;
      receipt?: AiProviderResult<AiReceiptStructuredResponse>;
      advice?: AiProviderResult<AiFinancialAdviceStructuredResponse>;
      error?: Error;
    } = {},
  ) {}

  async parse(
    _request: AiGatewayRequestBody,
  ): Promise<AiProviderResult<AiStructuredResponse>> {
    this.parseCalls += 1;
    if (this.overrides.error) throw this.overrides.error;
    return (
      this.overrides.parse ?? {
        usage: { inputTokens: 10, outputTokens: 5 },
        structuredJson: {
          intent: "add_expense",
          amount: 250,
          category: "Food",
          date: "2026-05-16",
          paymentMethod: "Cash",
          currency: "EGP",
          description: "Food",
          confidence: 0.9,
          needsConfirmation: true,
        },
      }
    );
  }

  async extractReceipt(
    _request: AiReceiptRequestBody,
  ): Promise<AiProviderResult<AiReceiptStructuredResponse>> {
    this.receiptCalls += 1;
    if (this.overrides.error) throw this.overrides.error;
    return (
      this.overrides.receipt ?? {
        usage: { inputTokens: 20, outputTokens: 7 },
        structuredJson: {
          intent: "add_expense",
          amount: 150,
          date: "2026-05-16",
          category: "Food",
          currency: "EGP",
          description: "Receipt",
          confidence: 0.85,
          needsConfirmation: true,
        },
      }
    );
  }

  async financialAdvice(
    _request: AiFinancialAdviceRequestBody,
  ): Promise<AiProviderResult<AiFinancialAdviceStructuredResponse>> {
    this.adviceCalls += 1;
    if (this.overrides.error) throw this.overrides.error;
    return (
      this.overrides.advice ?? {
        usage: { inputTokens: 30, outputTokens: 12 },
        structuredJson: {
          period: "month",
          groundedSummary: "Restaurants are high.",
          advice: "حدد ميزانية مطاعم أقل هذا الشهر.",
          categoryDrivers: [
            { category: "Food", amount: 500, currency: "EGP" },
          ],
          confidence: 0.88,
          needsConfirmation: true,
        },
      }
    );
  }
}
