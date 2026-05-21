# Feature Specification: Advanced AI

**Feature Branch**: `017-advanced-ai`
**Created**: 2026-05-15
**Status**: Draft

## User Scenarios & Testing

### User Story 1 - Receipt Image Extraction (P1)
As a user, I capture a receipt and get an editable expense preview.

**Acceptance Criteria**
- AI extracts amount, date, merchant, category, currency, and confidence.
- Preview is shown before save.

### User Story 2 - Repeated Expense Detection (P2)
As a user, I get suggestions when similar expenses repeat.

**Acceptance Criteria**
- App suggests recurring setup.
- No recurring expense is created without confirmation.

### User Story 3 - Spending Prediction (P2)
As a user, I see predicted spending based on history.

**Acceptance Criteria**
- Prediction is explainable by category/history.
- Prediction is displayed as guidance, not a guarantee.

### User Story 4 - Daily Limited AI Financial Advice (P2)
As a free-plan user, I can ask for short personalized financial advice from AI without exhausting the free API quota.

**Acceptance Criteria**
- Advice uses the user's real spending summary as grounded input.
- Free plan advice has a configurable daily limit per user.
- When the user reaches the daily limit, the app shows a clear message and keeps local non-AI insights available.
- Advice is displayed as guidance only and never changes data automatically.

### User Story 5 - App Remains Useful When AI Is Unavailable (P1)
As a user, I can keep using core expense tracking features when AI is unavailable, quota is exhausted, or Firebase Functions is not deployed.

**Acceptance Criteria**
- Manual expense entry remains available.
- Local reports, filters, predictions, and repeated expense detection remain available.
- Receipt extraction and AI advice show clear unavailable/quota messages instead of blocking the app.
- No AI-only path is required to create, update, delete, report, or inspect expenses.

## Functional Requirements

- Add receipt AI service.
- Add image capture/picker.
- Add repeated expense detector.
- Add prediction service.
- Add AI financial advice service through Firebase Functions only; no separate non-Firebase backend is allowed.
- Add per-user daily quota enforcement for AI advice in the free plan.
- Add per-user daily quota enforcement for receipt image extraction in the free plan.
- Add AI usage logging for receipt and advice requests, including success, failure, quota-blocked, provider, model, createdAt, and request type without storing sensitive raw receipt images.
- Add local fallback states when AI is disabled, quota is exhausted, Firebase Functions is unavailable, or the provider fails.
- Add receipt image preprocessing before upload, such as compression/resizing, to reduce request cost and latency.
- Add same-day cache/reuse behavior for AI advice and duplicate receipt analysis where safe.
- Keep repeated expense detection and spending prediction local by default to reduce API usage.
- Keep all AI outputs confirmation-first.

## Out Of Scope

- Direct AI API secrets in Flutter.
- Bank statement ingestion.
- Unlimited free-plan AI advice.
- Unlimited free-plan receipt extraction.
- Using AI for deterministic calculations that can be done locally.
- Non-Firebase backend hosting.
- Long-term storage of raw receipt images.

## Success Metrics

- Detector and prediction algorithms have unit tests.
- Receipt preview follows the same confirmation safety model.
- Free-plan advice quota prevents requests after the configured daily limit.
- Free-plan receipt quota prevents provider requests after the configured daily limit.
- Local repeated detection and prediction work without consuming AI requests.
- The app can complete manual expense entry, reports, filters, local predictions, and repeated detection while AI is unavailable.

## Detailed Requirements And Edge Cases

- Receipt image extraction must show preview before save.
- AI provider secrets must stay outside Flutter app code.
- AI provider calls must be routed only through Firebase Functions in this project.
- If Firebase Functions is not configured or unavailable, provider-backed features must fail gracefully and the rest of the app must continue working.
- Repeated expense detection suggests recurring setup but must not auto-create.
- Predictions must show category drivers or explanation.
- Prediction UI must clearly state that values are guidance based on history.
- AI financial advice must be short, grounded in local spending summaries, and routed through the backend gateway.
- AI financial advice must count against a per-user daily free-plan quota before calling the provider.
- Receipt extraction must count against a per-user daily free-plan quota before calling the provider.
- If any quota is exhausted, no provider request should be sent.
- Raw receipt images should be compressed/resized before upload and should not be stored long-term by the app.
- AI usage logs must not store provider secrets, raw authorization headers, or full raw receipt images.
- Cached advice or receipt results may be reused only when the same user, same period/day, and materially same input are detected.
- Repeated detection, prediction, reports, filters, and budget calculations must remain deterministic local logic unless a later paid-plan spec explicitly expands AI usage.
