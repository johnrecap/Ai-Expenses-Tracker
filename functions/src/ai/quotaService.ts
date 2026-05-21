import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { AiGatewayError, AiQuotaStatus, AiRequestType } from "./providerTypes.js";

export interface QuotaLimits {
  dailyUserLimit: number;
  dailyGlobalLimit?: number;
  requestTypeLimits?: Partial<Record<AiRequestType, number>>;
  requestTypeGlobalLimits?: Partial<Record<AiRequestType, number>>;
}

export interface QuotaStore {
  getCount(path: string): Promise<number>;
  increment(path: string, metadata?: Record<string, unknown>): Promise<void>;
  logUsage?(path: string, data: Record<string, unknown>): Promise<void>;
}

export class FirestoreQuotaStore implements QuotaStore {
  async getCount(path: string): Promise<number> {
    const snapshot = await getFirestore().doc(path).get();
    const value = snapshot.get("count");
    return typeof value === "number" ? value : 0;
  }

  async increment(path: string, metadata: Record<string, unknown> = {}): Promise<void> {
    await getFirestore().doc(path).set(
      {
        ...metadata,
        count: FieldValue.increment(1),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
  }
  async logUsage(path: string, data: Record<string, unknown>): Promise<void> {
    await getFirestore().collection(path).add({
      ...data,
      createdAt: FieldValue.serverTimestamp(),
    });
  }
}

export interface UsageLogEntry {
  uid: string;
  requestType: AiRequestType;
  dateKey: string;
  status: "success" | "failure" | "quota_blocked";
  provider: string;
  model: string;
  requestId: string;
  errorCode?: string;
  inputTokens?: number;
  outputTokens?: number;
}

export class InMemoryQuotaStore implements QuotaStore {
  private readonly counts = new Map<string, number>();

  async getCount(path: string): Promise<number> {
    return this.counts.get(path) ?? 0;
  }

  readonly logs: UsageLogEntry[] = [];

  async increment(path: string): Promise<void> {
    this.counts.set(path, (this.counts.get(path) ?? 0) + 1);
  }

  async logUsage(_path: string, data: Record<string, unknown>): Promise<void> {
    this.logs.push(data as unknown as UsageLogEntry);
  }
}

export class QuotaService {
  constructor(
    private readonly store: QuotaStore,
    private readonly limits: QuotaLimits,
  ) {}

  static fromEnvironment(store: QuotaStore = new FirestoreQuotaStore()) {
    return new QuotaService(store, {
      dailyUserLimit: numberFromEnv("AI_DAILY_USER_LIMIT", 50),
      dailyGlobalLimit: optionalNumberFromEnv("AI_DAILY_GLOBAL_LIMIT"),
      requestTypeLimits: {
        parse_text: numberFromEnv("AI_PARSE_DAILY_USER_LIMIT", 50),
        receipt_extraction: numberFromEnv("AI_RECEIPT_DAILY_USER_LIMIT", 3),
        financial_advice: numberFromEnv("AI_ADVICE_DAILY_USER_LIMIT", 5),
      },
      requestTypeGlobalLimits: {
        parse_text: optionalNumberFromEnv("AI_PARSE_DAILY_GLOBAL_LIMIT"),
        receipt_extraction: optionalNumberFromEnv("AI_RECEIPT_DAILY_GLOBAL_LIMIT"),
        financial_advice: optionalNumberFromEnv("AI_ADVICE_DAILY_GLOBAL_LIMIT"),
      },
    });
  }

  async consume(
    uid: string,
    dateKey: string,
    provider: string,
    model: string,
    requestType: AiRequestType = "parse_text",
  ): Promise<AiQuotaStatus> {
    const userLimit =
      this.limits.requestTypeLimits?.[requestType] ?? this.limits.dailyUserLimit;
    const globalLimit =
      this.limits.requestTypeGlobalLimits?.[requestType] ??
      this.limits.dailyGlobalLimit;
    const userPath =
      `ai_usage/${dateKey}/users/${uid}_${requestType}_${provider}_${model}`;
    const userCount = await this.store.getCount(userPath);

    if (userCount >= userLimit) {
      throw new AiGatewayError(
        "quota_exceeded",
        "Daily user AI limit reached.",
        429,
      );
    }

    let globalPath: string | undefined;
    if (globalLimit !== undefined) {
      globalPath = `ai_usage/${dateKey}/global/${requestType}_${provider}_${model}`;
      const globalCount = await this.store.getCount(globalPath);
      if (globalCount >= globalLimit) {
        throw new AiGatewayError(
          "quota_exceeded",
          "Daily project AI limit reached.",
          429,
        );
      }
    }

    const increments = [
      this.store.increment(userPath, {
        uid,
        dateKey,
        requestType,
        provider,
        model,
      }),
    ];
    if (globalPath !== undefined) {
      increments.push(this.store.increment(globalPath, {
        dateKey,
        requestType,
        provider,
        model,
      }));
    }
    await Promise.all(increments);

    return quotaStatus(requestType, userLimit, userCount + 1, dateKey);
  }

  async logUsage(entry: UsageLogEntry): Promise<void> {
    await this.store.logUsage?.(`ai_usage_logs/${entry.dateKey}/entries`, {
      ...entry,
    });
  }
}

function numberFromEnv(name: string, fallback: number): number {
  const parsed = Number(process.env[name]);
  return Number.isFinite(parsed) && parsed > 0 ? parsed : fallback;
}

function optionalNumberFromEnv(name: string): number | undefined {
  const value = process.env[name]?.trim();
  if (!value) return undefined;
  const parsed = Number(value);
  return Number.isFinite(parsed) && parsed > 0 ? parsed : undefined;
}

function quotaStatus(
  requestType: AiRequestType,
  limit: number,
  used: number,
  dateKey: string,
): AiQuotaStatus {
  const resetAt = new Date(`${dateKey}T00:00:00.000Z`);
  resetAt.setUTCDate(resetAt.getUTCDate() + 1);
  return {
    requestType,
    allowed: used <= limit,
    limit,
    used,
    remaining: Math.max(limit - used, 0),
    resetAt: resetAt.toISOString(),
  };
}
