import { AiGatewayErrorCode, AiRequestType } from "../ai/providerTypes";

export interface UsageLogEntry {
  uid: string;
  dateKey: string;
  requestType: AiRequestType;
  status: "success" | "failure" | "quota_blocked";
  provider: string;
  model: string;
  requestId: string;
  errorCode?: AiGatewayErrorCode | undefined;
  inputTokens?: number | undefined;
  outputTokens?: number | undefined;
  createdAt: string;
}

export interface UsageLogService {
  log(entry: UsageLogEntry): Promise<void>;
}

export class D1UsageLogService implements UsageLogService {
  constructor(private readonly db: D1Database) {}

  async log(entry: UsageLogEntry): Promise<void> {
    await this.db
      .prepare(
        `INSERT INTO ai_usage_logs
        (id, date_key, uid, request_type, status, provider, model, request_id, error_code, input_tokens, output_tokens, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      )
      .bind(
        crypto.randomUUID(),
        entry.dateKey,
        entry.uid,
        entry.requestType,
        entry.status,
        entry.provider,
        entry.model,
        entry.requestId,
        entry.errorCode ?? null,
        entry.inputTokens ?? null,
        entry.outputTokens ?? null,
        entry.createdAt,
      )
      .run();
  }
}

export class InMemoryUsageLogService implements UsageLogService {
  readonly entries: UsageLogEntry[] = [];

  async log(entry: UsageLogEntry): Promise<void> {
    this.entries.push(entry);
  }
}

export async function safeLogUsage(
  service: UsageLogService,
  entry: UsageLogEntry,
): Promise<void> {
  try {
    await service.log(entry);
  } catch {
    // Usage logs are operational metadata and must not block AI responses.
  }
}
