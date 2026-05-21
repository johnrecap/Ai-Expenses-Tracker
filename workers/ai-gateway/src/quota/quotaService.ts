import {
  AiGatewayError,
  AiQuotaStatus,
  AiRequestType,
} from "../ai/providerTypes";

export interface ConsumeQuotaInput {
  uid: string;
  dateKey: string;
  requestType: AiRequestType;
  provider: string;
  model: string;
  userLimit: number;
  globalLimit?: number | undefined;
}

export interface CounterConsumeInput {
  dateKey: string;
  uid: string;
  requestType: AiRequestType;
  provider: string;
  model: string;
  limit: number;
  nowIso: string;
}

export interface UsageCounterStore {
  consumeCounter(input: CounterConsumeInput): Promise<number | null>;
  decrementCounter(input: Omit<CounterConsumeInput, "limit">): Promise<void>;
}

export class QuotaService {
  constructor(private readonly store: UsageCounterStore) {}

  async consume(input: ConsumeQuotaInput): Promise<AiQuotaStatus> {
    const nowIso = new Date().toISOString();
    const userCounter: CounterConsumeInput = {
      dateKey: input.dateKey,
      uid: input.uid,
      requestType: input.requestType,
      provider: input.provider,
      model: input.model,
      limit: input.userLimit,
      nowIso,
    };

    const userUsed = await this.store.consumeCounter(userCounter);
    if (userUsed === null) {
      throw new AiGatewayError(
        "quota_exceeded",
        "Daily AI limit reached for this request type.",
        429,
      );
    }

    if (input.globalLimit) {
      try {
        await this.consumeGlobalQuota(input, nowIso);
      } catch (error) {
        await this.store.decrementCounter({
          dateKey: userCounter.dateKey,
          uid: userCounter.uid,
          requestType: userCounter.requestType,
          provider: userCounter.provider,
          model: userCounter.model,
          nowIso,
        });
        throw error;
      }
    }

    return statusFromUsed(input.requestType, input.userLimit, userUsed, input.dateKey);
  }

  private async consumeGlobalQuota(
    input: ConsumeQuotaInput,
    nowIso: string,
  ): Promise<void> {
    const used = await this.store.consumeCounter({
      dateKey: input.dateKey,
      uid: "__global__",
      requestType: input.requestType,
      provider: input.provider,
      model: input.model,
      limit: input.globalLimit ?? 0,
      nowIso,
    });
    if (used === null) {
      throw new AiGatewayError(
        "quota_exceeded",
        "AI gateway daily emergency limit reached.",
        429,
      );
    }
  }
}

export class D1UsageCounterStore implements UsageCounterStore {
  constructor(private readonly db: D1Database) {}

  async consumeCounter(input: CounterConsumeInput): Promise<number | null> {
    await this.db
      .prepare(
        `INSERT OR IGNORE INTO ai_usage_daily
        (date_key, uid, request_type, provider, model, used_count, limit_count, created_at, updated_at)
        VALUES (?, ?, ?, ?, ?, 0, ?, ?, ?)`,
      )
      .bind(
        input.dateKey,
        input.uid,
        input.requestType,
        input.provider,
        input.model,
        input.limit,
        input.nowIso,
        input.nowIso,
      )
      .run();

    const updated = await this.db
      .prepare(
        `UPDATE ai_usage_daily
        SET used_count = used_count + 1,
            limit_count = ?,
            updated_at = ?
        WHERE date_key = ?
          AND uid = ?
          AND request_type = ?
          AND provider = ?
          AND model = ?
          AND used_count < ?
        RETURNING used_count`,
      )
      .bind(
        input.limit,
        input.nowIso,
        input.dateKey,
        input.uid,
        input.requestType,
        input.provider,
        input.model,
        input.limit,
      )
      .first<{ used_count: number }>();

    return updated ? updated.used_count : null;
  }

  async decrementCounter(input: Omit<CounterConsumeInput, "limit">): Promise<void> {
    await this.db
      .prepare(
        `UPDATE ai_usage_daily
        SET used_count = CASE WHEN used_count > 0 THEN used_count - 1 ELSE 0 END,
            updated_at = ?
        WHERE date_key = ?
          AND uid = ?
          AND request_type = ?
          AND provider = ?
          AND model = ?`,
      )
      .bind(
        input.nowIso,
        input.dateKey,
        input.uid,
        input.requestType,
        input.provider,
        input.model,
      )
      .run();
  }
}

export class InMemoryUsageCounterStore implements UsageCounterStore {
  private readonly counts = new Map<string, number>();

  async consumeCounter(input: CounterConsumeInput): Promise<number | null> {
    const key = counterKey(input);
    const current = this.counts.get(key) ?? 0;
    if (current >= input.limit) return null;
    const next = current + 1;
    this.counts.set(key, next);
    return next;
  }

  async decrementCounter(input: Omit<CounterConsumeInput, "limit">): Promise<void> {
    const key = [
      input.dateKey,
      input.uid,
      input.requestType,
      input.provider,
      input.model,
    ].join("|");
    const current = this.counts.get(key) ?? 0;
    this.counts.set(key, Math.max(0, current - 1));
  }
}

export function dateKeyFromDate(date: Date): string {
  return date.toISOString().slice(0, 10);
}

export function quotaStatusForBlocked(
  requestType: AiRequestType,
  limit: number,
  dateKey: string,
): AiQuotaStatus {
  return {
    requestType,
    allowed: false,
    limit,
    used: limit,
    remaining: 0,
    resetAt: resetAt(dateKey),
  };
}

function statusFromUsed(
  requestType: AiRequestType,
  limit: number,
  used: number,
  dateKey: string,
): AiQuotaStatus {
  return {
    requestType,
    allowed: true,
    limit,
    used,
    remaining: Math.max(0, limit - used),
    resetAt: resetAt(dateKey),
  };
}

function resetAt(dateKey: string): string {
  const reset = new Date(`${dateKey}T00:00:00.000Z`);
  reset.setUTCDate(reset.getUTCDate() + 1);
  return reset.toISOString();
}

function counterKey(input: CounterConsumeInput): string {
  return [
    input.dateKey,
    input.uid,
    input.requestType,
    input.provider,
    input.model,
  ].join("|");
}
