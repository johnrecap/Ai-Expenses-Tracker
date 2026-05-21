# Implementation Report: AI Usage Quota Surface

**Date**: 2026-05-17

## Changed Files

- `workers/ai-gateway/src/quota/quotaService.ts`
- `workers/ai-gateway/src/handlers/parseExpense.ts`
- `workers/ai-gateway/src/handlers/receiptExtraction.ts`
- `workers/ai-gateway/src/handlers/financialAdvice.ts`
- `workers/ai-gateway/README.md`
- `workers/ai-gateway/test/parseExpense.test.ts`
- `workers/ai-gateway/test/receiptExtraction.test.ts`
- `workers/ai-gateway/test/financialAdvice.test.ts`
- `lib/ai/models/ai_usage_status.dart`
- `lib/ai/models/ai_response.dart`
- `lib/ai/services/ai_gateway_error.dart`
- `lib/ai/services/ai_gateway_client.dart`
- `lib/ai/services/gateway_ai_service.dart`
- `lib/ai/services/ai_usage_fallback_service.dart`
- `lib/ai/cubit/ai_assistant_state.dart`
- `lib/ai/cubit/ai_assistant_cubit.dart`
- `lib/monetization/cubit/monetization_cubit.dart`
- `lib/screens/ai_assistant/views/ai_assistant_sheet.dart`
- `lib/screens/settings/widgets/ai_settings_section.dart`
- `lib/screens/monetization/widgets/quota_usage_card.dart`
- `test/ai/ai_gateway_client_test.dart`
- `test/ai/ai_assistant_cubit_test.dart`
- `test/monetization/monetization_cubit_test.dart`
- `specs/028-ai-usage-quota-surface/tasks.md`
- `specs/028-ai-usage-quota-surface/implementation-report.md`

## Worker/App Contract

The Worker already returned `quota` on successful `/aiParse`, `/aiReceipt`, and `/aiAdvice` responses. This implementation adds matching quota metadata to quota-exhausted errors when the authenticated user and request type are known:

```json
{
  "requestType": "parse_text",
  "allowed": false,
  "limit": 5,
  "used": 5,
  "remaining": 0,
  "resetAt": "2026-05-18T00:00:00.000Z"
}
```

Flutter maps Worker quota into `AiUsageStatus`, exposes `AiUsageSnapshot` helpers, and stores the latest trusted usage in `MonetizationCubit`. Missing Worker quota remains display-only unknown/stale state; Flutter does not authorize or decrement backend quota locally.

Errors are normalized through `AiQuotaErrorCategory`: unclear input, missing fields, quota exhausted, provider unavailable, network, unauthorized, unsupported, and unknown. User-facing messages avoid provider secrets and keep manual expense entry available.

## Local Feature Boundary

`RepeatedExpenseDetector`, `SpendingPredictionService`, and report summaries use in-memory expense data and local calculators only. They do not call `AiGatewayClient`, provider services, HTTP, Firebase Functions, or Gemini.

## Worker Commands Not Run

Per instruction, no verification/build commands were run:

- `flutter test`
- `flutter analyze`
- `flutter build`
- `flutter gen-l10n`
- `npm test`
- `npm build`
- Worker test/typecheck/build commands

## Parent Verification

The parent review ran verification after integrating Plans 026, 027, and 028:

- `workers/ai-gateway`: `npm test` passed with 45 tests.
- `workers/ai-gateway`: `npm run typecheck` passed.
- `flutter analyze` passed with no issues.
- Targeted AI/monetization tests passed after fixing usage exhaustion helpers and quota error copy.
- `flutter test --reporter expanded --concurrency=1` passed with 186 tests.
- `flutter build apk --release --no-tree-shake-icons` passed and produced `build/app/outputs/flutter-apk/app-release.apk`.

Manual quota-exhausted and provider-unavailable fixture checks remain open because they require interactive app/device exercising.

## Notes And Risks

- Worker tests were updated but not executed.
- Flutter tests were updated but not executed.
- Settings and Free/Premium now read the same monetization usage state where the existing app-level `MonetizationCubit` is present.
- Rewarded credit display remains limited to existing monetization policy/state; no backend credit authorization was added.
