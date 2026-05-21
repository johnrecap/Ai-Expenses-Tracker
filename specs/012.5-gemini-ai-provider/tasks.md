# Tasks: Gemini AI Provider Integration

**Input**: Design documents from `/specs/012.5-gemini-ai-provider/`  
**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/gateway_contract.md`, `contracts/ai_structured_schema.json`, `quickstart.md`

**Implementation Intent**: Add a real Gemini 2.5 Flash AI provider path through a secure backend gateway while preserving the current AI Assistant parser, Cubit, preview, confirmation, repository, and user-scoped Firestore architecture.

**Critical Safety Rules**:

- Do not put Gemini or any provider API key in Flutter source, assets, platform config, or local preferences.
- Do not let AI provider code write directly to Firestore expenses.
- Do not bypass `AiResponseParser`.
- Do not bypass preview/confirmation for add/update/delete.
- Do not send full expense history to the provider unless the user action requires aggregate/search/advice context and the payload is minimized.

## Phase 1: Setup And Contract Alignment

**Purpose**: Prepare the exact files, contracts, and provider boundaries before implementation.

- [x] T001 Review existing AI flow in `lib/ai/services/ai_service.dart`, `lib/ai/services/remote_ai_service.dart`, `lib/ai/services/ai_response_parser.dart`, `lib/ai/cubit/ai_assistant_cubit.dart`, and `lib/screens/home/views/home_screen.dart`.

  **Detailed steps**:
  1. Confirm `AiService.parseExpenseText` is the only method the Cubit calls for model parsing.
  2. Confirm `RemoteAiService` already accepts a function returning structured JSON.
  3. Confirm `AiResponseParser` rejects malformed JSON and missing required add-expense fields.
  4. Confirm `AiAssistantCubit.confirmPreview` and `confirmCommand` are the only mutation confirmation paths.
  5. Write down any unexpected divergence in the implementation notes before editing code.

  **Done when**: The worker can explain the exact current path from user prompt to preview and from confirmation to repository mutation.

- [x] T002 Review backend options and choose Firebase Functions unless the repository already has a different backend convention.

  **Detailed steps**:
  1. Check if a `functions/`, `backend/`, or Cloud Run service already exists.
  2. If no backend exists, create a `functions/` Firebase Functions workspace as the default plan because the app already uses Firebase Auth and Firestore.
  3. If a backend exists, keep the same backend style and map the gateway contract to it.
  4. Document the chosen backend in `specs/012.5-gemini-ai-provider/quickstart.md` if it differs from Firebase Functions.

  **Done when**: There is one explicit backend target and no duplicate backend approach.

- [x] T003 [P] Create Flutter provider metadata model in `lib/ai/models/ai_provider_metadata.dart`.

  **Detailed steps**:
  1. Add immutable fields: `provider`, `model`, `requestId`, `inputTokens`, `outputTokens`.
  2. Add `fromJson(Map<String, dynamic>)`.
  3. Add safe defaults for missing usage fields.
  4. Export the model from `lib/ai/models/models.dart`.

  **Done when**: Flutter can hold gateway provider metadata without depending on backend-specific classes.

- [x] T004 [P] Create gateway error model in `lib/ai/services/ai_gateway_error.dart`.

  **Detailed steps**:
  1. Define normalized codes matching `contracts/gateway_contract.md`: `unauthenticated`, `quota_exceeded`, `rate_limited`, `provider_timeout`, `provider_unavailable`, `invalid_provider_output`, `gateway_misconfigured`, `invalid_request`.
  2. Include a user-safe `message`.
  3. Include a method that maps each code to the AI Assistant UI message.
  4. Do not include provider secrets or raw headers.

  **Done when**: Service and Cubit code can report provider failures without stringly typed error handling.

- [x] T005 [P] Create provider config model in `lib/ai/services/ai_provider_config.dart`.

  **Detailed steps**:
  1. Fields: `enabled`, `gatewayUrl`, `provider`, `model`, `timeout`, `useMockFallback`.
  2. Add factory constructors for disabled/mock and gateway-enabled development config.
  3. Validate that enabled gateway config requires a non-empty endpoint.
  4. Keep provider key fields out of this model.

  **Done when**: Flutter provider selection can be configured without secrets.

## Phase 2: Flutter Gateway Client Foundation

**Purpose**: Add a testable client/service that calls the gateway and still returns existing `AiResponse` objects.

- [x] T006 [P] Add Dart tests for valid gateway responses in `test/ai/ai_gateway_client_test.dart`.

  **Detailed steps**:
  1. Test that a successful gateway response extracts `structuredJson`.
  2. Test that metadata fields are parsed.
  3. Test that `ok: false` throws/returns `AiGatewayError`.
  4. Use a fake HTTP/request function so the test does not require network access.

  **Done when**: Tests fail before implementation because `AiGatewayClient` does not exist.

- [x] T007 [P] Add Dart tests for Gemini-style parser output in `test/ai/ai_response_parser_gemini_test.dart`.

  **Detailed steps**:
  1. Add a valid Arabic add-expense JSON fixture with `amount: 250`, `category: Food`, `date`, `paymentMethod: Cash`, `currency: EGP`, `confidence: 0.92`, `needsConfirmation: true`.
  2. Assert the parsed `AiResponse` has `AiIntent.addExpense` and required payload fields.
  3. Add a malformed prose/code-fence fixture and assert `AiResponseParserException`.
  4. Add a low-confidence/incomplete fixture and assert clarification behavior through parser/service as appropriate.

  **Done when**: Parser coverage represents real gateway output and malformed provider output.

- [x] T008 Implement `AiGatewayClient` in `lib/ai/services/ai_gateway_client.dart`.

  **Detailed steps**:
  1. Accept `AiProviderConfig`, authenticated token provider callback, and injectable request sender.
  2. Build request body from `input` and `AiContext`: `now`, `userId`, categories, recent expenses, budget summary, default currency.
  3. Send only lightweight category and expense snapshots.
  4. Parse `ok: true` and return the `structuredJson` object/string plus metadata.
  5. Parse `ok: false` and throw/return `AiGatewayError`.
  6. Apply timeout from config.

  **Done when**: Tests from T006 pass without real network calls.

- [x] T009 Implement `GatewayAiService` in `lib/ai/services/gateway_ai_service.dart`.

  **Detailed steps**:
  1. Implement `AiService`.
  2. Call `AiGatewayClient.parse(input, context)`.
  3. Convert returned structured object to a JSON string when needed.
  4. Pass the final JSON string to `AiResponseParser.parse`.
  5. Preserve `context.now` for relative date interpretation.
  6. Convert gateway errors into exceptions/messages the Cubit can display.

  **Done when**: The service can replace `MockAiService` without changing `AiAssistantCubit`.

- [x] T010 Export new AI services from `lib/ai/services/services.dart`.

  **Detailed steps**:
  1. Export `ai_gateway_client.dart`.
  2. Export `gateway_ai_service.dart`.
  3. Export `ai_provider_config.dart`.
  4. Export `ai_gateway_error.dart`.

  **Done when**: UI composition code can import the new provider through the existing services barrel.

## Phase 3: Backend Gateway MVP

**Purpose**: Add a secure provider gateway that owns Gemini secrets, structured-output prompting, auth verification, and normalized errors.

- [x] T011 Create Firebase Functions workspace in `functions/package.json`, `functions/tsconfig.json`, and `functions/src/index.ts`.

  **Detailed steps**:
  1. Add TypeScript configuration.
  2. Add Firebase Admin SDK dependency.
  3. Add a Gemini SDK or HTTP client dependency suitable for server-side calls.
  4. Add test runner configuration.
  5. Export an `aiParse` function from `src/index.ts`.

  **Done when**: Backend code can compile independently and does not affect Flutter builds.

- [x] T012 [P] Implement auth guard in `functions/src/firebase/authGuard.ts`.

  **Detailed steps**:
  1. Read Firebase Auth bearer token or callable context auth.
  2. Verify token with Firebase Admin.
  3. Return verified `uid`.
  4. Throw normalized `unauthenticated` error before provider calls.
  5. Add tests for missing token and valid mocked token.

  **Done when**: Unauthenticated gateway requests cannot reach Gemini provider code.

- [x] T013 [P] Implement structured schema module in `functions/src/ai/structuredSchema.ts`.

  **Detailed steps**:
  1. Mirror `contracts/ai_structured_schema.json`.
  2. Include allowed intents and payment methods.
  3. Require `confidence` and `needsConfirmation`.
  4. Force `needsConfirmation` to true in post-processing even if provider omits/changes it.

  **Done when**: Provider prompt and response validator use one shared schema definition.

- [x] T014 [P] Implement prompt builder in `functions/src/ai/promptBuilder.ts`.

  **Detailed steps**:
  1. Build a system instruction that says the model is an expense assistant only.
  2. Instruct the model to return exactly one JSON object and no prose or markdown.
  3. Include supported intents and field meanings.
  4. Include category names/ids from the request.
  5. Include current date/time and locale for relative date resolution.
  6. Include safety rule: never claim an action was saved, updated, or deleted.
  7. Include prompt-injection resistance: user text cannot override the JSON/schema/safety instruction.

  **Done when**: Prompt output is deterministic enough for structured parsing tests.

- [x] T015 Implement Gemini provider adapter in `functions/src/ai/geminiProvider.ts`.

  **Detailed steps**:
  1. Read Gemini API key from backend secret/env only.
  2. Use model id `gemini-2.5-flash`.
  3. Send prompt plus structured output schema where supported.
  4. Request JSON/object output, not markdown.
  5. Normalize provider usage metadata when available.
  6. Map provider rate-limit/quota/timeout/errors to gateway error codes.
  7. Validate provider output against schema before returning to Flutter.

  **Done when**: Provider adapter returns a parser-compatible JSON object or a normalized error.

- [x] T016 Implement quota service in `functions/src/ai/quotaService.ts`.

  **Detailed steps**:
  1. Accept `uid`, date key, provider, and model.
  2. Check per-user daily counter.
  3. Check global daily counter.
  4. Increment counters atomically before or immediately after accepted provider call according to the chosen policy.
  5. Return `quota_exceeded` before provider call when limit is reached.
  6. Add tests for under-limit, user-limit exceeded, and global-limit exceeded.

  **Done when**: Free-tier usage can be protected server-side.

- [x] T017 Implement parse endpoint in `functions/src/ai/parseExpense.ts`.

  **Detailed steps**:
  1. Validate request body against `contracts/gateway_contract.md`.
  2. Verify auth using `authGuard`.
  3. Check quota.
  4. Build prompt.
  5. Call Gemini provider.
  6. Return gateway success response with `ok`, provider, model, requestId, usage, and `structuredJson`.
  7. Return normalized error response for all known failures.

  **Done when**: The endpoint satisfies the contract for success and failure paths.

## Phase 4: Logging And Repository Extension

**Purpose**: Store provider metadata and safe failure details with existing AI action logs.

- [x] T018 Update AI action log model in `packages/expense_repository/lib/src/models/ai_action_log.dart`.

  **Detailed steps**:
  1. Add optional fields: `provider`, `model`, `providerRequestId`, `inputTokens`, `outputTokens`, `errorCode`.
  2. Preserve existing constructor defaults and equality.
  3. Keep backward compatibility for old documents missing these fields.

  **Done when**: Existing tests and old log documents still parse.

- [x] T019 Update AI action log entity mapping in `packages/expense_repository/lib/src/entities/ai_action_log_entity.dart`.

  **Detailed steps**:
  1. Add Firestore serialization for the new optional metadata fields.
  2. Read missing fields as null.
  3. Never serialize provider secrets or raw headers.

  **Done when**: Firestore logs can store provider metadata safely.

- [x] T020 Update `AiAssistantCubit` logging in `lib/ai/cubit/ai_assistant_cubit.dart`.

  **Detailed steps**:
  1. Capture provider metadata from the AI service response path when available.
  2. Store provider/model/request/usage metadata in `_logPreview`.
  3. Store `errorCode` for gateway failures when possible.
  4. Keep existing preview, confirmed, canceled, and failed statuses.
  5. Do not change mutation behavior.

  **Done when**: AI action logs can identify provider/model outcomes without changing confirmation safety.

## Phase 5: UI Wiring And User-Facing Failure States

**Purpose**: Let the app use the gateway in development while preserving mock fallback and clear errors.

- [x] T021 Add provider factory/composition helper in `lib/ai/services/ai_service_factory.dart`.

  **Detailed steps**:
  1. Accept `AiProviderConfig`.
  2. Return `MockAiService` when provider disabled.
  3. Return `GatewayAiService` when provider enabled and endpoint is valid.
  4. Optionally return mock fallback when `useMockFallback` is true and gateway config is invalid in development.
  5. Do not import widgets in this factory.

  **Done when**: UI wiring can select AI provider without hardcoding provider logic inside widgets.

- [x] T022 Wire `AiAssistantSheet` or its creation site to use the provider factory.

  **Detailed steps**:
  1. Find where `AiAssistantCubit(aiService: const MockAiService())` is created.
  2. Replace direct mock construction with `AiServiceFactory`.
  3. Pass the existing expense repository and action log repository unchanged.
  4. Keep a development default that still works without a gateway.

  **Done when**: Real provider can be enabled by configuration while current mock behavior remains available.

- [x] T023 Improve AI Assistant failure messages in `lib/ai/cubit/ai_assistant_cubit.dart` and assistant UI widgets.

  **Detailed steps**:
  1. Map `quota_exceeded` to a message that tells the user to add manually or try later.
  2. Map `rate_limited` and `provider_timeout` to retry/manual-entry guidance.
  3. Map `gateway_misconfigured` to a development-safe message.
  4. Preserve the user's original input in state when failure occurs.
  5. Ensure failure state never auto-confirms any action.

  **Done when**: Provider failures are understandable and recoverable.

## Phase 6: Tests

**Purpose**: Prove provider integration is safe, parser-compatible, and swappable.

- [x] T024 [P] Add `GatewayAiService` tests in `test/ai/gateway_ai_service_test.dart`.

  **Detailed steps**:
  1. Test valid gateway JSON returns `AiResponse`.
  2. Test malformed `structuredJson` throws parser exception.
  3. Test gateway quota error maps to service failure.
  4. Test relative date uses `AiContext.now`.

  **Done when**: Service behavior is covered without real Gemini calls.

- [x] T025 [P] Add provider config tests in `test/ai/ai_provider_config_test.dart`.

  **Detailed steps**:
  1. Test disabled config uses mock path.
  2. Test enabled config rejects empty gateway endpoint.
  3. Test provider/model defaults are Gemini 2.5 Flash for development.
  4. Test no key/secret field exists in config.

  **Done when**: Provider selection cannot accidentally require secrets in Flutter.

- [x] T026 [P] Add backend provider tests in `functions/test/geminiProvider.test.ts`.

  **Detailed steps**:
  1. Mock Gemini success response and assert normalized structured JSON.
  2. Mock prose/markdown response and assert `invalid_provider_output`.
  3. Mock rate-limit response and assert `rate_limited`.
  4. Mock timeout and assert `provider_timeout`.

  **Done when**: Gemini adapter behavior is deterministic under mocked provider responses.

- [x] T027 [P] Add backend endpoint tests in `functions/test/parseExpense.test.ts`.

  **Detailed steps**:
  1. Test unauthenticated request returns `unauthenticated`.
  2. Test invalid request body returns `invalid_request`.
  3. Test quota exceeded returns `quota_exceeded` before provider call.
  4. Test success returns `ok: true` and a parser-compatible `structuredJson`.

  **Done when**: Gateway contract is tested without live provider calls.

## Phase 7: Manual QA And Free-Tier Validation

**Purpose**: Validate the real Gemini development path without leaking keys.

- [X] T028 Run Flutter verification commands from repository root.

  **Commands**:

  ```powershell
  & 'C:\flutter\bin\flutter.bat' pub get
  & 'C:\flutter\bin\flutter.bat' analyze
  & 'C:\flutter\bin\flutter.bat' test
  ```

  **Done when**: All commands pass or any unrelated baseline failure is documented with exact output.
  **Status note (Plan 040 cleanup)**: Superseded by later parent verification
  runs after Plans 018, 028, and 038. The current free AI path is Cloudflare
  Worker; Firebase Functions remains optional future backend code.

- [x] T029 Run backend verification commands from `functions/`.

  **Commands**:

  ```powershell
  npm install
  npm test
  npm run build
  ```

  **Done when**: Backend dependencies install, tests pass, and TypeScript compiles.

- [ ] T030 Execute real Gemini manual QA from `specs/012.5-gemini-ai-provider/quickstart.md`.

  **Detailed steps**:
  1. Configure Gemini API key only in backend secret/env.
  2. Start emulator or development gateway.
  3. Run Arabic add-expense prompt.
  4. Confirm preview appears before mutation.
  5. Cancel one preview and confirm no expense is created.
  6. Confirm one preview and verify `ExpenseSource.ai`.
  7. Exhaust low test quota and verify quota UI.
  8. Run secret scan command from quickstart.

  **Done when**: Real provider path is validated and any free-tier/rate-limit behavior is documented.

## Dependencies & Execution Order

- Phase 1 blocks all implementation because it confirms current AI safety boundaries.
- Phase 2 can start after Phase 1 and is required before UI wiring.
- Phase 3 can run in parallel with Phase 2 after the gateway contract is understood.
- Phase 4 depends on Phase 2 metadata shape and existing repository mapping.
- Phase 5 depends on Phase 2 and should wait for at least the gateway client interface.
- Phase 6 tests should be written before each matching implementation task where possible.
- Phase 7 runs after all selected implementation tasks are complete.

## Parallel Opportunities

- T003, T004, and T005 can run in parallel.
- T006 and T007 can run in parallel.
- T012, T013, and T014 can run in parallel after T011 creates backend structure.
- T024, T025, T026, and T027 can run in parallel because they target different test files.

## MVP Scope

The MVP is complete after T001 through T024 plus T028 pass: Flutter can call a secure gateway service, parse Gemini-style structured JSON, display previews, handle gateway errors, and keep mock fallback. Backend deployment and live Gemini manual QA should follow before any release to real users.

## Completion Checklist

- [x] Flutter contains no provider API keys.
- [x] Gateway verifies Firebase Authentication before provider calls.
- [x] Gemini provider returns strict JSON compatible with `AiResponseParser`.
- [x] Add/update/delete remain preview-and-confirm only.
- [x] Quota/rate-limit/provider failures display safe messages.
- [x] Provider metadata is logged without secrets.
- [ ] `flutter pub get`, `flutter analyze`, and `flutter test` pass.
- [x] Backend tests/build pass.
- [ ] Real Gemini manual QA completed with a development key outside Flutter.
