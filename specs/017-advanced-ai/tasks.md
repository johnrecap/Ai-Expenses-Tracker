# Tasks: Advanced AI

## Implementation Intent

Add receipt image extraction, AI financial advice with daily free-plan quotas, repeated expense detection, and spending prediction after the safe AI confirmation architecture is already in place. Provider calls are limited to receipt understanding and advice; repeated detection and prediction must run locally. Any provider-backed work must use Firebase Functions only, with graceful local fallback when AI, quota, or Firebase Functions are unavailable.

---

## Phase 1: Firebase AI Usage Governance

### [X] T001 - Define Firebase-Only AI Backend Boundary

**Files:** Update `specs/017-advanced-ai/plan.md` if needed during implementation and inspect existing `functions/src/` gateway files.

**Steps:** Confirm all provider-backed receipt/advice calls go through Firebase Functions. Do not add direct provider calls, direct API keys, or a non-Firebase backend.

**Done When:** The implementation has a single Firebase Functions provider boundary and Flutter stores no provider secrets.

### [X] T002 - Add Usage Status Model

**Files:** Create `lib/ai/models/ai_usage_status.dart`.

**Steps:** Model requestType, allowed/blocked, limit, used, remaining, resetAt, and fallbackReason so UI can explain quota and unavailable states.

**Done When:** Receipt/advice UI can show quota remaining and fallback reasons from structured data.

### [X] T003 - Add Firebase Usage/Quota Module

**Files:** Create or update Firebase Functions quota module under `functions/src/`.

**Steps:** Store per-user per-day usage by request type in Firestore through Functions. Support at least `receipt_extraction` and `financial_advice`. Check quota before provider call.

**Done When:** Quota state is server-side, user-scoped, daily, and request-type specific.

### [X] T004 - Add AI Usage Logging

**Files:** Update Firebase Functions gateway code and any existing AI action log integration as appropriate.

**Steps:** Log request type, userId, status, provider/model, createdAt, quota result, and safe error codes. Do not log provider secrets, raw auth headers, or raw receipt images.

**Done When:** Debugging/cost monitoring is possible without storing sensitive AI inputs.

### [X] T005 - Add Local Fallback Contract

**Files:** Create `lib/ai/services/ai_usage_fallback_service.dart` or equivalent app-layer helper.

**Steps:** Define consistent fallback states for AI disabled, Firebase Functions unavailable, quota exhausted, provider failed, and low confidence.

**Done When:** Provider-backed UI can fail gracefully while core local app features continue.

---

## Phase 2: Receipt AI

### [X] T006 - Add Image Capture Dependency

**Files:** Modify `pubspec.yaml`.

**Steps:** Add `image_picker` or selected camera package; run `flutter pub get`.

**Done When:** App can request image input.

### [X] T007 - Add Permissions

**Files:** Android/iOS/macOS platform files as required.

**Steps:** Add camera/gallery permission descriptions; handle denied permission.

**Done When:** Image flow does not crash on denied permissions.

### [X] T008 - Create `AiReceiptPayload`

**Files:** Create `lib/ai/models/ai_receipt_payload.dart`.

**Steps:** Include amount, date, merchant, category, currency, confidence, rawText optional.

**Done When:** Receipt extraction has structured output.

### [X] T009 - Create `ReceiptAiService`

**Files:** Create `lib/ai/services/receipt_ai_service.dart`.

**Steps:** Define interface for extracting receipt payload from image; real implementation must call Firebase Functions without app secrets.

**Done When:** UI does not know provider details.

### [X] T010 - Add Receipt Image Preprocessing

**Files:** Update receipt capture/service files.

**Steps:** Compress/resize selected receipt images before upload and keep the original image local only. Avoid long-term raw image storage.

**Done When:** Receipt requests are smaller and raw images are not persisted by the app.

### [X] T011 - Enforce Free Daily Receipt Quota

**Files:** Update Firebase Functions quota/gateway code and create tests under `functions/test/`.

**Steps:** Check `receipt_extraction` quota before provider call. If exhausted, return a structured quota response and do not call Gemini.

**Done When:** Exhausted users consume zero receipt provider requests.

### [X] T012 - Add Receipt Capture UI

**Files:** Create `lib/screens/ai_assistant/widgets/receipt_capture_button.dart`.

**Steps:** Let user pick/capture image; pass image to service; show loading.

**Done When:** User can start receipt extraction.

### [X] T013 - Show Receipt Preview

**Steps:** Reuse AI preview card; require user confirmation before create.

**Done When:** Receipt data never auto-saves.

### [X] T014 - Add Receipt Low-Confidence Handling

**Files:** Update receipt preview/cubit integration.

**Steps:** If amount/date/category confidence is low or fields are missing, show editable preview with clear missing-field messages instead of guessing.

**Done When:** Low-confidence receipt extraction asks the user to complete fields manually.

### [X] T015 - Add Duplicate Receipt Cache

**Files:** Update receipt service/cubit integration.

**Steps:** Avoid repeat provider calls for materially same image/input when a recent same-user result exists. Use local/safe fingerprinting; do not store raw images remotely.

**Done When:** Repeated analysis of the same receipt does not waste quota where safely detectable.

---

## Phase 3: AI Financial Advice With Daily Free Quota

### [X] T016 - Create `AiFinancialAdvicePayload`

**Files:** Create `lib/ai/models/ai_financial_advice_payload.dart`.

**Steps:** Include period, grounded input summary, advice text, confidence/quality note, quotaRemaining, generatedAt, provider metadata optional.

**Done When:** Advice responses are structured and can show quota status.

### [X] T017 - Create `FinancialAdviceAiService`

**Files:** Create `lib/ai/services/financial_advice_ai_service.dart`.

**Steps:** Define an interface that accepts local spending aggregates and requests short AI advice through the backend gateway only.

**Done When:** Flutter UI does not know provider details or secrets.

### [X] T018 - Add Firebase Functions Advice Endpoint

**Files:** Modify `functions/src/index.ts` and the existing AI gateway module.

**Steps:** Add an authenticated advice route/action that accepts spending summary JSON, validates it, builds a concise advice prompt, and returns structured JSON.

**Done When:** Advice goes through backend auth and provider secrets remain server-side.

### [X] T019 - Enforce Free Daily Advice Quota

**Files:** Modify backend gateway code and create backend quota tests under `functions/test/`.

**Steps:** Check per-user per-day advice usage before provider call; if daily limit is reached, return a quota error without calling Gemini. Make the limit configurable through environment/config with a conservative default.

**Done When:** Exhausted free-plan users consume zero provider requests.

### [X] T020 - Add Advice UI Entry Point

**Files:** Create `lib/screens/ai_assistant/widgets/financial_advice_button.dart` and integrate it into the AI assistant surface.

**Steps:** Let the user explicitly request advice for current week/month; show loading, result text, quota remaining, and a quota-exhausted state.

**Done When:** Advice is user-triggered and never runs automatically on app open/refresh.

### [X] T021 - Cache Same-Day Advice Where Safe

**Files:** Update advice service/cubit integration as needed.

**Steps:** Reuse the latest same-user same-period same-day advice when the underlying summary has not changed meaningfully.

**Done When:** Repeated taps do not waste free API requests unnecessarily.

---

## Phase 4: Repeated Expense Detection

### [X] T022 - Create Detector

**Files:** Create `lib/ai/services/repeated_expense_detector.dart`.

**Steps:** Accept expense history; find similar amount/category/description patterns.

**Done When:** Detector returns suggestions without UI and does not call AI.

### [X] T023 - Group Similar Expenses

**Steps:** Use amount tolerance, same category, normalized description/merchant, and recurring date interval.

**Done When:** Repeated subscriptions are detected.

### [X] T024 - Suggest Recurring Expense

**Steps:** Show suggestion card with detected pattern and proposed recurrence frequency.

**Done When:** User can review suggestion.

### [X] T025 - Require Confirmation

**Steps:** If user accepts, open recurring expense form prefilled; do not create directly.

**Done When:** AI suggestion remains confirmation-first.

---

## Phase 5: Local Prediction

### [X] T026 - Create Prediction Payload

**Files:** Create `lib/ai/models/ai_prediction_payload.dart`.

**Steps:** Include period, expected total, category drivers, confidence/quality note.

**Done When:** Prediction result is structured.

### [X] T027 - Create Prediction Service

**Files:** Create `lib/ai/services/spending_prediction_service.dart`.

**Steps:** Start with simple historical averages by week/month and category.

**Done When:** Prediction runs locally without remote AI.

### [X] T028 - Show Category Drivers

**Steps:** Display which categories contribute most to predicted spend.

**Done When:** Prediction is explainable.

### [X] T029 - Add Guidance Disclaimer

**Steps:** UI copy should say prediction is guidance based on history, not a financial guarantee.

**Done When:** User understands uncertainty.

---

## Phase 6: Tests

### [X] T030 - Detector Tests

Test repeated monthly subscription, weekly transport, and non-repeated random expenses.

### [X] T031 - Prediction Tests

Test average calculation, empty history, category drivers.

### [X] T032 - Financial Advice Quota Tests

Test allowed advice request, exhausted daily quota, provider not called after quota exhaustion, and quota reset on a new day.

### [X] T033 - Receipt Quota Tests

Test allowed receipt request, exhausted receipt quota, provider not called after receipt quota exhaustion, and quota reset on a new day.

### [X] T034 - Local Fallback Tests

Test AI disabled, Firebase Functions unavailable, quota exhausted, and provider failure states still allow manual expense entry and local insight flows.

### [ ] T035 - Manual Receipt QA

Use a sample receipt image and verify preview fields can be edited before save.

### [ ] T036 - Manual Advice And Receipt Quota QA

Use a free-plan test user, request advice and receipt extraction until daily limits are reached, verify quota messages appear, and verify no extra provider calls are made after exhaustion.
