# Tasks: Smarter AI Expense Inference

**Input**: Design documents from `specs/055-ai-expense-inference/`  
**Prerequisites**: `spec.md`, `plan.md`

## Phase 1: Setup

- [X] T001 Inspect Flutter AI add-expense flow in `lib/ai/cubit/ai_assistant_cubit.dart`, `lib/ai/services/ai_response_parser.dart`, and `lib/ai/models/ai_action_preview.dart`.
- [X] T002 [P] Inspect local fallback parsing in `lib/ai/services/mock_ai_service.dart`.
- [X] T003 [P] Inspect Worker prompt and normalization in `workers/ai-gateway/src/ai/promptBuilder.ts` and `workers/ai-gateway/src/ai/structuredSchema.ts`.
- [X] T004 [P] Inspect current AI tests in `test/ai/ai_assistant_cubit_test.dart` and `workers/ai-gateway/test/structuredSchema.test.ts`.

---

## Phase 2: Foundational

- [X] T005 Define shared add-expense critical-field rule in Flutter: amount plus category after category resolver, in `lib/ai/cubit/ai_assistant_cubit.dart`.
- [X] T006 Update parser required-field behavior in `lib/ai/services/ai_response_parser.dart` so missing date/payment method does not throw when amount exists.
- [X] T007 Update `AiResponse.requiresClarification` in `lib/ai/models/ai_response.dart` to align with critical-field semantics.
- [X] T008 Add relative date support for `last night` and `tonight` in `lib/ai/services/ai_response_parser.dart`.

---

## Phase 3: User Story 1 - Infer Complete Preview From Common Expense Text (Priority: P1)

**Goal**: The reported sentence produces preview immediately.

**Independent Test**: `spent 100 dollar on food last night` resolves to a preview with USD, Food, yesterday, and default payment method.

- [X] T009 [P] [US1] Add Flutter test for reported English sentence in `test/ai/ai_assistant_cubit_test.dart`.
- [X] T010 [US1] Update `MockAiService` in `lib/ai/services/mock_ai_service.dart` to use default payment method when payment is omitted.
- [X] T011 [US1] Update `AiAssistantCubit` in `lib/ai/cubit/ai_assistant_cubit.dart` to build inferred preview before rejecting low confidence caused only by defaultable fields.
- [X] T012 [US1] Update Worker date inference for `last night` in `workers/ai-gateway/src/ai/structuredSchema.ts`.
- [X] T013 [P] [US1] Add Worker structured-schema test for `spent 100 dollar on food last night` in `workers/ai-gateway/test/structuredSchema.test.ts`.

---

## Phase 4: User Story 2 - Ask Only For Truly Missing Critical Information (Priority: P1)

**Goal**: Clarification asks for amount/category only when those cannot be inferred.

**Independent Test**: Missing amount asks amount only; missing category asks category only; omitted payment/date/currency uses defaults.

- [X] T014 [P] [US2] Add Flutter tests for missing amount, missing category, and omitted payment method in `test/ai/ai_assistant_cubit_test.dart`.
- [X] T015 [US2] Replace broad fallback clarification strings in `lib/ai/cubit/ai_assistant_cubit.dart` with targeted missing-field text.
- [X] T016 [US2] Update Worker `missingAddExpenseFields()` and `buildClarifyingQuestion()` in `workers/ai-gateway/src/ai/structuredSchema.ts` to exclude defaultable fields after normalization.
- [X] T017 [P] [US2] Add Worker tests for omitted payment/date/currency and missing critical fields in `workers/ai-gateway/test/structuredSchema.test.ts`.

---

## Phase 5: User Story 3 - Keep Confirmation Safety (Priority: P2)

**Goal**: Smarter inference still requires confirmation and editable preview.

**Independent Test**: Inferred preview remains `previewReady`, not confirmed/saved, until user confirms.

- [X] T018 [US3] Confirm `AiAssistantCubit.confirmPreview()` remains the only add-expense write path in `lib/ai/cubit/ai_assistant_cubit.dart`.
- [X] T019 [P] [US3] Add/adjust Flutter test verifying inferred preview does not create expense before confirm in `test/ai/ai_assistant_cubit_test.dart`.
- [X] T020 [US3] Preserve suggested-category confirmation behavior in `lib/screens/ai_assistant/views/ai_assistant_sheet.dart`.

---

## Phase 6: Verification

- [X] T021 Run Flutter AI tests.
- [X] T022 Run Worker `npm test`.
- [X] T023 Run Worker `npm run typecheck`.
- [X] T024 Run `flutter analyze --no-pub`.

## Dependencies & Execution Order

- T005-T008 block all user-story implementation.
- US1 and US2 can run in parallel after foundational rules are updated.
- US3 should run after US1 preview behavior is working.

## Notes

- Do not remove confirmation.
- Do not invent amount or category when absent.
- Do not put provider secrets or prompt keys into Flutter.
