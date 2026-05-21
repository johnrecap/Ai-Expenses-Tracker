# Tasks: Cloudflare AI Gateway

**Input**: Design documents from `specs/018-cloudflare-ai-gateway/`
**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/worker-api.md`, `contracts/worker-env.md`, `quickstart.md`

**Implementation Intent**: Add a Cloudflare Worker AI gateway that keeps Firebase on Spark, stores Gemini secrets server-side, verifies Firebase Auth tokens, enforces per-user daily free limits, and preserves the existing Flutter AI Gateway contract.

**Critical Safety Rules**:

- Do not deploy Firebase Functions for this free-plan path.
- Do not put Gemini or provider API keys in Flutter, Firestore, Android/iOS config, docs examples, or committed files.
- Do not let the Worker write expenses, categories, budgets, or any user app data.
- Do not bypass `AiResponseParser`.
- Do not bypass preview/confirmation for add/update/delete.
- Do not apply global project-wide limits by default.
- Do not store raw receipt images or authorization headers in logs.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel because it touches different files and has no dependency on incomplete tasks.
- **[Story]**: Maps to the user story in `spec.md`.
- Each task includes exact files, detailed steps, verification, and done criteria.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Create the Cloudflare Worker workspace, package scripts, config files, ignore rules, and D1 migration structure.

- [X] T001 Create Worker workspace directory structure in `workers/ai-gateway/`.

  **Detailed steps**:
  1. Create `workers/ai-gateway/src/`.
  2. Create `workers/ai-gateway/src/http/`.
  3. Create `workers/ai-gateway/src/auth/`.
  4. Create `workers/ai-gateway/src/ai/`.
  5. Create `workers/ai-gateway/src/quota/`.
  6. Create `workers/ai-gateway/src/handlers/`.
  7. Create `workers/ai-gateway/test/`.
  8. Create `workers/ai-gateway/migrations/`.

  **Done when**: The folder tree matches the plan and contains no generated secrets.

- [X] T002 Create Worker package manifest in `workers/ai-gateway/package.json`.

  **Detailed steps**:
  1. Set package name to `ai-expenses-gateway`.
  2. Set `"private": true`.
  3. Set module type to ESM if using TypeScript modules.
  4. Add scripts: `dev`, `deploy`, `test`, `typecheck`, `migrate:local`, `migrate:remote`.
  5. Add runtime dependency for JWT verification, such as `jose`.
  6. Add dev dependencies: `wrangler`, `typescript`, `vitest` or selected test runner.
  7. Do not add Firebase Admin SDK unless a later task proves it works in Workers.

  **Done when**: `npm install` can install the Worker project independently from Flutter and Firebase Functions.

- [X] T003 Create TypeScript config in `workers/ai-gateway/tsconfig.json`.

  **Detailed steps**:
  1. Target modern JavaScript supported by Cloudflare Workers.
  2. Use strict type checking.
  3. Include `src/**/*.ts` and `test/**/*.ts`.
  4. Exclude `node_modules` and generated worker build output.
  5. Ensure module resolution works with Wrangler.

  **Done when**: `npm run typecheck` can type-check Worker source and tests.

- [X] T004 Create Worker config in `workers/ai-gateway/wrangler.toml`.

  **Detailed steps**:
  1. Set `name = "ai-expenses-gateway"`.
  2. Set `main = "src/index.ts"`.
  3. Set a current `compatibility_date`.
  4. Add `[vars]` with `FIREBASE_PROJECT_ID = "ai-expenses-tracker-studio"`.
  5. Add `AI_PROVIDER = "gemini"`.
  6. Add `AI_MODEL = "gemini-2.5-flash"`.
  7. Add `AI_PARSE_DAILY_USER_LIMIT = "5"`.
  8. Add `AI_RECEIPT_DAILY_USER_LIMIT = "3"`.
  9. Add `AI_ADVICE_DAILY_USER_LIMIT = "3"`.
  10. Add a temporary D1 binding named `AI_DB`; leave `database_id` clearly marked for replacement after `wrangler d1 create`.
  11. Do not add `GEMINI_API_KEY` to `wrangler.toml`.
  12. Do not add global daily limits by default.

  **Done when**: Config reflects the free-plan limits and requires secrets through `wrangler secret put`.

- [X] T005 Create Worker git ignore rules in `workers/ai-gateway/.gitignore`.

  **Detailed steps**:
  1. Ignore `node_modules/`.
  2. Ignore `.wrangler/`.
  3. Ignore `.dev.vars`.
  4. Ignore `.env`.
  5. Ignore coverage output.
  6. Do not ignore source, tests, migrations, or `wrangler.toml`.

  **Done when**: Local secrets and generated Worker artifacts cannot be committed accidentally.

- [X] T006 Create D1 migration in `workers/ai-gateway/migrations/0001_ai_usage.sql`.

  **Detailed steps**:
  1. Create `ai_usage_daily` table with fields from `data-model.md`.
  2. Use primary key `(date_key, uid, request_type, provider, model)`.
  3. Create `ai_usage_logs` table with safe diagnostic fields.
  4. Add index for `ai_usage_logs(date_key, uid, request_type)`.
  5. Do not create tables for expense/user app data.

  **Done when**: Migration can initialize D1 quota and usage logging only.

- [X] T007 [P] Add Worker README or operations note in `workers/ai-gateway/README.md`.

  **Detailed steps**:
  1. Explain that this Worker is the free-plan AI gateway.
  2. Explain that Firebase Functions remain optional future backend only.
  3. List required secrets and vars.
  4. List test, migration, deploy, and rollback commands.
  5. Link back to `specs/018-cloudflare-ai-gateway/quickstart.md`.

  **Done when**: A new worker can understand the Worker purpose without reading all specs first.

**Checkpoint**: Worker project skeleton exists and can be installed without touching Flutter or Firebase Functions.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Build shared config, response, CORS, auth, quota, and provider foundations required before any endpoint story.

**CRITICAL**: No user story endpoint should call Gemini until this phase is complete.

- [X] T008 Implement environment config parsing in `workers/ai-gateway/src/config.ts`.

  **Detailed steps**:
  1. Define a typed `WorkerEnv` interface for bindings and variables.
  2. Include `AI_DB`, `GEMINI_API_KEY`, `FIREBASE_PROJECT_ID`, `AI_PROVIDER`, `AI_MODEL`, and request limits.
  3. Parse integer limits with defaults: parse 5, receipt 3, advice 3.
  4. Treat optional global limits as undefined when missing.
  5. Throw or return `gateway_misconfigured` for missing `GEMINI_API_KEY`, missing `AI_DB`, or missing Firebase project id.
  6. Do not expose secret values in thrown messages.

  **Done when**: Handlers can load validated config without duplicating env parsing.

- [X] T009 [P] Implement normalized JSON responses in `workers/ai-gateway/src/http/response.ts`.

  **Detailed steps**:
  1. Add `jsonResponse(body, status)` helper.
  2. Always include `Content-Type: application/json`.
  3. Add safe success response builder matching `contracts/worker-api.md`.
  4. Add safe error response builder matching current Flutter `AiGatewayClient` expected fields.
  5. Ensure error responses include provider/model/requestId/errorCode/errorMessage.
  6. Never include stack traces, secrets, raw token, or raw provider body in user responses.

  **Done when**: All handlers can return a consistent contract-compatible response.

- [X] T010 [P] Implement CORS handling in `workers/ai-gateway/src/http/cors.ts`.

  **Detailed steps**:
  1. Add `corsHeaders()` with `Access-Control-Allow-Origin`.
  2. Add allowed methods `POST, OPTIONS`.
  3. Add allowed headers `Authorization, Content-Type`.
  4. Add `handleOptions()` for preflight.
  5. Keep CORS permissive for web builds, but do not treat CORS as authentication.

  **Done when**: `OPTIONS` returns headers and protected `POST` still requires Firebase token.

- [X] T011 [P] Define shared provider/gateway types in `workers/ai-gateway/src/ai/providerTypes.ts`.

  **Detailed steps**:
  1. Define `AiRequestType` union: `parse_text`, `receipt_extraction`, `financial_advice`.
  2. Define `AiGatewayErrorCode` union matching the spec.
  3. Define `AiGatewayError` class with code, safe message, and status.
  4. Define provider usage type with optional `inputTokens` and `outputTokens`.
  5. Define provider result types for parse, receipt, and advice.
  6. Define minimal request DTOs for handlers.

  **Done when**: Auth, quota, provider, and handlers share one error/type vocabulary.

- [X] T012 [P] Implement Google Secure Token key cache in `workers/ai-gateway/src/auth/googleJwksCache.ts`.

  **Detailed steps**:
  1. Fetch Google Secure Token public keys/JWKS from Google's official endpoint.
  2. Cache keys in module-level memory with expiration from response headers when available.
  3. Fall back to a short safe TTL when cache headers are unavailable.
  4. Refetch keys when token `kid` is unknown.
  5. Return normalized auth errors when keys cannot be fetched.
  6. Do not log raw tokens.

  **Done when**: Token verifier can retrieve signing keys without fetching on every request.

- [X] T013 Implement Firebase token verification in `workers/ai-gateway/src/auth/firebaseTokenVerifier.ts`.

  **Detailed steps**:
  1. Read bearer token from `Authorization` header.
  2. Reject missing or malformed header with `unauthenticated`.
  3. Decode token header to obtain `kid`.
  4. Verify JWT signature using cached Google Secure Token public keys.
  5. Verify issuer equals `https://securetoken.google.com/{FIREBASE_PROJECT_ID}`.
  6. Verify audience equals `{FIREBASE_PROJECT_ID}`.
  7. Verify expiry is in the future.
  8. Extract `uid` from `sub`.
  9. Reject empty `sub`.
  10. Return `uid` and safe optional claims.

  **Done when**: Any handler can obtain a verified Firebase user id or fail before quota/provider calls.

- [X] T014 [P] Add auth tests in `workers/ai-gateway/test/auth.test.ts`.

  **Detailed steps**:
  1. Test missing authorization header returns `unauthenticated`.
  2. Test non-bearer header returns `unauthenticated`.
  3. Test wrong issuer is rejected.
  4. Test wrong audience is rejected.
  5. Test expired token is rejected.
  6. Test valid mocked token returns `uid`.
  7. Mock JWK/key behavior; do not require internet for tests.

  **Done when**: Auth verification behavior is covered without calling Gemini.

- [X] T015 Implement quota service in `workers/ai-gateway/src/quota/quotaService.ts`.

  **Detailed steps**:
  1. Accept D1 database binding.
  2. Accept `uid`, server `dateKey`, request type, provider, model, and limit.
  3. Read current usage row.
  4. If current usage is at or above user limit, throw `quota_exceeded`.
  5. Increment usage safely before provider call to prevent retries from bypassing quota.
  6. Return quota status: requestType, allowed, limit, used, remaining, resetAt.
  7. Do not check global limits unless explicitly configured.
  8. Implement optional global limit support behind explicit config only.
  9. Use UTC server date for `dateKey`.

  **Done when**: Quota is server-side, per-user, per-request-type, and blocks before provider calls.

- [X] T016 [P] Add quota tests in `workers/ai-gateway/test/quota.test.ts`.

  **Detailed steps**:
  1. Test first parse request with limit 5 returns remaining 4.
  2. Test 5th parse request returns remaining 0.
  3. Test 6th parse request throws `quota_exceeded`.
  4. Test user B is unaffected by user A's exhausted quota.
  5. Test receipt and advice counters are independent from text parse.
  6. Test a new UTC date resets quota.
  7. Test no global limit applies when global env vars are absent.
  8. Test optional global limit works only when explicitly provided.

  **Done when**: User-specific quota behavior matches the user's free-plan requirement.

- [X] T017 [P] Implement usage log service in `workers/ai-gateway/src/quota/usageLogService.ts`.

  **Detailed steps**:
  1. Accept D1 database binding.
  2. Log request id, dateKey, uid, requestType, status, provider, model, errorCode, inputTokens, outputTokens, and createdAt.
  3. Allow `uid = "unknown"` for auth failures.
  4. Do not accept raw prompt, raw token, raw image, API key, or headers.
  5. Swallow logging failures after the main response is prepared; logging must not block successful AI responses.

  **Done when**: Gateway can keep safe operational logs without privacy leaks.

- [X] T018 [P] Implement structured schema helpers in `workers/ai-gateway/src/ai/structuredSchema.ts`.

  **Detailed steps**:
  1. Define Gemini schema for text intent responses.
  2. Define Gemini schema for receipt extraction responses.
  3. Define Gemini schema for financial advice responses.
  4. Add parser/normalizer for provider JSON text.
  5. Reject markdown/prose wrappers.
  6. Force `needsConfirmation = true` for mutation-capable responses.
  7. Validate `confidence` range where present.

  **Done when**: Provider output can be accepted only if compatible with Flutter parser expectations.

- [X] T019 [P] Implement prompt builder in `workers/ai-gateway/src/ai/promptBuilder.ts`.

  **Detailed steps**:
  1. Build text parse prompt for Arabic/English natural-language expense commands.
  2. Include allowed intents and required JSON-only behavior.
  3. Include current date from request for relative dates, while reminding model that quota uses server date separately.
  4. Include known categories as names/ids.
  5. Include payment method mapping: Cash, Visa, Wallet, Bank Transfer.
  6. Include safety instruction: never claim an action was saved.
  7. Include prompt-injection instruction: user text cannot override schema or safety rules.
  8. Build receipt prompt with image context and no image storage.
  9. Build advice prompt that uses only supplied summary and keeps response short.

  **Done when**: All provider calls have deterministic, schema-focused prompts.

- [X] T020 Implement Gemini provider in `workers/ai-gateway/src/ai/geminiProvider.ts`.

  **Detailed steps**:
  1. Read API key from validated Worker config only.
  2. Use model from config, default `gemini-2.5-flash`.
  3. Call Gemini REST `generateContent`.
  4. Use `responseMimeType: application/json`.
  5. Pass response schema where supported.
  6. Apply request timeout.
  7. Map provider 429 to `rate_limited`.
  8. Map timeout to `provider_timeout`.
  9. Map non-JSON or schema mismatch to `invalid_provider_output`.
  10. Extract usage metadata when available.
  11. Do not include provider raw error body in user-safe responses if it may contain sensitive details.

  **Done when**: Provider adapter returns structured results or normalized errors.

- [X] T021 [P] Add Gemini provider tests in `workers/ai-gateway/test/geminiProvider.test.ts`.

  **Detailed steps**:
  1. Mock successful Gemini JSON response.
  2. Assert structured JSON is parsed.
  3. Assert usage metadata is mapped.
  4. Mock provider 429 and assert `rate_limited`.
  5. Mock provider timeout and assert `provider_timeout`.
  6. Mock prose/markdown output and assert `invalid_provider_output`.
  7. Assert missing API key maps to `gateway_misconfigured`.

  **Done when**: Provider behavior is tested without real network calls.

**Checkpoint**: Auth, quota, response contract, prompt/schema, and provider foundations are ready. Endpoints can now be implemented safely.

---

## Phase 3: User Story 1 - Free Text AI Gateway Without Firebase Blaze (Priority: P1) MVP

**Goal**: Signed-in users can parse natural-language expense text through Cloudflare while Firebase remains Spark.

**Independent Test**: Build app with Worker `/aiParse` URL, sign in, send an Arabic expense sentence, and verify editable preview appears.

### Tests for User Story 1

- [X] T022 [P] [US1] Add parse endpoint contract tests in `workers/ai-gateway/test/parseExpense.test.ts`.

  **Detailed steps**:
  1. Test successful request returns `ok: true`.
  2. Test response includes provider, model, requestId, quota, and structuredJson.
  3. Test empty input returns `invalid_request`.
  4. Test missing token returns `unauthenticated`.
  5. Test quota exhausted returns `quota_exceeded`.
  6. Assert provider mock is not called for invalid request, unauthenticated request, or quota-exhausted request.

  **Done when**: `/aiParse` behavior is fully contract-tested before implementation.

### Implementation for User Story 1

- [X] T023 [US1] Implement parse request validation in `workers/ai-gateway/src/handlers/parseExpense.ts`.

  **Detailed steps**:
  1. Accept only `POST`.
  2. Parse JSON body safely.
  3. Require non-empty `input`.
  4. Validate `now` when present; default prompt context safely if missing only if contract allows.
  5. Normalize locale default `ar-EG`.
  6. Normalize default currency default `EGP`.
  7. Bound categories to safe fields only.
  8. Bound recent expenses to a safe maximum count.
  9. Reject malformed JSON with `invalid_request`.

  **Done when**: Bad text parse requests fail before auth/quota/provider where appropriate.

- [X] T024 [US1] Implement parse endpoint flow in `workers/ai-gateway/src/handlers/parseExpense.ts`.

  **Detailed steps**:
  1. Generate request id.
  2. Verify Firebase token and get uid.
  3. Load config and request type limit for `parse_text`.
  4. Consume per-user quota before provider call.
  5. Build Gemini prompt using request context.
  6. Call Gemini provider.
  7. Validate/normalize provider structured output.
  8. Log safe success usage.
  9. Return success response matching `contracts/worker-api.md`.
  10. On errors, log safe failure and return normalized failure response.

  **Done when**: `/aiParse` can serve current Flutter `AiGatewayClient.parse()`.

- [X] T025 [US1] Wire router for `/aiParse` in `workers/ai-gateway/src/index.ts`.

  **Detailed steps**:
  1. Add top-level `fetch(request, env, ctx)` export.
  2. Route `OPTIONS` to CORS handler.
  3. Route path ending in `/aiParse` to parse handler.
  4. Return `404` JSON for unknown paths.
  5. Ensure all responses include CORS headers.

  **Done when**: Local `wrangler dev` can receive `/aiParse` requests.

- [X] T026 [US1] Verify Flutter endpoint compatibility in `lib/ai/services/ai_gateway_client.dart`.

  **Detailed steps**:
  1. Confirm `_endpoint(null)` uses the exact `AI_GATEWAY_URL`.
  2. Confirm `parse()` expects `structuredJson`.
  3. Confirm error mapping covers Worker error codes.
  4. Do not change Flutter code unless the Worker contract cannot match current behavior.
  5. If code changes are needed, keep them isolated to `lib/ai/services/ai_gateway_client.dart` and related tests.

  **Done when**: Flutter can call Worker `/aiParse` using existing config behavior.

- [X] T027 [US1] Add or update Flutter gateway tests in `test/ai/ai_gateway_client_test.dart`.

  **Detailed steps**:
  1. Add a test that base URL ending `/aiParse` produces `/aiReceipt` for receipt endpoint and `/aiAdvice` for advice endpoint.
  2. Add a test that Worker-style quota response parses provider metadata.
  3. Add a test that Worker error response maps to `AiGatewayException`.
  4. Keep tests network-free using injected sender.

  **Done when**: Flutter client compatibility with Worker routing is protected.

- [ ] T028 [US1] Manually verify local parse endpoint with `wrangler dev`.

  **Status note (2026-05-16)**: Local D1 migration passed and local `wrangler dev` returned HTTP 401 for an unauthenticated `/aiParse` request after the request lifecycle fix. Authenticated provider verification could not be completed locally because the configured Gemini key is invalid and no safe local Firebase ID token was available for a successful local provider call.

  **Detailed steps**:
  1. Run local D1 migration.
  2. Run `npx wrangler dev`.
  3. Send a request to `/aiParse` with missing token and verify `unauthenticated`.
  4. Send a request with a mocked or real Firebase ID token in a safe dev setup.
  5. Verify response is JSON and contract-compatible.
  6. Do not paste Gemini key into command history if avoidable; use secrets/dev vars.

  **Done when**: `/aiParse` works locally without Firebase Functions.

**Checkpoint**: Text AI gateway MVP is independently deployable and testable.

---

## Phase 4: User Story 2 - Protected Secret And Verified Users (Priority: P1)

**Goal**: Ensure the Worker is not an open proxy and the Gemini key cannot be extracted from the app.

**Independent Test**: Abuse-style calls without valid Firebase ID tokens never reach provider mock.

### Tests for User Story 2

- [X] T029 [P] [US2] Add security contract tests in `workers/ai-gateway/test/contract.test.ts`.

  **Detailed steps**:
  1. Test all three endpoints reject missing auth.
  2. Test all three endpoints reject wrong-project token.
  3. Test rejected requests do not call provider mock.
  4. Test error response does not include raw token.
  5. Test error response does not include `GEMINI_API_KEY`.

  **Done when**: Authentication is enforced consistently across endpoint types.

### Implementation for User Story 2

- [X] T030 [US2] Add request lifecycle guard in `workers/ai-gateway/src/index.ts`.

  **Detailed steps**:
  1. Ensure every protected POST route goes through token verification inside its handler.
  2. Do not create any unprotected provider route.
  3. Keep health/404 routes provider-free.
  4. Ensure OPTIONS routes do not call auth or provider.

  **Done when**: There is no path from public request to Gemini without auth and quota.

- [X] T031 [US2] Add secret safety checks in `workers/ai-gateway/test/contract.test.ts`.

  **Detailed steps**:
  1. Scan Worker source fixtures or response output in tests for accidental secret echo.
  2. Assert `GEMINI_API_KEY` value from test env never appears in success response.
  3. Assert provider raw request URL with key is not returned in errors.
  4. Assert logs service accepts no raw auth header fields.

  **Done when**: Tests protect against common key leakage paths.

- [X] T032 [US2] Update repository root `.gitignore` if needed to protect Worker secrets.

  **Files**: `.gitignore`

  **Detailed steps**:
  1. Confirm `.env` and `.env.*` are already ignored.
  2. Add `workers/**/.dev.vars` if not already covered.
  3. Add `workers/**/.wrangler/`.
  4. Do not ignore committed source/config files needed by future workers.

  **Done when**: Cloudflare local secret files are ignored at root and Worker level.

- [X] T033 [US2] Document secret setup in `workers/ai-gateway/README.md`.

  **Detailed steps**:
  1. Explain `npx wrangler secret put GEMINI_API_KEY`.
  2. Explain not to put the key in Flutter or `wrangler.toml`.
  3. Explain local `.dev.vars` is for local development only and ignored.
  4. Explain rotating the key if it was accidentally exposed.

  **Done when**: Secret management is explicit and safe.

**Checkpoint**: Gateway rejects unauthenticated traffic and secrets are server-side only.

---

## Phase 5: User Story 3 - Per-User Daily Free Quotas (Priority: P1)

**Goal**: Enforce free-plan daily limits per user without default global blockers.

**Independent Test**: User A can exhaust quota without blocking user B.

### Tests for User Story 3

- [X] T034 [P] [US3] Add per-user quota endpoint tests in `workers/ai-gateway/test/quota.test.ts`.

  **Detailed steps**:
  1. Use the parse handler with limit 5.
  2. Send 5 requests as user A.
  3. Verify 6th request as user A returns `quota_exceeded`.
  4. Send 1 request as user B.
  5. Verify user B succeeds.
  6. Assert provider mock called exactly 6 total successful calls, not 7.

  **Done when**: User-specific quota behavior is enforced end-to-end.

- [X] T035 [P] [US3] Add request-type quota isolation tests in `workers/ai-gateway/test/quota.test.ts`.

  **Detailed steps**:
  1. Exhaust parse quota for a user.
  2. Verify receipt quota remains available.
  3. Verify advice quota remains available.
  4. Exhaust receipt and verify advice still available.
  5. Confirm all counters use the same uid but different request type keys.

  **Done when**: Request types do not consume each other's limits.

### Implementation for User Story 3

- [X] T036 [US3] Implement D1 atomic quota increment in `workers/ai-gateway/src/quota/quotaService.ts`.

  **Detailed steps**:
  1. Use D1 prepared statements.
  2. Insert a new row when no counter exists.
  3. Increment existing row only when `used < applied_limit`.
  4. Return the new `used` count.
  5. If no row was updated because limit reached, throw `quota_exceeded`.
  6. Keep dateKey in UTC.
  7. Keep request type in the primary key.

  **Done when**: Quota cannot exceed daily user limit under normal concurrent requests.

- [X] T037 [US3] Add quota status response mapping in `workers/ai-gateway/src/quota/quotaService.ts`.

  **Detailed steps**:
  1. Compute `remaining = max(limit - used, 0)`.
  2. Compute resetAt as next UTC midnight.
  3. Include `requestType`, `allowed`, `limit`, `used`, `remaining`, and `resetAt`.
  4. Return status to handlers after successful consume.
  5. Include quota status in success responses.

  **Done when**: Flutter can show remaining requests after successful AI calls.

- [X] T038 [US3] Add optional global limit support without default activation in `workers/ai-gateway/src/quota/quotaService.ts`.

  **Detailed steps**:
  1. Read optional global limits only if env vars exist and parse to positive integers.
  2. Do not create global counter rows when global limit is absent.
  3. If global limit exists, enforce it after user quota passes but before provider call.
  4. Add an explicit comment that global limits are emergency-only.
  5. Keep default free-plan behavior user-only.

  **Done when**: The user's concern about feature-wide shutdown is addressed by default behavior.

- [X] T039 [US3] Update quickstart limits in `specs/018-cloudflare-ai-gateway/quickstart.md` if implementation changes defaults.

  **Detailed steps**:
  1. Confirm parse daily user limit is 5.
  2. Confirm receipt daily user limit is 3.
  3. Confirm advice daily user limit is 3.
  4. Confirm global limits are not in default setup.
  5. Confirm troubleshooting explains `quota_exceeded`.

  **Done when**: Docs match actual Worker defaults.

**Checkpoint**: Free-plan quota behavior is correct and scalable per user.

---

## Phase 6: User Story 4 - Receipt Extraction And Financial Advice Through Worker (Priority: P2)

**Goal**: Port the remaining provider-backed AI endpoints to Cloudflare while keeping local fallback.

**Independent Test**: `/aiReceipt` and `/aiAdvice` return structured JSON or quota errors with no Firebase Functions.

### Tests for User Story 4

- [X] T040 [P] [US4] Add receipt endpoint tests in `workers/ai-gateway/test/receiptExtraction.test.ts`.

  **Detailed steps**:
  1. Test valid image request returns amount/date/category/currency/confidence.
  2. Test missing image returns `invalid_request`.
  3. Test invalid MIME type returns `invalid_request`.
  4. Test quota exhausted prevents provider call.
  5. Test provider malformed output returns `invalid_provider_output`.
  6. Assert raw image is not passed to usage log service.

  **Done when**: Receipt endpoint behavior is covered without real image provider calls.

- [X] T041 [P] [US4] Add financial advice endpoint tests in `workers/ai-gateway/test/financialAdvice.test.ts`.

  **Detailed steps**:
  1. Test valid monthly summary returns short advice payload.
  2. Test missing summary returns `invalid_request`.
  3. Test invalid period returns `invalid_request`.
  4. Test quota exhausted prevents provider call.
  5. Test provider output cannot include invented transactions in fixture expectations.
  6. Assert advice response follows contract.

  **Done when**: Advice endpoint is contract-tested.

### Implementation for User Story 4

- [X] T042 [US4] Implement receipt request validation in `workers/ai-gateway/src/handlers/receiptExtraction.ts`.

  **Detailed steps**:
  1. Accept only POST.
  2. Parse JSON safely.
  3. Require `imageBase64`.
  4. Require `mimeType` starting with `image/`.
  5. Enforce maximum base64 length based on current Flutter compression.
  6. Normalize locale/defaultCurrency.
  7. Validate categories as minimal snapshots.
  8. Reject invalid request before auth/quota/provider where appropriate.

  **Done when**: Bad receipt requests cannot reach Gemini.

- [X] T043 [US4] Implement receipt endpoint flow in `workers/ai-gateway/src/handlers/receiptExtraction.ts`.

  **Detailed steps**:
  1. Generate request id.
  2. Verify Firebase token.
  3. Consume `receipt_extraction` quota with limit 3 by default.
  4. Build receipt prompt.
  5. Call Gemini provider with text prompt and inline image data.
  6. Validate receipt structured output.
  7. Log safe metadata only.
  8. Return contract-compatible success or error response.

  **Done when**: Flutter `GatewayReceiptAiService` can use the Worker endpoint.

- [X] T044 [US4] Implement advice request validation in `workers/ai-gateway/src/handlers/financialAdvice.ts`.

  **Detailed steps**:
  1. Accept only POST.
  2. Parse JSON safely.
  3. Require `period` to be `week` or `month`.
  4. Require `summary` to be an object.
  5. Reject arrays, empty body, and invalid dates.
  6. Normalize locale/defaultCurrency.

  **Done when**: Bad advice requests fail before provider calls.

- [X] T045 [US4] Implement advice endpoint flow in `workers/ai-gateway/src/handlers/financialAdvice.ts`.

  **Detailed steps**:
  1. Generate request id.
  2. Verify Firebase token.
  3. Consume `financial_advice` quota with limit 3 by default.
  4. Build grounded advice prompt from `summary`.
  5. Call Gemini provider.
  6. Validate advice structured output.
  7. Log safe metadata.
  8. Return contract-compatible success or error response.

  **Done when**: Flutter `GatewayFinancialAdviceAiService` can use the Worker endpoint.

- [X] T046 [US4] Route `/aiReceipt` and `/aiAdvice` in `workers/ai-gateway/src/index.ts`.

  **Detailed steps**:
  1. Route `/aiReceipt` to receipt handler.
  2. Route `/aiAdvice` to advice handler.
  3. Ensure both support CORS OPTIONS.
  4. Ensure unknown endpoint returns JSON 404.
  5. Ensure all routes share response/error helpers.

  **Done when**: The Worker exposes all endpoints expected by Flutter endpoint replacement logic.

- [X] T047 [US4] Verify Flutter services need no endpoint-specific code changes.

  **Files**: `lib/ai/services/receipt_ai_service.dart`, `lib/ai/services/financial_advice_ai_service.dart`, `lib/ai/services/ai_gateway_client.dart`

  **Detailed steps**:
  1. Confirm receipt service calls `AiGatewayClient.extractReceipt()`.
  2. Confirm advice service calls `AiGatewayClient.financialAdvice()`.
  3. Confirm both endpoint names match Worker routes.
  4. Only patch Flutter if mismatch exists.
  5. Add tests if any Flutter patch is needed.

  **Done when**: Existing Flutter receipt/advice paths can use Cloudflare Worker.

**Checkpoint**: All provider-backed AI features have Worker endpoints.

---

## Phase 7: User Story 5 - Deployable Documentation And Safe Operations (Priority: P2)

**Goal**: Make the gateway deployable by future developers/agents with no guessing.

**Independent Test**: A new developer follows quickstart and deploys Worker plus APK without reading chat history.

### Documentation And Operations Tasks

- [X] T048 [US5] Finalize Worker quickstart in `specs/018-cloudflare-ai-gateway/quickstart.md`.

  **Detailed steps**:
  1. Confirm commands are Windows CMD/PowerShell friendly.
  2. Include D1 creation command.
  3. Include secret creation command.
  4. Include migration command.
  5. Include Worker deploy command.
  6. Include exact Flutter build command with `/aiParse`.
  7. Include manual verification commands and expected behavior.

  **Done when**: The quickstart can be followed from a clean checkout.

- [X] T049 [US5] Add deployment checklist in `workers/ai-gateway/README.md`.

  **Detailed steps**:
  1. List pre-deploy checks.
  2. List secrets check without printing secrets.
  3. List D1 migration check.
  4. List deploy command.
  5. List post-deploy smoke tests.
  6. List rollback path.

  **Done when**: Deployment steps are visible next to Worker code.

- [X] T050 [US5] Add local smoke request examples in `workers/ai-gateway/README.md`.

  **Detailed steps**:
  1. Provide unauthenticated curl example expecting `unauthenticated`.
  2. Provide authenticated example with a redacted token variable.
  3. Provide quota exhaustion manual steps.
  4. Do not include a real token, user id, or Gemini key.

  **Done when**: Developers can test the Worker manually without leaking credentials.

- [X] T051 [US5] Document Firebase Spark boundary in `docs/implementation_plans/cloudflare_ai_gateway.md`.

  **Detailed steps**:
  1. Explain why Firebase Functions are not used for free plan.
  2. Explain Firebase remains responsible for Auth and Firestore.
  3. Explain Cloudflare Worker is responsible for AI provider calls and quota.
  4. Explain Gemini free quota is external and can still be exhausted.
  5. Link to this Spec Kit plan.

  **Done when**: Product/architecture documentation reflects the new free-plan backend split.

- [X] T052 [US5] Update `AGENTS.md` current Spec Kit plan to `specs/018-cloudflare-ai-gateway/plan.md`.

  **Detailed steps**:
  1. Replace the current plan path between SPECKIT markers.
  2. Do not alter unrelated instructions.
  3. Confirm future agents see this plan first.

  **Done when**: The repository context points to this plan.

- [X] T053 [US5] Update `.specify/feature.json` to reference `specs/018-cloudflare-ai-gateway`.

  **Detailed steps**:
  1. Set `feature_directory` to `specs/018-cloudflare-ai-gateway`.
  2. Keep valid JSON.
  3. Confirm Speckit downstream commands target this feature.

  **Done when**: Spec Kit recognizes feature 018 as active.

- [X] T054 [US5] Update constitution after implementation in `.specify/memory/constitution.md`.

  **Detailed steps**:
  1. Add Cloudflare Worker AI Gateway to current architecture only after implementation exists.
  2. Add Worker source path and verification commands.
  3. Add convention that Firebase Functions are not the free-plan AI path.
  4. Update Last Updated date.
  5. Do not claim implemented features before code exists.

  **Done when**: Constitution accurately reflects actual repository state.

**Checkpoint**: Operational docs are complete and future agents have the correct context.

---

## Phase 8: Integration, Deployment, And App Build

**Purpose**: Deploy Worker, build APK against it, and verify the end-to-end app flow.

- [X] T055 Run Worker dependency install in `workers/ai-gateway/`.

  **Detailed steps**:
  1. Run `npm install`.
  2. Confirm `package-lock.json` is created or updated.
  3. Confirm no install secrets are generated.
  4. If network fails, retry only with user-approved network escalation.

  **Done when**: Worker dependencies are installed and lockfile is present.

- [X] T056 Run Worker typecheck in `workers/ai-gateway/`.

  **Detailed steps**:
  1. Run `npm run typecheck`.
  2. Fix all TypeScript errors.
  3. Do not suppress strict errors without justification.

  **Done when**: TypeScript passes cleanly.

- [X] T057 Run Worker test suite in `workers/ai-gateway/`.

  **Detailed steps**:
  1. Run `npm test`.
  2. Confirm all auth, quota, provider, endpoint, and contract tests pass.
  3. If tests fail, fix code or test assumptions before deployment.

  **Done when**: Worker tests pass.

- [X] T058 Create Cloudflare D1 database for remote environment.

  **Detailed steps**:
  1. Run `npx wrangler d1 create ai_expenses_gateway`.
  2. Copy returned database id into `workers/ai-gateway/wrangler.toml`.
  3. Do not commit account-specific secrets beyond intended database binding config if the team accepts it.
  4. If multiple environments are planned, document dev/prod database ids separately.

  **Done when**: Remote D1 database exists and Worker config points to it.

- [X] T059 Apply D1 migrations locally and remotely.

  **Detailed steps**:
  1. Run local migration command.
  2. Run remote migration command.
  3. Verify `ai_usage_daily` and `ai_usage_logs` exist.
  4. Do not manually edit D1 tables in dashboard unless documenting the change.

  **Done when**: D1 schema is ready for deployed Worker.

- [X] T060 Add Cloudflare Gemini secret.

  **Detailed steps**:
  1. Run `npx wrangler secret put GEMINI_API_KEY`.
  2. Paste Gemini key only into the secret prompt.
  3. Do not echo the key in terminal logs.
  4. Do not store the key in `.env`, `wrangler.toml`, docs, or Flutter.

  **Done when**: Worker has provider secret configured.

- [X] T061 Deploy Worker.

  **Detailed steps**:
  1. Run `npx wrangler deploy`.
  2. Capture the deployed Worker base URL.
  3. Verify routes `/aiParse`, `/aiReceipt`, `/aiAdvice` respond with JSON errors when unauthenticated.
  4. Save only non-secret URL in implementation notes.

  **Done when**: Worker is deployed and reachable.

- [X] T062 Build Flutter APK with Cloudflare Worker URL.

  **Files**: Flutter build output under `build/app/outputs/flutter-apk/app-release.apk`

  **Detailed steps**:
  1. Build with `--dart-define=AI_GATEWAY_URL=<worker-base-url>/aiParse`.
  2. Include `--dart-define=AI_PROVIDER=gemini`.
  3. Include `--dart-define=AI_MODEL=gemini-2.5-flash`.
  4. Confirm release APK builds.
  5. Do not put Gemini key in any dart-define.

  **Done when**: Release APK points at Cloudflare Worker and contains no provider key.

- [X] T063 Run Flutter analysis and tests.

  **Detailed steps**:
  1. Run `flutter analyze`.
  2. Run `flutter test`.
  3. If Worker-only changes do not touch Flutter, still run at least existing tests before final APK if time allows.
  4. Record exact pass/fail counts.

  **Done when**: Existing app verification baseline remains healthy.

- [ ] T064 Manual end-to-end test on device.

  **Status note (2026-05-16)**: Release APK was built with the deployed Worker URL, but device install/manual flow was not run from this shell because `adb` is not available on PATH. A remote authenticated smoke attempt created and deleted a temporary Firebase user successfully, then reached the Worker and failed only at Gemini because the configured Gemini key is invalid.

  **Detailed steps**:
  1. Install APK.
  2. Sign in with Firebase Auth.
  3. Open AI Assistant.
  4. Send Arabic text expense.
  5. Verify editable preview.
  6. Confirm expense only after user taps confirm.
  7. Verify saved expense appears in user-scoped Firestore.
  8. Exhaust quota and verify clear message.
  9. Verify another account still gets quota.

  **Done when**: The free-plan AI path works end to end without Firebase Functions.

---

## Phase 9: Polish And Cross-Cutting Concerns

**Purpose**: Security hardening, maintenance notes, and future premium readiness.

- [X] T065 [P] Add premium extension notes to `specs/018-cloudflare-ai-gateway/research.md`.

  **Detailed steps**:
  1. Document future options: Firestore user plan lookup, Custom Claims, or Cloudflare D1 subscription table.
  2. State that premium implementation is out of scope.
  3. Note that limits should become per-plan instead of env-only later.

  **Done when**: Future premium work has a clear next direction.

- [X] T066 [P] Add security threat notes to `docs/implementation_plans/cloudflare_ai_gateway.md`.

  **Detailed steps**:
  1. List threats: open proxy abuse, token spoofing, key leak, quota bypass, prompt injection, receipt privacy.
  2. Map each threat to implemented mitigation.
  3. Identify residual risks: external free quota changes, provider outages.

  **Done when**: Security assumptions are documented for future review.

- [X] T067 Add provider fallback behavior documentation to `workers/ai-gateway/README.md`.

  **Detailed steps**:
  1. Explain what happens on Gemini rate limit.
  2. Explain how Flutter fallback works when gateway fails.
  3. Explain what manual features remain available.
  4. Explain that local repeated detection and prediction consume no AI requests.

  **Done when**: Support/debug docs explain non-happy paths.

- [X] T068 Verify no secrets are present in tracked files.

  **Detailed steps**:
  1. Search for `GEMINI_API_KEY=` outside ignored local files.
  2. Search for known key prefixes if user provides safe redacted pattern only.
  3. Search Flutter source for API key fields.
  4. Confirm `wrangler.toml` contains only non-secret vars.
  5. Report any secret exposure immediately and rotate key if needed.

  **Done when**: Repository contains no provider secret.

- [X] T069 Verify Firebase Functions are not required by the free-plan path.

  **Detailed steps**:
  1. Confirm deploy instructions use `wrangler deploy`, not `firebase deploy --only functions`.
  2. Confirm Flutter build uses Cloudflare Worker URL.
  3. Confirm Firebase Spark remains acceptable for Auth/Firestore.
  4. Leave `functions/` code untouched unless a future paid backend spec uses it.

  **Done when**: Free-plan architecture has no Firebase Blaze dependency.

- [X] T070 Final release note for this change in `docs/implementation_plans/cloudflare_ai_gateway.md`.

  **Detailed steps**:
  1. Summarize what changed.
  2. List the deployed Worker URL field using a redacted example value.
  3. List user free limits.
  4. List verification commands and results.
  5. List known limitations.

  **Done when**: The final implementation can be reviewed without chat context.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 Setup**: No dependencies.
- **Phase 2 Foundational**: Depends on Phase 1.
- **US1 MVP Text Parse**: Depends on Phase 2.
- **US2 Security Hardening**: Depends on Phase 2 and should be completed before public deployment.
- **US3 Quota Rules**: Depends on Phase 2 and should be completed before provider calls.
- **US4 Receipt/Advice**: Depends on Phase 2 and can start after US1 patterns are established.
- **US5 Documentation**: Can start after plan artifacts exist, but final docs depend on implementation details.
- **Phase 8 Deployment**: Depends on US1, US2, US3, and any desired US4 endpoint completion.
- **Phase 9 Polish**: Depends on completed implementation scope.

### User Story Dependencies

- **US1**: MVP path. Can be delivered first after foundation.
- **US2**: Required before public deployment; can run in parallel with US1 tests after auth foundation.
- **US3**: Required before public deployment; can run in parallel with US1 handler work after quota foundation.
- **US4**: Extends MVP to receipt/advice; should reuse US1 endpoint patterns.
- **US5**: Documentation and operations; can be refined throughout.

### Parallel Opportunities

- T007, T009, T010, T011, T012, T014, T016, T017, T018, T019, T021 can run in parallel after setup where file paths do not conflict.
- US1 tests T022 can be written while foundational implementation is underway.
- US4 tests T040 and T041 can run in parallel because they touch different test files.
- Documentation tasks T048, T049, T050, T051 can run in parallel after core contracts stabilize.

## Parallel Example: Foundation

```text
Task: T009 Implement normalized JSON responses in workers/ai-gateway/src/http/response.ts
Task: T010 Implement CORS handling in workers/ai-gateway/src/http/cors.ts
Task: T011 Define shared provider/gateway types in workers/ai-gateway/src/ai/providerTypes.ts
Task: T012 Implement Google Secure Token key cache in workers/ai-gateway/src/auth/googleJwksCache.ts
Task: T018 Implement structured schema helpers in workers/ai-gateway/src/ai/structuredSchema.ts
Task: T019 Implement prompt builder in workers/ai-gateway/src/ai/promptBuilder.ts
```

## Parallel Example: Receipt And Advice

```text
Task: T040 Add receipt endpoint tests in workers/ai-gateway/test/receiptExtraction.test.ts
Task: T041 Add financial advice endpoint tests in workers/ai-gateway/test/financialAdvice.test.ts
Task: T042 Implement receipt request validation in workers/ai-gateway/src/handlers/receiptExtraction.ts
Task: T044 Implement advice request validation in workers/ai-gateway/src/handlers/financialAdvice.ts
```

## Implementation Strategy

### MVP First

1. Complete Phase 1.
2. Complete Phase 2.
3. Complete US1 text parse.
4. Complete US2 auth/secret hardening needed for public exposure.
5. Complete US3 quota enforcement.
6. Deploy Worker and build APK.
7. Stop and validate text AI end to end.

### Incremental Delivery

1. MVP text AI gateway.
2. Receipt endpoint.
3. Advice endpoint.
4. Operational docs and premium extension notes.

### Future Premium Strategy

Premium is not implemented in this plan. Future work should:

1. Add a user plan source of truth.
2. Resolve plan from Firebase Auth Custom Claims or Firestore profile.
3. Map plan to request-type limits.
4. Add admin tooling for plan changes.
5. Add billing/subscription provider in a separate spec.

## Notes

- Every task must preserve the current Flutter AI confirmation-first behavior.
- Any implementation agent must update task checkboxes as tasks complete.
- Do not deploy or configure Firebase Functions for this feature.
- Do not paste real secrets into markdown files, command logs, or final reports.
