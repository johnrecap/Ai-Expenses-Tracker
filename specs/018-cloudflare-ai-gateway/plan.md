# Implementation Plan: Cloudflare AI Gateway

**Branch**: `018-cloudflare-ai-gateway` | **Date**: 2026-05-16 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `specs/018-cloudflare-ai-gateway/spec.md`

## Summary

Replace the free-plan AI backend path from Firebase Functions to a Cloudflare Worker gateway while keeping Firebase Auth and Firestore on Spark. Flutter will continue to use the existing `AI_GATEWAY_URL` HTTP gateway contract. The Worker verifies Firebase ID tokens, enforces per-user daily quotas, calls Gemini 2.5 Flash with server-side secrets, returns structured JSON, and keeps existing preview/confirmation safety intact.

## Technical Context

**Language/Version**: TypeScript for Cloudflare Worker, Dart 3.x/Flutter for existing app integration  
**Primary Dependencies**: Cloudflare Workers, Wrangler, Cloudflare D1, Gemini REST API, Firebase Auth JWT verification via Google Secure Token public keys, existing Flutter `http` gateway client  
**Storage**: Cloudflare D1 for AI usage counters and safe logs; Firestore remains for app data only  
**Testing**: Worker unit/contract tests with mocked token verifier/provider/D1; existing `flutter analyze`, `flutter test`, and Android APK build for app integration  
**Target Platform**: Cloudflare edge Worker plus existing Flutter Android/iOS/web/desktop clients  
**Project Type**: Mobile app plus external AI gateway service  
**Performance Goals**: Text parse and advice should respond within 10 seconds; receipt extraction within 15 seconds after upload; quota/auth rejection should return without provider call in under 1 second under normal network conditions  
**Constraints**: Firebase must remain Spark/free; no Firebase Functions deployment; provider secrets never in Flutter; all AI mutations preview-first; no global quota by default; receipt images not persisted  
**Scale/Scope**: MVP supports current project users, three AI request types, per-user daily free quotas, and future plan-based quota extension

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Spec-driven workflow**: Pass. This feature has a dedicated spec, plan, research, data model, contracts, quickstart, and task list.
- **Existing architecture preservation**: Pass. Flutter keeps Bloc/Cubit, repository pattern, `AiGatewayClient`, parser, and confirmation-first UI.
- **Data ownership**: Pass. Firestore user data remains under `users/{userId}`; Worker stores only AI usage counters/logs.
- **AI Assistant safety**: Pass. Gateway returns structured JSON only and never writes expenses.
- **Secrets**: Pass. Gemini key stored only as Cloudflare secret.
- **Verification**: Pass with planned commands in tasks and quickstart.

## Project Structure

### Documentation (this feature)

```text
specs/018-cloudflare-ai-gateway/
|-- spec.md
|-- plan.md
|-- research.md
|-- data-model.md
|-- quickstart.md
|-- contracts/
|   |-- worker-api.md
|   `-- worker-env.md
|-- checklists/
|   `-- requirements.md
`-- tasks.md
```

### Source Code (repository root)

```text
workers/
`-- ai-gateway/
    |-- package.json
    |-- package-lock.json
    |-- tsconfig.json
    |-- wrangler.toml
    |-- .gitignore
    |-- src/
    |   |-- index.ts
    |   |-- config.ts
    |   |-- http/
    |   |   |-- cors.ts
    |   |   `-- response.ts
    |   |-- auth/
    |   |   |-- firebaseTokenVerifier.ts
    |   |   `-- googleJwksCache.ts
    |   |-- ai/
    |   |   |-- geminiProvider.ts
    |   |   |-- promptBuilder.ts
    |   |   |-- providerTypes.ts
    |   |   `-- structuredSchema.ts
    |   |-- quota/
    |   |   |-- quotaService.ts
    |   |   `-- usageLogService.ts
    |   `-- handlers/
    |       |-- parseExpense.ts
    |       |-- receiptExtraction.ts
    |       `-- financialAdvice.ts
    |-- migrations/
    |   `-- 0001_ai_usage.sql
    `-- test/
        |-- auth.test.ts
        |-- quota.test.ts
        |-- parseExpense.test.ts
        |-- receiptExtraction.test.ts
        |-- financialAdvice.test.ts
        |-- geminiProvider.test.ts
        `-- contract.test.ts

lib/
`-- ai/
    `-- services/
        |-- ai_gateway_client.dart
        |-- ai_provider_config.dart
        |-- gateway_ai_service.dart
        |-- receipt_ai_service.dart
        `-- financial_advice_ai_service.dart

functions/
`-- existing Firebase Functions gateway retained for future non-free/premium backend path
```

**Structure Decision**: Add a new `workers/ai-gateway` service rather than modifying `functions/` because Firebase Functions cannot be deployed under the required free Spark plan. Keep Flutter changes minimal and contract-compatible.

## Phase 0: Research

Research output is captured in [research.md](research.md). Key decisions:

- Use Cloudflare Worker for AI gateway.
- Keep Firebase Auth as identity source.
- Use D1 for per-user daily quota counters.
- Do not apply global project limits by default.
- Preserve the existing Flutter gateway response contract.
- Keep existing Firebase Functions code as optional future backend.

## Phase 1: Design

Design outputs:

- [data-model.md](data-model.md): Worker environment, token validation result, usage counters, usage logs, gateway requests, gateway responses.
- [contracts/worker-api.md](contracts/worker-api.md): Endpoint request/response contract for `aiParse`, `aiReceipt`, and `aiAdvice`.
- [contracts/worker-env.md](contracts/worker-env.md): Cloudflare bindings, secrets, variables, and optional emergency globals.
- [quickstart.md](quickstart.md): Setup, deploy, APK build, verification, and rollback.

## Implementation Strategy

### MVP First

1. Create the Worker project and D1 schema.
2. Implement Firebase token verification.
3. Implement per-user quota service.
4. Implement `/aiParse`.
5. Deploy Worker and build Flutter APK with `AI_GATEWAY_URL`.
6. Validate text AI end to end.

### Expand After MVP

1. Port receipt extraction to `/aiReceipt`.
2. Port financial advice to `/aiAdvice`.
3. Add usage logs and operational docs.
4. Add optional premium-plan extension points without implementing premium billing yet.

## Risk Management

| Risk | Mitigation |
|------|------------|
| Firebase token verification implemented incorrectly | Add tests for missing token, wrong issuer, wrong audience, expired token, and valid token; use Google Secure Token public keys |
| Gemini key leaks | Store only in Cloudflare secrets; never include in Flutter or docs examples |
| Quota race conditions | Use D1 atomic update/check patterns and tests |
| Free-tier limits change | Keep fallback mode and document operational assumptions |
| Worker URL misconfigured in Flutter | Quickstart uses exact `AI_GATEWAY_URL` path ending in `/aiParse`; add manual verification |
| Provider returns invalid JSON | Validate provider output before response; return `invalid_provider_output` |
| Receipt image privacy | Do not store raw image; log only safe metadata |

## Verification Plan

### Worker Verification

```bat
cd workers\ai-gateway
npm install
npm test
npm run typecheck
npx wrangler d1 migrations apply ai_expenses_gateway --local
npx wrangler dev
```

### Flutter Verification

```bat
cd /d "C:\Users\SOUQ\Downloads\apps\Expense-Tracker\Expense-Tracker-main"
& "C:\flutter\bin\flutter.bat" analyze
& "C:\flutter\bin\flutter.bat" test
& "C:\flutter\bin\flutter.bat" build apk --release --dart-define=AI_GATEWAY_URL=https://<worker-url>/aiParse --dart-define=AI_PROVIDER=gemini --dart-define=AI_MODEL=gemini-2.5-flash
```

### Manual Verification

- Sign in with Firebase Auth.
- Submit Arabic text expense.
- Confirm editable preview.
- Exhaust text quota and verify 6th request blocks.
- Verify another user still has quota.
- Verify manual expense entry still works.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Additional backend service under `workers/` | Firebase Functions requires Blaze and user requires free Firebase plan | Direct Flutter Gemini calls leak the provider key; Firebase Functions violates free-plan requirement |
| D1 quota storage | Need accurate per-user daily quota counters | KV/eventual consistency can allow quota overrun; in-memory counters are not durable |
| JWT verification without Firebase Admin SDK | Workers cannot rely on Firebase Admin SDK like Node Firebase Functions | Skipping verification would expose the gateway to abuse |

## Constitution Check - Post Design

- **Spec-driven workflow**: Pass.
- **Existing Flutter architecture**: Pass; no widget-layer provider secrets.
- **AI safety**: Pass; gateway returns previews only.
- **User data ownership**: Pass; Firestore remains user-scoped.
- **Free Firebase constraint**: Pass; no Firebase Functions deploy required.
- **Verification coverage**: Pass; tasks include worker tests, Flutter tests, deploy smoke checks, and APK build.
