import type { FastifyReply } from "fastify";

export interface ApiErrorResponse {
  code: string;
  message: string;
  retryable: boolean;
}

export function sendApiError(
  reply: FastifyReply,
  statusCode: number,
  error: ApiErrorResponse,
) {
  return reply.code(statusCode).send(error);
}

export const internalError: ApiErrorResponse = {
  code: "server/internal",
  message: "The server could not complete the request.",
  retryable: true,
};
