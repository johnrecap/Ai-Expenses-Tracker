import type { FastifyRequest } from "fastify";

const redactedKeys = new Set([
  "authorization",
  "cookie",
  "database_url",
  "firebase_private_key",
  "receiptText",
  "receiptImage",
  "rawInput",
  "description",
  "note",
  "prompt",
]);

export interface SafeLogContext {
  requestId?: string;
  userId?: string;
  route?: string;
  statusCode?: number;
  durationMs?: number;
  code?: string;
  details?: Record<string, unknown>;
}

export function safeRequestContext(request: FastifyRequest): SafeLogContext {
  return {
    requestId: request.id,
    route: request.routeOptions.url,
  };
}

export function sanitizeLogValue(value: unknown): unknown {
  if (Array.isArray(value)) return value.map(sanitizeLogValue);
  if (value && typeof value === "object") {
    return Object.fromEntries(
      Object.entries(value as Record<string, unknown>).map(([key, entry]) => [
        key,
        redactedKeys.has(key.toLowerCase()) ? "[redacted]" : sanitizeLogValue(entry),
      ]),
    );
  }
  return value;
}

export function safeLogContext(context: SafeLogContext): SafeLogContext {
  return sanitizeLogValue(context) as SafeLogContext;
}
