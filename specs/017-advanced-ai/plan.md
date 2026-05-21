# Implementation Plan: Advanced AI

## Technical Context

Advanced AI depends on stable AI Assistant architecture, reports, and recurring expenses.
This plan intentionally limits provider calls: AI is used for receipt image understanding and short financial advice only. Repeated expense detection, prediction, reports, filters, and budget calculations remain local deterministic logic to protect the free API quota. The only backend allowed for provider calls, secrets, quota, and usage logs is Firebase, specifically Firebase Functions plus Firestore where persistence is needed.

## Architecture

Use Firebase Functions for receipt vision and financial advice. Keep local deterministic services for repeated expense detection and prediction. Route all provider-backed requests through the existing Firebase gateway so Flutter never stores provider secrets. Add quota checks before advice and receipt provider calls so free-plan users have configurable daily limits. If Firebase Functions, provider auth, or quota is unavailable, Flutter must show a clear fallback state while keeping manual expense entry and local insight features working.

## Files

- Modify: `pubspec.yaml`
- Modify: `functions/src/index.ts`
- Modify: `functions/src/aiGateway.ts` or equivalent gateway module
- Modify/Create: Firebase Functions usage/quota module under `functions/src/`
- Modify/Create: Firestore rules/index documentation if quota/usage collections are added
- Create: `lib/ai/models/ai_receipt_payload.dart`
- Create: `lib/ai/models/ai_prediction_payload.dart`
- Create: `lib/ai/models/ai_financial_advice_payload.dart`
- Create: `lib/ai/models/ai_usage_status.dart`
- Create: `lib/ai/services/receipt_ai_service.dart`
- Create: `lib/ai/services/financial_advice_ai_service.dart`
- Create: `lib/ai/services/ai_usage_fallback_service.dart`
- Create: `lib/ai/services/repeated_expense_detector.dart`
- Create: `lib/ai/services/spending_prediction_service.dart`
- Create: `lib/screens/ai_assistant/widgets/receipt_capture_button.dart`
- Create: `lib/screens/ai_assistant/widgets/financial_advice_button.dart`
- Create: Firebase Functions tests for receipt/advice quota enforcement under `functions/test/`

## Data Model

Receipt payload: amount, date, merchant, category, currency, confidence. Prediction payload: period, expected total, category drivers. Advice payload: period, grounded spending summary, short advice text, provider metadata, quota remaining, generated date. Usage status payload: request type, allowed/blocked, quota limit, quota used, quota remaining, reset date, and fallback reason when blocked.

Free-plan receipt and advice quota state should be stored server-side in Firestore through Firebase Functions, keyed by `userId + requestType + yyyy-MM-dd`. The provider must not be called when the quota is already exhausted. Raw receipt images should be compressed before upload and should not be stored long-term; only extracted fields and non-sensitive usage metadata should persist after confirmation.

## Risks

- AI provider secrets must not be embedded in Flutter.
- Free API quota can be exhausted quickly if advice or receipt analysis is called automatically.
- Predictions must be explainable and non-binding.
- Advice must not invent spending facts; the app should provide local aggregates as ground truth.
- Quota checks must happen before provider calls to prevent wasted requests.
- Receipt images may contain sensitive merchant or personal data; avoid long-term image storage and log only safe metadata.
- Firebase Functions may not be deployed in early testing; provider-backed UI must degrade gracefully.
- Duplicate taps or retries can waste quota without request de-duplication/cache.

## Verification

- Repeated expense detector tests.
- Prediction service tests.
- Financial advice quota tests in Firebase Functions.
- Receipt extraction quota tests in Firebase Functions.
- Provider-not-called tests after quota exhaustion.
- Manual receipt preview test.
- Manual free-plan quota exhausted test.
- Manual Firebase Functions unavailable fallback test.

## Detailed Execution Guidance

- Do not begin this plan until AI phase 1 and phase 2 are stable.
- Receipt extraction must reuse the preview-confirm pattern.
- Repeated detection and prediction must be local and testable first; do not spend provider calls on those calculations.
- Remote AI/vision and AI advice must go through Firebase Functions only, not a separate server or direct Flutter provider call.
- Advice requests must be user-initiated; do not call AI advice automatically on app open or every refresh.
- Receipt extraction requests must be user-initiated; do not analyze images automatically after every picker event without explicit user action.
- Free-plan advice and receipt quotas should be conservative and configurable, such as small daily counts per user and request type.
- Cache or reuse the latest advice for the same user/period/day when possible instead of calling the provider again.
- Cache duplicate receipt analysis where safe by using non-sensitive local fingerprints of the selected image/input, not by storing raw images remotely.
- Compress/resize receipt images before upload to Firebase Functions.
- If AI is unavailable or quota is exhausted, keep manual expense entry, reports, filters, local predictions, and repeated detection available.
- Prediction output must include reasoning/category drivers, not just a number.
- Provider-backed advice output must be structured JSON, short, and based on local aggregates passed to the backend.
