import type { FastifyReply, FastifyRequest } from "fastify";
import { cert, getApps, initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";

import { env } from "../config/env.js";

export interface AuthenticatedFirebaseUser {
  uid: string;
  email?: string;
}

declare module "fastify" {
  interface FastifyRequest {
    firebaseUser?: AuthenticatedFirebaseUser;
  }
}

function initializeFirebaseAdmin() {
  if (getApps().length > 0) return;
  initializeApp({
    credential: cert({
      projectId: env.FIREBASE_PROJECT_ID,
      clientEmail: env.FIREBASE_CLIENT_EMAIL,
      privateKey: env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, "\n"),
    }),
  });
}

export async function verifyFirebaseToken(
  token: string,
): Promise<AuthenticatedFirebaseUser> {
  initializeFirebaseAdmin();
  const decoded = await getAuth().verifyIdToken(token);
  return {
    uid: decoded.uid,
    email: decoded.email,
  };
}

export async function firebaseAuthGuard(
  request: FastifyRequest,
  reply: FastifyReply,
) {
  return createFirebaseAuthGuard()(request, reply);
}

export function createFirebaseAuthGuard(
  verifier: (
    token: string,
  ) => Promise<AuthenticatedFirebaseUser> = verifyFirebaseToken,
) {
  return async function guard(request: FastifyRequest, reply: FastifyReply) {
    const authorization = request.headers.authorization;
    const token = authorization?.startsWith("Bearer ")
      ? authorization.slice("Bearer ".length).trim()
      : null;

    if (!token) {
      return reply.code(401).send({
        code: "auth/missing-token",
        message: "Authentication token is required.",
        retryable: false,
      });
    }

    try {
      request.firebaseUser = await verifier(token);
    } catch {
      return reply.code(401).send({
        code: "auth/invalid-token",
        message: "Authentication token is invalid or expired.",
        retryable: true,
      });
    }
  };
}

export async function checkFirebaseVerifier(): Promise<boolean> {
  try {
    initializeFirebaseAdmin();
    getAuth();
    return true;
  } catch {
    return false;
  }
}
