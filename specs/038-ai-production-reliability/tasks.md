# Tasks: AI Production Reliability

**Input**: `specs/038-ai-production-reliability/spec.md`, `plan.md`  
**Implementation Intent**: Ensure AI works with the real Worker gateway and fails safely without breaking manual finance flows.

## Phase 1: Configuration And Documentation

- [X] T001 Document AI build configuration in `docs/ai/production-ai-setup.md`.

  **Why**: The app silently falls back to mock AI when `AI_GATEWAY_URL` is missing.
  **Steps**:
  1. Explain mock mode vs gateway mode.
  2. Add exact build/run commands with `--dart-define=AI_GATEWAY_URL=<worker-url>`.
  3. Explain allowed client config: endpoint, provider, model, timeout, mock fallback.
  4. Warn that Gemini keys belong only in Cloudflare Worker secrets.
  **Done when**: Anyone can build a real-AI app without putting keys in Flutter.
  **Worker 038 status**: Added production AI setup doc with mock vs gateway mode, Flutter commands, allowed client defines, and Worker-only secret guidance.

- [X] T002 Add a visible AI provider/debug status for internal builds only.

  **Why**: During testing, the owner needs to know whether AI is real gateway or mock fallback.
  **Steps**:
  1. Add a small internal-only status in AI settings or debug section.
  2. Show gateway enabled/disabled, provider/model, and stale usage state.
  3. Do not expose secrets or auth tokens.
  4. Hide or simplify this for public production if needed.
  **Done when**: Internal QA can immediately detect a build missing `AI_GATEWAY_URL`.
  **Worker 038 status**: Added non-release AI Assistant status showing gateway/mock mode, provider/model/timeout, and stale usage state without secrets or auth tokens.

- [X] T003 Add a secret scan checklist to `docs/ai/production-ai-setup.md`.

  **Why**: API keys were previously pasted into terminal/chat workflows; leaks must be prevented.
  **Steps**:
  1. List search terms: `GEMINI_API_KEY`, `AIza`, `OPENAI_API_KEY`, provider keys.
  2. Explain Firebase client API key is not the same as Gemini provider key but should be restricted in Google Cloud.
  3. Explain rotation steps if a provider key leaks.
  **Done when**: The setup doc contains clear security recovery steps.
  **Worker 038 status**: Added scan terms, Firebase client API key note, and provider-key rotation steps.

## Phase 2: Error Handling And Quota UX

- [X] T004 Review and expand `AiGatewayException` and error UI mapping.

  **Why**: Provider unavailable, quota exhausted, auth failure, timeout, malformed JSON, and network errors need different user guidance.
  **Steps**:
  1. Map Worker `quota_exceeded` to quota UI with reset metadata.
  2. Map 401/403 auth failures to sign-in/session guidance.
  3. Map provider 403/5xx/timeouts to temporary unavailable guidance.
  4. Map malformed JSON to clarification/failure without mutation.
  **Done when**: Users see accurate, non-technical messages for each failure class.
  **Worker 038 status**: Gateway client now maps non-JSON/HTTP 401/403, 408/504, 429, and 5xx responses before falling back to malformed-output handling; existing UI receives auth/quota/provider/network categories.

- [X] T005 Ensure `MonetizationCubit` usage state updates only from trusted Worker metadata.

  **Why**: The client should not guess quota use when provider metadata is missing.
  **Steps**:
  1. Confirm parse/receipt/advice responses update usage when metadata exists.
  2. Mark usage stale when metadata is missing or request fails before Worker response.
  3. Avoid local decrement assumptions that drift from server quota.
  **Done when**: Free/Premium quota display stays honest.
  **Worker 038 status**: Parse responses still update usage only when Worker quota metadata exists; gateway responses without quota metadata now mark parse usage stale instead of guessing.

- [X] T006 Add tests for AI error and quota states in `test/ai/`.

  **Why**: This protects the exact cases users hit in real API setup.
  **Steps**:
  1. Test quota exhausted includes reset/count metadata.
  2. Test provider unavailable does not show quota upsell incorrectly.
  3. Test missing auth token produces auth-specific failure.
  4. Test manual fallback remains available.
  **Done when**: AI failure behavior is deterministic and covered.
  **Worker 038 status**: Added/expanded AI tests for quota metadata, provider outage, missing auth, manual fallback after AI failure, stale usage when quota metadata is missing, and status-code error mapping. Tests were not executed by request.

## Phase 3: Category Reliability

- [X] T007 Expand AI category resolver fixtures for Arabic everyday spending terms.

  **Why**: The user expects "أكل", "مواصلات", "أوبر", "نت", "فواتير" to match real categories naturally.
  **Steps**:
  1. Add terms for food, transport, shopping, bills, entertainment, subscriptions, wallet/bank wording.
  2. Include Egyptian Arabic variants where obvious.
  3. Keep aliases curated and avoid over-broad matches that cause false positives.
  **Done when**: Common Arabic phrases resolve to active categories with explainable confidence.
  **Worker 038 status**: Added curated aliases for Egyptian Arabic/service-name food, transport, bills, entertainment, subscriptions, shopping, and bank-fee wording.

- [ ] T008 Add tests for archived category and no-match suggestion behavior.

  **Why**: AI must not silently reuse archived categories or create categories without confirmation.
  **Steps**:
  1. Test archived match is ignored or shown as suggestion requiring user action.
  2. Test no active match produces editable suggestion metadata.
  3. Test confirming suggested category creates category through repository before expense.
  **Done when**: Category safety is covered end-to-end.
  **Worker 038 status**: Partially complete. Added archived-category and editable no-match suggestion tests. Remaining blocker: no end-to-end widget/repository test was run for suggested category creation before expense save because all test execution was explicitly forbidden in this pass.

- [X] T009 Review AI preview UI for category confidence and suggestion clarity.

  **Why**: Users need to know whether AI selected an existing category or suggested a new one.
  **Steps**:
  1. Show selected category source where helpful: existing, alias, recent, suggestion.
  2. Allow user to change category before confirmation.
  3. Ensure suggested category creation is explicit in preview.
  **Done when**: No AI category creation/selection is hidden from the user.
  **Worker 038 status**: Preview already allowed category changes and explicit suggested-category creation; added source labels for id/name/alias/history/suggestion/manual paths.

## Phase 4: Real Gateway And Worker Verification

- [X] T010 Run `workers/ai-gateway` tests and typecheck.

  **Why**: Flutter real AI depends on Worker request/response contracts.
  **Steps**:
  1. Run `npm test`.
  2. Run `npm run typecheck`.
  3. Fix only Worker issues caused by this plan.
  **Done when**: Worker remains green.
  **Worker 038 blocker**: Not run by worker because the user explicitly forbade `npm test`, `npm run typecheck`, and any build/test command.
  **Parent verification (2026-05-18)**: `npm --prefix workers/ai-gateway test` passed 45 tests across 8 files. `npm --prefix workers/ai-gateway run typecheck` passed.

- [X] T011 Add a local Worker smoke command to `docs/ai/production-ai-setup.md`.

  **Why**: The owner needs a correct CMD/PowerShell-safe way to test the Worker and Gemini key.
  **Steps**:
  1. Provide `curl.exe` examples for Windows CMD.
  2. Provide PowerShell examples separately without mixing syntax.
  3. Include expected success and common 401/403/quota errors.
  **Done when**: API testing instructions no longer cause shell syntax confusion.
  **Worker 038 status**: Added separate PowerShell and CMD `curl.exe` examples plus expected success and common auth/quota/provider/misconfiguration failures.

- [ ] T012 Run Android device QA with real Worker URL.

  **Why**: Unit tests do not prove Firebase Auth token, Worker CORS/auth, and Gemini provider all work together.
  **Steps**:
  1. Build/run with `--dart-define=AI_GATEWAY_URL=<worker-url>`.
  2. Sign in with Firebase Auth.
  3. Parse Arabic add-expense sentence.
  4. Confirm preview creates expense.
  5. Test quota exhausted/provider unavailable fixture if available.
  6. Test manual add expense still works after AI error.
  **Done when**: Real device AI path is verified or exact blocker is documented.
  **Worker 038 blocker**: Not run. User explicitly forbade build/test/run commands; doc now records the exact Android Worker QA checklist and blocker.

## Phase 5: Verification

- [X] T013 Run `flutter analyze`.

  **Why**: AI/service/UI changes can introduce import or state issues.
  **Steps**:
  1. Run analyzer.
  2. Fix plan-caused issues.
  **Done when**: Analyzer passes.
  **Worker 038 blocker**: Not run by worker because the user explicitly forbade `flutter analyze`.
  **Parent verification (2026-05-18)**: `flutter analyze` passed with no issues after parent fixes.

- [X] T014 Run full Flutter tests.

  **Why**: AI touches Cubits, parsers, monetization, categories, and UI.
  **Steps**:
  1. Run `flutter test --reporter expanded --concurrency=1 --timeout 45s`.
  2. Confirm existing 214+ test baseline remains green or updated deliberately.
  **Done when**: Full tests pass.
  **Worker 038 blocker**: Not run by worker because the user explicitly forbade `flutter test` and all build/test commands.
  **Parent verification (2026-05-18)**: Targeted AI tests passed, and the full Flutter suite passed: 233 tests.

- [X] T015 Run a final AI secret scan.

  **Why**: Provider key leakage is the highest AI operational risk.
  **Steps**:
  1. Search for `GEMINI_API_KEY`, `AIza`, and provider key patterns.
  2. Confirm any Firebase client API key is expected and restricted.
  3. Confirm Worker secret is not present in files.
  **Done when**: No AI provider secrets are committed.
  **Worker 038 status**: Ran read-only scans for provider key terms and key-like patterns; hits were documented secret names, placeholder examples such as `<local-test-key>`/`your-local-key`, Worker secret bindings/tests, or existing setup notes, not committed provider key values.
  **Parent verification (2026-05-18)**: Final secret scan found only documented secret names/placeholders, expected Worker env variable references, and the Firebase client API key in `android/app/google-services.json`; no Gemini/provider secret value was committed.

## Dependencies & Execution Order

- T001 and T003 should happen before device QA.
- T004 to T006 can run in parallel with T007 to T009.
- T010 and T011 must happen before T012.
- T013 to T015 are final.

## Suggested MVP

Complete T001, T004 to T006, T010 to T012, and T015 first. That proves real AI works and fails safely before category/UI refinements.
