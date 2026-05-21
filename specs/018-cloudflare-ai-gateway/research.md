# Research: Cloudflare AI Gateway

## Decision 1: Use Cloudflare Worker Instead Of Firebase Functions For Free-Plan AI Gateway

**Decision**: Implement a Cloudflare Worker HTTP gateway for provider-backed AI requests and leave Firebase Functions unused for the free-plan build path.

**Rationale**:

- Firebase Functions deployment is blocked while the Firebase project remains on Spark.
- The existing Flutter app already sends authenticated HTTP requests to a configurable gateway URL.
- A Worker can keep the Gemini API key server-side while the app continues using Firebase Auth and Firestore.
- The current Firebase Functions TypeScript gateway already contains useful prompting, schema, quota, and normalized error behavior that can be ported.

**Alternatives considered**:

- Direct Gemini calls from Flutter: rejected because the provider key would be extractable from the APK and would make commercial free/premium separation weak.
- Firebase Functions: technically already implemented, but rejected for this feature because the user requires Firebase to remain free/Spark.
- Separate VPS/backend: rejected because it adds hosting cost and operational burden.

## Decision 2: Keep Firebase Auth As The Identity Source

**Decision**: Flutter continues to sign users in with Firebase Auth, then sends the Firebase ID token to the Worker in `Authorization: Bearer <token>`.

**Rationale**:

- The app already has working Firebase Authentication and `AuthRepository.getIdToken()`.
- Existing repositories and Firestore rules depend on Firebase user ids.
- User-scoped quota counters should use the same user id as Firestore data ownership.

**Implementation note**: Firebase Admin SDK should not be used inside the Worker. The Worker should verify Firebase Secure Token JWTs by checking issuer, audience, expiry, signature, and Google Secure Token public keys.

**Alternatives considered**:

- Cloudflare Access identity: rejected because it would add a second login system.
- Anonymous gateway key: rejected because it cannot enforce per-user limits safely.

## Decision 3: Use Cloudflare D1 For Usage Counters

**Decision**: Use Cloudflare D1 for per-user daily usage counters and safe usage logs.

**Rationale**:

- Quota enforcement needs consistent increment-and-check behavior.
- Cloudflare KV is eventually consistent and can allow quota race conditions.
- D1 is a better fit for rows keyed by `userId + requestType + dateKey`.

**Alternatives considered**:

- Cloudflare KV: acceptable for non-critical cache, but rejected for authoritative quotas.
- In-memory counters: rejected because Worker instances are ephemeral and distributed.
- Firestore counters: would require the Worker to write to Firestore from server credentials, increasing complexity and secret handling.

## Decision 4: Do Not Apply Global Project Limits By Default

**Decision**: Enforce only per-user daily free limits by default: text parse 5/day, receipt extraction 3/day, advice 3/day. Project-wide global limits remain optional emergency settings.

**Rationale**:

- The user explicitly rejected global limits that can shut down AI for every user as the user base grows.
- Per-user limits are the correct free-plan product rule.
- Provider rate limits still exist externally and must be handled gracefully.

**Alternatives considered**:

- Low project-wide global limits: rejected by user.
- Unlimited per-user calls: rejected because it can exhaust Gemini free quota quickly.

## Decision 5: Preserve Existing Flutter Gateway Contract

**Decision**: The Worker must return the same response shape as the Firebase Functions gateway:

- `ok: true`, provider/model/requestId/usage/quota, and `structuredJson` on success.
- `ok: false`, provider/model/requestId/errorCode/errorMessage on failure.

**Rationale**:

- Flutter already has `AiGatewayClient`, `GatewayAiService`, `GatewayReceiptAiService`, and `GatewayFinancialAdviceAiService`.
- Keeping the contract avoids risky UI refactors.
- The existing endpoint replacement logic expects a base `aiParse` path and sibling `aiReceipt`/`aiAdvice` paths.

**Alternatives considered**:

- Introduce new Flutter service for Cloudflare: rejected because it duplicates gateway code.
- Use Cloudflare-specific response format: rejected because it breaks parser and tests.

## Decision 6: Keep Firebase Functions Code As Optional Future Backend

**Decision**: Do not delete the existing `functions/` code in this feature. Mark Cloudflare Worker as the free-plan gateway path and leave Firebase Functions as a future paid/backend option.

**Rationale**:

- The Firebase Functions code is tested and may be useful later for premium or production backend migration.
- Removing it now would create unnecessary churn and risk.
- The key product requirement is to avoid deploying Firebase Functions on the free path, not to erase the implementation.

**Alternatives considered**:

- Delete `functions/`: rejected due to loss of tested gateway logic.
- Keep both live simultaneously: rejected for MVP because it creates operational confusion.

## Premium Extension Notes

Premium is intentionally out of scope for this free-plan gateway. Future premium work should add a reliable user-plan source of truth before changing quota behavior.

Supported future options:

- Firebase Auth Custom Claims: fast to read from the ID token, good for coarse plans such as `free` and `premium`, but requires an admin backend or trusted admin workflow to set claims.
- Firestore user profile plan field: simple to manage with the existing Firebase data model, but the Worker would need a server-side read path or a signed plan snapshot to avoid trusting client input.
- Cloudflare D1 subscription table: keeps quota decisions inside the Worker, but creates a second source of truth that must be synchronized with billing.

Future premium implementation should map `plan -> request-type limits` instead of hardcoding one set of env-only limits. The free defaults remain text parse 5/day, receipt extraction 3/day, and advice 3/day per user.
