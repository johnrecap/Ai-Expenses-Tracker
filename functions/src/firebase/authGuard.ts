import { getAuth } from "firebase-admin/auth";
import { AiGatewayError } from "../ai/providerTypes.js";

export type TokenVerifier = (token: string) => Promise<{ uid: string }>;

export async function requireUserId(
  authorizationHeader: string | undefined,
  verifier: TokenVerifier = (token) => getAuth().verifyIdToken(token),
): Promise<string> {
  const token = bearerTokenFromHeader(authorizationHeader);
  if (!token) {
    throw new AiGatewayError(
      "unauthenticated",
      "Missing authentication token.",
      401,
    );
  }

  const decoded = await verifier(token);
  if (!decoded.uid) {
    throw new AiGatewayError("unauthenticated", "Invalid user token.", 401);
  }
  return decoded.uid;
}

export function bearerTokenFromHeader(header: string | undefined): string | null {
  if (!header) return null;
  const match = /^Bearer\s+(.+)$/i.exec(header.trim());
  return match?.[1] ?? null;
}
