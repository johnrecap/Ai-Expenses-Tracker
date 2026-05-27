import type { FastifyReply } from "fastify";
import type { ZodSchema } from "zod";

import { sendApiError } from "./errors.js";

export function parseBody<T>(
  schema: ZodSchema<T>,
  body: unknown,
  reply: FastifyReply,
): T | undefined {
  const parsed = schema.safeParse(body);
  if (parsed.success) return parsed.data;

  sendApiError(reply, 400, {
    code: "request/invalid-body",
    message: parsed.error.issues.map((issue) => issue.message).join("; "),
    retryable: false,
  });
  return undefined;
}
