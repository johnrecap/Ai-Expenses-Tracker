# Tasks: AI Text To Expense Preview

## Implementation Intent

Implement AI-assisted add expense safely. AI returns structured data, the app validates it, and the user confirms before any write happens.

## Completion Checklist

- [x] T001 - Create `AiIntent`
- [x] T002 - Create `AiResponse`
- [x] T003 - Create `AiExpensePayload`
- [x] T004 - Create `AiActionPreview`
- [x] T005 - Create `AiService`
- [x] T006 - Create `MockAiService`
- [x] T007 - Create `RemoteAiService` Placeholder
- [x] T008 - Create Strict Parser
- [x] T009 - Create `AiAssistantCubit`
- [x] T010 - Add States
- [x] T011 - Confidence Threshold
- [x] T012 - Category/Date/Payment Mapping
- [x] T013 - Assistant Bottom Sheet
- [x] T014 - AI Text Input
- [x] T015 - Preview Card
- [x] T016 - Editable Preview
- [x] T017 - Confirm Through Existing Flow
- [x] T018 - Parser Tests
- [x] T019 - Cubit Tests
- [ ] T020 - Manual Arabic QA

## Deferred Items

- T020 is intentionally deferred because this worker was instructed not to run verification or manual QA. The scenario to verify later is: open the AI Assistant, enter `صرفت 250 جنيه على أكل امبارح بالكاش`, confirm the preview shows amount `250`, category `Food/أكل` when a matching category exists, date as yesterday, payment method `Cash`, currency `EGP`, then confirm and verify the expense is created through `CreateExpenseBloc` with `source = ai`.

---

## Phase 1: AI Models

### T001 - Create `AiIntent`

**Files:** Create `lib/ai/models/ai_intent.dart`.

**Steps:** Add `addExpense` and `unknown` for phase 1; include string mapping from JSON.

**Done When:** Parser can convert JSON intent safely.

### T002 - Create `AiResponse`

**Files:** Create `lib/ai/models/ai_response.dart`.

**Steps:** Include intent, expense payload, confidence, needsConfirmation, clarifyingQuestion, rawJson.

**Done When:** Cubit receives one structured response object.

### T003 - Create `AiExpensePayload`

**Files:** Create `lib/ai/models/ai_expense_payload.dart`.

**Steps:** Include amount, category name/id optional, date, payment method, currency, description.

**Done When:** Payload can map to `Expense`.

### T004 - Create `AiActionPreview`

**Files:** Create `lib/ai/models/ai_action_preview.dart`.

**Steps:** Store editable preview fields and validation errors.

**Done When:** UI can display and edit AI result.

---

## Phase 2: Services

### T005 - Create `AiService`

**Files:** Create `lib/ai/services/ai_service.dart`.

**Steps:** Define `parseExpenseText(String input, AiContext context)`.

**Done When:** AI provider can be swapped.

### T006 - Create `MockAiService`

**Files:** Create `lib/ai/services/mock_ai_service.dart`.

**Steps:** Deterministically parse known Arabic/English examples; return structured response without network.

**Done When:** Feature can be tested offline.

### T007 - Create `RemoteAiService` Placeholder

**Files:** Create `lib/ai/services/remote_ai_service.dart`.

**Steps:** Implement interface but keep provider config injectable; do not hardcode API keys.

**Done When:** Production provider can be added later safely.

### T008 - Create Strict Parser

**Files:** Create `lib/ai/services/ai_response_parser.dart`.

**Steps:** Decode JSON, reject malformed data, validate amount/date/payment method, apply confidence threshold.

**Done When:** Random text output cannot be treated as valid AI response.

---

## Phase 3: Cubit

### T009 - Create `AiAssistantCubit`

**Files:** Create `lib/ai/cubit/ai_assistant_cubit.dart` and state.

**Steps:** Implement parse, edit preview, confirm, cancel, reset.

**Done When:** UI has one state source.

### T010 - Add States

**Steps:** initial, parsing, previewReady, needsClarification, failure, confirming, confirmed.

**Done When:** Every AI outcome has UI representation.

### T011 - Confidence Threshold

**Steps:** If confidence < 0.75 or required fields missing, emit clarification/failure instead of preview.

**Done When:** Low-confidence AI cannot create expense.

### T012 - Category/Date/Payment Mapping

**Steps:** Map Arabic/English category names; parse today/yesterday; map cash/كاش/visa/wallet/bank transfer.

**Done When:** Example sentence extracts expected fields.

---

## Phase 4: UI

### T013 - Assistant Bottom Sheet

**Files:** Create `lib/screens/ai_assistant/views/ai_assistant_sheet.dart`.

**Steps:** Text input, parse button, loading state, error/clarification state.

**Done When:** User can open assistant and enter natural text.

### T014 - AI Text Input

**Files:** Create `lib/screens/ai_assistant/widgets/ai_text_input.dart`.

**Steps:** Multiline input, clear action, submit action.

**Done When:** Text entry is reusable.

### T015 - Preview Card

**Files:** Create `lib/screens/ai_assistant/widgets/ai_action_preview_card.dart`.

**Steps:** Show amount, category, date, payment, currency, description, confidence.

**Done When:** User can review all fields.

### T016 - Editable Preview

**Steps:** Allow editing amount/category/date/payment/currency/description before confirm.

**Done When:** User can correct AI mistakes.

### T017 - Confirm Through Existing Flow

**Steps:** On confirm, create `Expense` with `source = ai`; dispatch existing create bloc or repository abstraction.

**Done When:** AI service never writes to Firestore directly.

---

## Phase 5: Tests

### T018 - Parser Tests

Valid JSON, malformed JSON, low confidence, missing amount, yesterday date, Arabic cash.

### T019 - Cubit Tests

Parsing success, clarification, failure, edit preview, confirm.

### T020 - Manual Arabic QA

Use `صرفت 250 جنيه على أكل امبارح بالكاش` and verify preview values.
