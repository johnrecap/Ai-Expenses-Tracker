# Implementation Plan: Gemini AI Provider Integration

**Branch**: `codex/012-5-gemini-ai-provider` | **Date**: 2026-05-16 | **Spec**: [spec.md](spec.md)  
**Input**: Feature specification from `/specs/012.5-gemini-ai-provider/spec.md`

## Summary

Add the first real AI provider path for the Expense Tracker AI Assistant using Gemini 2.5 Flash through a secure backend gateway. The Flutter app keeps the existing AI service, strict JSON parser, Cubit, preview UI, and confirmation-first mutation flow, while the gateway owns provider secrets, free-tier quota limits, structured-output prompting, provider fallback, and normalized errors.

## Technical Context

**Language/Version**: Dart 3.x for Flutter app; backend gateway recommended as Firebase Cloud Functions or Cloud Run using TypeScript/Node.js because the project already uses Firebase Auth and Firestore.  
**Primary Dependencies**: Flutter, Bloc, Firebase Auth, Cloud Firestore, existing `lib/ai` AI service/parser/cubit, Gemini API from backend only.  
**Storage**: Existing Firestore user paths; AI action logs under `users/{userId}/ai_actions`; optional gateway usage counters under user-owned or server-owned usage paths.  
**Testing**: `flutter test`, `flutter analyze`, backend unit tests for provider/gateway when backend is introduced.  
**Target Platform**: Flutter Android, iOS, web, Windows, Linux, macOS; backend gateway reachable by all supported clients.  
**Project Type**: Multi-platform Flutter app with Firebase backend integration.  
**Performance Goals**: Clear AI text prompts should produce preview-ready structured JSON in under 5 seconds for most development requests when provider is available.  
**Constraints**: No provider API keys in Flutter; AI mutations remain confirmation-first; malformed AI output rejected; free-tier quotas handled gracefully; low-confidence outputs ask for clarification.  
**Scale/Scope**: MVP supports authenticated text prompts through Gemini 2.5 Flash; receipt vision, advanced prediction, and production billing rollout are separate work.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Skill-first workflow**: Passed. Constitution, development workflow, skill matcher, and matched Spec Kit skills were read before creating artifacts.
- **Spec-driven development**: Passed. This feature has `spec.md`, `plan.md`, `research.md`, `data-model.md`, `contracts/`, `quickstart.md`, and `tasks.md`.
- **Architecture preservation**: Passed. The plan extends `AiService`/`RemoteAiService` and avoids changing Bloc/repository boundaries.
- **Firebase user ownership**: Passed. AI action logs and usage data remain tied to authenticated users; gateway verifies identity.
- **AI safety**: Passed. Provider never writes directly to Firestore; Flutter parser and preview/confirmation remain mandatory.
- **Secret management**: Passed. Provider keys stay outside Flutter and are accessed only by backend gateway.
- **Verification**: Passed at planning level. Implementation tasks require `flutter pub get`, `flutter analyze`, `flutter test`, backend tests, and manual Gemini QA.

## Project Structure

### Documentation (this feature)

```text
specs/012.5-gemini-ai-provider/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── checklists/
│   └── requirements.md
├── contracts/
│   ├── ai_structured_schema.json
│   └── gateway_contract.md
└── tasks.md
```

### Source Code (repository root)

```text
lib/
├── ai/
│   ├── models/
│   │   ├── ai_provider_metadata.dart
│   │   └── models.dart
│   ├── services/
│   │   ├── gateway_ai_service.dart
│   │   ├── ai_gateway_client.dart
│   │   ├── ai_provider_config.dart
│   │   ├── ai_gateway_error.dart
│   │   └── services.dart
│   └── cubit/
│       ├── ai_assistant_cubit.dart
│       └── ai_assistant_state.dart
├── screens/
│   └── home/
│       └── views/
│           └── home_screen.dart
└── firebase_options.dart

packages/
└── expense_repository/
    └── lib/
        ├── src/
        │   ├── entities/
        │   │   └── ai_action_log_entity.dart
        │   ├── models/
        │   │   └── ai_action_log.dart
        │   └── repositories/
        │       ├── ai_action_log_repository.dart
        │       └── firebase_ai_action_log_repository.dart
        └── expense_repository.dart

functions/
├── package.json
├── tsconfig.json
├── src/
│   ├── index.ts
│   ├── ai/
│   │   ├── parseExpense.ts
│   │   ├── geminiProvider.ts
│   │   ├── providerTypes.ts
│   │   ├── structuredSchema.ts
│   │   ├── quotaService.ts
│   │   └── promptBuilder.ts
│   └── firebase/
│       └── authGuard.ts
└── test/
    ├── geminiProvider.test.ts
    ├── quotaService.test.ts
    └── parseExpense.test.ts

test/
└── ai/
    ├── ai_gateway_client_test.dart
    ├── gateway_ai_service_test.dart
    ├── ai_response_parser_gemini_test.dart
    └── ai_provider_config_test.dart
```

**Structure Decision**: Keep Flutter AI orchestration in `lib/ai`, keep Firestore action logging in `packages/expense_repository`, and add a Firebase-aligned `functions/` gateway only for provider calls, secrets, quota, and response normalization. If the project chooses Cloud Run instead of Functions at implementation time, the same gateway contract and tests still apply.

## Phase 0: Research Output

Research is captured in [research.md](research.md). Key decisions:

- Start with Gemini 2.5 Flash as the first real provider.
- Use a backend gateway because provider keys must not ship inside Flutter.
- Enforce structured JSON at the provider/gateway boundary.
- Keep the current parser and confirmation-first Cubit as the safety boundary.
- Treat free-tier usage as development/early validation, not a guaranteed production plan.

## Phase 1: Design Output

Design artifacts:

- [data-model.md](data-model.md) defines provider config, gateway request/response, usage records, and fallback policy.
- [contracts/gateway_contract.md](contracts/gateway_contract.md) defines the authenticated gateway request/response behavior.
- [contracts/ai_structured_schema.json](contracts/ai_structured_schema.json) defines the strict JSON schema the provider must follow.
- [quickstart.md](quickstart.md) defines manual validation and no-secret checks.

## Implementation Phases

### Phase A: Flutter Provider Boundary

Add gateway client/config/error models under `lib/ai/services` and provider metadata models under `lib/ai/models`. `GatewayAiService` implements `AiService` by calling the gateway, extracting `structuredJson`, and passing it to `AiResponseParser`.

### Phase B: Backend Gateway

Add `functions/` backend gateway with authenticated `/ai/parse` callable/HTTP function, Gemini provider adapter, schema prompt builder, quota service, and normalized errors. Store Gemini API key only in backend secret management or local backend environment during development.

### Phase C: Logging And Observability

Extend AI action logs with provider/model/request/usage/error fields. Keep all logs user-owned and safe. Record previewed, confirmed, canceled, failed, quota, and rate-limit outcomes.

### Phase D: UI Wiring And Failure UX

Wire `AiAssistantSheet` to use `GatewayAiService` when provider config is enabled, and keep `MockAiService` as dev/test fallback. Add clear quota/rate-limit/provider-unavailable messages without losing the user's input.

### Phase E: Verification And Manual Gemini QA

Add parser, service, client, config, quota, and gateway tests. Run Flutter verification and backend verification. Execute Arabic manual QA prompts with a development Gemini key stored outside Flutter.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|--------------------------------------|
| Add backend gateway surface | Required to protect AI provider keys and enforce free-tier quota | Direct Flutter provider calls expose keys and cannot enforce reliable quotas |
| Add provider metadata to logs | Required for free-tier cost/quality monitoring | Existing logs cannot identify provider/model failures or usage patterns |

## Post-Design Constitution Check

- AI provider code remains outside widgets except provider selection/wiring.
- `AiResponseParser` remains the single parsing gate for provider output.
- Existing domain repositories remain responsible for Firestore mutations after confirmation.
- Firestore data remains user-scoped.
- No new state-management package is introduced.
- Verification commands are explicitly required before completion.
