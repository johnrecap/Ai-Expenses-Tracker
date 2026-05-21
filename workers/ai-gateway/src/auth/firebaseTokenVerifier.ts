import {
  decodeProtectedHeader,
  jwtVerify,
  type JWTPayload,
} from "jose";
import { AiGatewayError } from "../ai/providerTypes";
import { getGoogleSecureTokenPublicKey } from "./googleJwksCache";

export interface VerifiedFirebaseUser {
  uid: string;
  email?: string;
}

export type FirebaseJwtVerifier = (
  token: string,
  firebaseProjectId: string,
) => Promise<JWTPayload>;

export async function requireFirebaseUser(
  authorizationHeader: string | null,
  firebaseProjectId: string,
  verifier: FirebaseJwtVerifier = verifyFirebaseJwt,
): Promise<VerifiedFirebaseUser> {
  const token = readBearerToken(authorizationHeader);
  const payload = await verifier(token, firebaseProjectId);
  return validateFirebasePayload(payload, firebaseProjectId);
}

export function readBearerToken(authorizationHeader: string | null): string {
  if (!authorizationHeader) {
    throw new AiGatewayError(
      "unauthenticated",
      "Authentication token is required.",
      401,
    );
  }
  const match = authorizationHeader.match(/^Bearer\s+(.+)$/i);
  if (!match?.[1]?.trim()) {
    throw new AiGatewayError(
      "unauthenticated",
      "Authentication token must use Bearer format.",
      401,
    );
  }
  return match[1].trim();
}

export async function verifyFirebaseJwt(
  token: string,
  firebaseProjectId: string,
): Promise<JWTPayload> {
  let kid: string | undefined;
  try {
    const header = decodeProtectedHeader(token);
    kid = typeof header.kid === "string" ? header.kid : undefined;
  } catch {
    throw new AiGatewayError(
      "unauthenticated",
      "Authentication token is invalid.",
      401,
    );
  }

  if (!kid) {
    throw new AiGatewayError(
      "unauthenticated",
      "Authentication token key is missing.",
      401,
    );
  }

  const key = await getGoogleSecureTokenPublicKey(kid);
  try {
    const result = await jwtVerify(token, key, {
      issuer: issuerForProject(firebaseProjectId),
      audience: firebaseProjectId,
    });
    return result.payload;
  } catch {
    throw new AiGatewayError(
      "unauthenticated",
      "Authentication token could not be verified.",
      401,
    );
  }
}

export function validateFirebasePayload(
  payload: JWTPayload,
  firebaseProjectId: string,
  nowSeconds = Math.floor(Date.now() / 1000),
): VerifiedFirebaseUser {
  if (payload.iss !== issuerForProject(firebaseProjectId)) {
    throw new AiGatewayError(
      "unauthenticated",
      "Authentication token issuer is invalid.",
      401,
    );
  }
  if (payload.aud !== firebaseProjectId) {
    throw new AiGatewayError(
      "unauthenticated",
      "Authentication token audience is invalid.",
      401,
    );
  }
  if (typeof payload.exp !== "number" || payload.exp <= nowSeconds) {
    throw new AiGatewayError(
      "unauthenticated",
      "Authentication token has expired.",
      401,
    );
  }
  if (typeof payload.sub !== "string" || payload.sub.trim() === "") {
    throw new AiGatewayError(
      "unauthenticated",
      "Authentication token user id is missing.",
      401,
    );
  }
  return {
    uid: payload.sub,
    ...(typeof payload.email === "string" ? { email: payload.email } : {}),
  };
}

function issuerForProject(projectId: string) {
  return `https://securetoken.google.com/${projectId}`;
}
