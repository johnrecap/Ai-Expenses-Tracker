# Feature Specification: Cloudflare AI Gateway

**Feature Branch**: `018-cloudflare-ai-gateway`
**Created**: 2026-05-16
**Status**: Draft
**Input**: User request: "Create a full Spec Kit plan and detailed tasks to replace Firebase Functions AI gateway with a free-plan Cloudflare Worker bridge while keeping Firebase Spark."

## User Scenarios & Testing

### User Story 1 - Free AI Gateway Without Firebase Blaze (Priority: P1)

As an app owner who wants to keep Firebase on the free Spark plan, I want provider-backed AI requests to go through a Cloudflare Worker instead of Firebase Functions, so the app can use Gemini without requiring Firebase Blaze.

**Why this priority**: This is the blocking business requirement. Firebase Functions deployment requires Blaze, and the user explicitly wants the Firebase side to remain free.

**Independent Test**: Deploy only the text AI endpoint to Cloudflare, build the app with the worker `aiParse` URL, sign in with Firebase Auth, type "صرفت 250 جنيه على أكل امبارح بالكاش", and verify the app receives a structured editable preview without Firebase Functions enabled.

**Acceptance Scenarios**:

1. **Given** the app is signed in with Firebase Auth and the Cloudflare Worker has a Gemini secret configured, **When** the user sends a natural-language expense command, **Then** the worker verifies the Firebase token and returns a structured JSON response compatible with the current Flutter parser.
2. **Given** Firebase remains on Spark and no Firebase Functions are deployed, **When** the user uses AI text parsing, **Then** the request succeeds through Cloudflare and does not require enabling Firebase Blaze.
3. **Given** the Cloudflare Worker is not configured or unavailable, **When** the user opens the AI Assistant, **Then** the app keeps the deterministic mock/local fallback behavior and the rest of the expense tracker remains usable.

---

### User Story 2 - Protected Gemini Secret And Verified Users (Priority: P1)

As the app owner, I want Gemini API keys to stay on the server side and every AI request to be tied to a verified Firebase user, so users cannot extract the provider key from the APK and anonymous traffic cannot consume quota.

**Why this priority**: A direct Flutter-to-Gemini call exposes the key. A gateway without token verification is vulnerable to public abuse.

**Independent Test**: Call the worker endpoint with no token, an invalid token, and a valid Firebase ID token. Verify only the valid token reaches the provider path.

**Acceptance Scenarios**:

1. **Given** a request has no `Authorization: Bearer <token>` header, **When** it reaches the worker, **Then** the worker returns `ok: false`, `errorCode: unauthenticated`, and does not call Gemini.
2. **Given** a request has a token from another project, **When** it reaches the worker, **Then** the worker rejects it because issuer and audience do not match the configured Firebase project.
3. **Given** a request has a valid Firebase ID token for `ai-expenses-tracker-studio`, **When** the worker validates it, **Then** the worker extracts the user id and uses it for per-user quota counting.

---

### User Story 3 - Free-Plan Daily AI Quotas Per User (Priority: P1)

As the app owner, I want each free user to have small daily AI limits, so the shared Gemini free quota is protected without a project-wide limit that blocks all users.

**Why this priority**: The user rejected global daily limits because they can shut down the feature for everyone when the user base grows.

**Independent Test**: Configure text parse limit to 5/day, receipt limit to 3/day, advice limit to 3/day, then send requests as two different users and verify each user has independent counters.

**Acceptance Scenarios**:

1. **Given** a free user has used 4 text parse requests today, **When** they send one more text parse request, **Then** the request is allowed and the response includes 0 remaining text parse requests.
2. **Given** a free user has used 5 text parse requests today, **When** they send another text parse request, **Then** the worker returns `quota_exceeded` before calling Gemini.
3. **Given** user A has exhausted text parse quota, **When** user B sends their first text parse request on the same day, **Then** user B is allowed because quotas are per-user.
4. **Given** the project owner has not configured a global emergency limit, **When** total project usage grows, **Then** no project-wide counter blocks all users.

---

### User Story 4 - Receipt Extraction And Financial Advice Through The Same Worker (Priority: P2)

As a user, I want receipt image extraction and AI financial advice to continue working through the same AI gateway, so all provider-backed AI features use one secure free-plan-compatible backend.

**Why this priority**: Text parsing is the MVP, but the current app already has receipt extraction and advice paths that expect `aiReceipt` and `aiAdvice` endpoints.

**Independent Test**: After text parsing works, call `/aiReceipt` with a compressed test image payload and `/aiAdvice` with a spending summary, then verify both return structured JSON or clear quota/unavailable errors.

**Acceptance Scenarios**:

1. **Given** a signed-in user has remaining receipt quota, **When** they submit a receipt image, **Then** the worker returns amount/date/merchant/category/currency/confidence fields without storing the raw image.
2. **Given** a signed-in user has remaining advice quota, **When** they request advice for the current period, **Then** the worker returns short grounded advice based only on the provided spending summary.
3. **Given** receipt or advice quota is exhausted, **When** the user repeats the request, **Then** no provider call is made and the app shows the existing AI unavailable/quota fallback.

---

### User Story 5 - Deployable Documentation And Safe Operations (Priority: P2)

As a future developer or AI agent, I want exact setup, deploy, secrets, testing, rollback, and build instructions, so the gateway can be maintained without guessing or leaking secrets.

**Why this priority**: The user explicitly requested a detailed plan and tasks that any developer or AI agent can follow later.

**Independent Test**: A new developer follows only `quickstart.md` and `tasks.md`, creates a Cloudflare Worker, adds secrets, deploys, and builds an APK that uses the worker.

**Acceptance Scenarios**:

1. **Given** the developer has a Gemini key, Firebase project id, and Cloudflare account, **When** they follow the quickstart, **Then** they can deploy the worker without Firebase Blaze.
2. **Given** the worker URL is known, **When** the developer builds the Flutter APK with `AI_GATEWAY_URL`, **Then** Flutter calls the worker and still does not store provider secrets.
3. **Given** a deployment fails, **When** the developer reads the operations notes, **Then** they can identify whether the issue is Firebase token verification, Cloudflare secret config, Gemini quota, D1 binding, or app build configuration.

### Edge Cases

- Firebase Auth token is expired, malformed, missing, from another Firebase project, or signed by an unexpected key.
- Google Secure Token public keys rotate while worker instances still cache old keys.
- Gemini returns prose, markdown, blocked content, rate limit, timeout, invalid JSON, or a schema-incompatible object.
- Cloudflare D1 quota storage is unavailable, slow, or not bound in the deployed environment.
- A user changes device time; quota must use server-side UTC date, not client-side date.
- Worker receives a receipt image that is too large, unsupported MIME type, empty, or fails base64 validation.
- Worker receives an advice request with missing or untrusted spending summary fields.
- The worker endpoint is public; non-app callers may attempt abuse with forged requests.
- Cloudflare free tier or Gemini free tier changes; the app must keep fallback behavior.
- The app is built without `AI_GATEWAY_URL`; mock/local mode must still work.

## Requirements

### Functional Requirements

- **FR-001**: The system MUST provide a Cloudflare Worker gateway with `aiParse`, `aiReceipt`, and `aiAdvice` endpoints matching the existing Flutter gateway response contract.
- **FR-002**: The system MUST keep Firebase on the Spark plan by avoiding Firebase Functions for the AI gateway path.
- **FR-003**: The system MUST keep Gemini API keys and any provider secrets outside Flutter source, assets, platform config, generated APK, Firestore, and client preferences.
- **FR-004**: The system MUST verify Firebase ID tokens server-side before any provider-backed AI request reaches Gemini.
- **FR-005**: The system MUST validate token issuer and audience against `ai-expenses-tracker-studio` unless environment configuration explicitly changes the Firebase project id.
- **FR-006**: The system MUST reject unauthenticated or invalid-token requests with normalized JSON errors and zero provider calls.
- **FR-007**: The system MUST enforce per-user daily quotas by request type before provider calls: text parse default 5/day, receipt extraction default 3/day, financial advice default 3/day.
- **FR-008**: The system MUST NOT apply a project-wide global quota by default.
- **FR-009**: The system MAY support optional emergency project-wide limits only when explicitly configured, and those limits must be documented as optional safeguards, not free-plan defaults.
- **FR-010**: The system MUST use server-side UTC dates for quota reset keys.
- **FR-011**: The system MUST return quota status fields that Flutter can display, including limit, used, remaining, reset time, and request type.
- **FR-012**: The system MUST call Gemini 2.5 Flash by default for provider-backed text parsing, receipt extraction, and financial advice.
- **FR-013**: The worker MUST request structured JSON output and validate or normalize provider output before returning it to Flutter.
- **FR-014**: Text parse responses MUST preserve the existing structured fields expected by `AiResponseParser`, including intent, amount, category, date, paymentMethod, description, confidence, and needsConfirmation where relevant.
- **FR-015**: Receipt responses MUST include amount, date, merchant, category, currency, confidence, and needsConfirmation when extraction succeeds.
- **FR-016**: Advice responses MUST be short, based only on the provided spending summary, and must not invent transactions.
- **FR-017**: The system MUST preserve the existing preview and confirmation-first AI safety model in Flutter; no gateway response may directly create, update, or delete Firestore data.
- **FR-018**: The system MUST keep deterministic local features working when AI is unavailable, including manual expense entry, reports, filters, local prediction, and repeated expense detection.
- **FR-019**: The worker MUST not store raw receipt images in durable storage or logs.
- **FR-020**: Usage logs MUST avoid provider secrets, raw authorization headers, and full raw receipt images.
- **FR-021**: The worker MUST expose clear error codes compatible with current Flutter error handling: unauthenticated, quota_exceeded, rate_limited, provider_timeout, provider_unavailable, invalid_provider_output, gateway_misconfigured, invalid_request.
- **FR-022**: The implementation MUST include automated tests for auth rejection, quota enforcement, endpoint contracts, provider output parsing, and no-provider-call-on-quota-exceeded behavior.
- **FR-023**: The quickstart MUST document Cloudflare account setup, D1 database creation, secrets, deployment, worker URL, Flutter build command, verification, and rollback.
- **FR-024**: The Firebase Functions gateway may remain in the repository for future paid backend use, but the free-plan build path MUST use Cloudflare Worker.
- **FR-025**: The worker MUST support CORS for web builds while still requiring Authorization for protected endpoints.

### Key Entities

- **AI Gateway Request**: A client request sent from Flutter to the worker, containing request-specific input, client context, locale, default currency, and Firebase ID token in the Authorization header.
- **Verified Firebase User**: The user identity derived from a valid Firebase ID token after issuer, audience, signature, and expiry validation.
- **Daily AI Usage Counter**: Per-user, per-request-type, per-UTC-day counter used to enforce free limits.
- **AI Gateway Response**: Normalized response object with `ok`, provider/model metadata, requestId, quota status, and structuredJson or error fields.
- **Provider Secret**: Gemini API key and any future provider credentials stored only in Cloudflare secrets.
- **Receipt Extraction Payload**: Structured receipt interpretation without persistent raw image storage.
- **Financial Advice Payload**: Short grounded advice derived from app-provided aggregates.

## Success Criteria

### Measurable Outcomes

- **SC-001**: A signed-in user can receive a structured text-expense AI preview through Cloudflare while Firebase remains on Spark.
- **SC-002**: 100% of unauthenticated and invalid-token requests are rejected before any provider call in automated tests.
- **SC-003**: Per-user text parse quota blocks the 6th same-day request for the same user when the limit is 5, while allowing another user on their own quota.
- **SC-004**: Receipt and advice requests block after their configured daily user limits without calling Gemini.
- **SC-005**: Gemini API key does not appear in Flutter source, generated app config, Firestore rules, quickstart examples, or task files.
- **SC-006**: Worker contract tests cover successful and failed responses for all three endpoint types.
- **SC-007**: Existing Flutter AI Gateway client can point at the worker URL with `AI_GATEWAY_URL` and does not require widget-layer changes for the endpoint names.
- **SC-008**: A new developer can follow quickstart instructions and identify the deployed `aiParse` URL in under 30 minutes after having Cloudflare and Gemini accounts ready.
- **SC-009**: When Cloudflare or Gemini is unavailable, the app still allows manual expenses and local insights with a clear fallback message.

## Assumptions

- Firebase Auth and Firestore remain hosted on Firebase Spark.
- Firebase Functions deployment is intentionally avoided for the free-plan path.
- Cloudflare Workers free tier is acceptable for early testing, but not guaranteed to remain unchanged forever.
- Cloudflare D1 is selected for daily usage counters because quota enforcement should be more consistent than eventually consistent edge KV counters.
- Flutter already has `AiGatewayClient`, `GatewayAiService`, and `AI_GATEWAY_URL` configuration that can call a compatible HTTP gateway.
- The worker will return the same endpoint naming convention as the Firebase Functions gateway: base `aiParse`, sibling `aiReceipt`, and sibling `aiAdvice`.
- Premium plans are out of scope for this feature, but the quota model must be extensible to plan-based limits later.
- The app owner will manually create or authorize Cloudflare resources and add secrets; secrets will not be committed to the repository.
