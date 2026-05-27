import type { FastifyReply, FastifyRequest } from "fastify";

import { sendApiError } from "../http/errors.js";

export interface BackendUserContext {
  id: string;
  firebaseUid: string;
}

export function requireFirebaseUser(request: FastifyRequest) {
  if (!request.firebaseUser) {
    throw new Error("Firebase user is missing from authenticated request.");
  }
  return request.firebaseUser;
}

export function assertOwnsUser(
  request: FastifyRequest,
  user: BackendUserContext,
): boolean {
  return request.firebaseUser?.uid === user.firebaseUid;
}

export function sendOwnershipError(reply: FastifyReply) {
  return sendApiError(reply, 403, {
    code: "auth/forbidden",
    message: "The authenticated user cannot access this resource.",
    retryable: false,
  });
}
