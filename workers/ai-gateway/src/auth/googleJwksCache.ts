import { importJWK, type JWK } from "jose";
import { AiGatewayError } from "../ai/providerTypes";

type FetchImpl = typeof fetch;

interface CachedJwks {
  expiresAt: number;
  keys: Map<string, JWK>;
}

const googleSecureTokenJwksUrl =
  "https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com";
const fallbackTtlMs = 5 * 60 * 1000;

let cachedJwks: CachedJwks | undefined;

export async function getGoogleSecureTokenPublicKey(
  kid: string,
  fetchImpl: FetchImpl = fetch,
): Promise<CryptoKey | Uint8Array> {
  const jwks = await getJwks(fetchImpl);
  const jwk = jwks.keys.get(kid);
  if (jwk) return importJWK(jwk, jwk.alg ?? "RS256");

  const refreshed = await refreshJwks(fetchImpl);
  const refreshedJwk = refreshed.keys.get(kid);
  if (!refreshedJwk) {
    throw new AiGatewayError(
      "unauthenticated",
      "Authentication token key is not trusted.",
      401,
    );
  }
  return importJWK(refreshedJwk, refreshedJwk.alg ?? "RS256");
}

async function getJwks(fetchImpl: FetchImpl): Promise<CachedJwks> {
  if (cachedJwks && cachedJwks.expiresAt > Date.now()) {
    return cachedJwks;
  }
  return refreshJwks(fetchImpl);
}

async function refreshJwks(fetchImpl: FetchImpl): Promise<CachedJwks> {
  let response: Response;
  try {
    response = await fetchImpl(googleSecureTokenJwksUrl);
  } catch {
    throw new AiGatewayError(
      "unauthenticated",
      "Authentication keys are unavailable.",
      401,
    );
  }

  if (!response.ok) {
    throw new AiGatewayError(
      "unauthenticated",
      "Authentication keys are unavailable.",
      401,
    );
  }

  const decoded = (await response.json()) as { keys?: JWK[] };
  const keys = new Map<string, JWK>();
  for (const jwk of decoded.keys ?? []) {
    if (typeof jwk.kid === "string") {
      keys.set(jwk.kid, jwk);
    }
  }

  cachedJwks = {
    expiresAt: resolveExpiresAt(response.headers),
    keys,
  };
  return cachedJwks;
}

function resolveExpiresAt(headers: Headers): number {
  const cacheControl = headers.get("cache-control");
  const maxAgeMatch = cacheControl?.match(/max-age=(\d+)/i);
  if (maxAgeMatch?.[1]) {
    return Date.now() + Number.parseInt(maxAgeMatch[1], 10) * 1000;
  }

  const expires = headers.get("expires");
  if (expires) {
    const parsed = Date.parse(expires);
    if (!Number.isNaN(parsed) && parsed > Date.now()) {
      return parsed;
    }
  }

  return Date.now() + fallbackTtlMs;
}
