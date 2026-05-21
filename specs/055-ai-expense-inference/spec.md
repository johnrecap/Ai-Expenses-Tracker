# Feature Specification: Smarter AI Expense Inference

**Feature Branch**: `055-ai-expense-inference`  
**Created**: 2026-05-19  
**Status**: Draft  
**Input**: User report that `spent 100 dollar on food last night` contains enough information, but the AI asks for amount, category, date, and payment method, making the flow worse than manual entry.

## User Scenarios & Testing

### User Story 1 - Infer Complete Preview From Common Expense Text (Priority: P1)

As a user, I want the AI assistant to turn a normal sentence into an editable expense preview without asking for details it can infer.

**Why this priority**: If the AI asks for basic details after the user gave amount, currency, category, and date context, users will abandon AI and enter expenses manually.

**Independent Test**: Submit `spent 100 dollar on food last night` with default payment method and verify a preview is produced with amount 100, USD, Food, yesterday date, and default payment method.

**Acceptance Scenarios**:

1. **Given** the input `spent 100 dollar on food last night`, **When** the user taps AI parse, **Then** the assistant shows a confirmation preview instead of asking for amount/category/date/payment method.
2. **Given** the input omits payment method, **When** default payment method exists in settings, **Then** the assistant uses the default payment method and marks it as inferred.
3. **Given** the input uses `last night`, **When** today is known, **Then** the assistant resolves it to yesterday's date.

---

### User Story 2 - Ask Only For Truly Missing Critical Information (Priority: P1)

As a user, I want clarification only when the assistant cannot safely infer amount or category from text and app context.

**Why this priority**: Asking for every field wastes the value of AI and duplicates manual entry.

**Independent Test**: Submit text missing amount and verify the assistant asks only for amount; submit text missing category and verify it asks only for category.

**Acceptance Scenarios**:

1. **Given** the input `food last night`, **When** amount is missing, **Then** the assistant asks for amount only.
2. **Given** the input `spent 100 dollars last night` and no category can be inferred, **When** parsing completes, **Then** the assistant asks for category only.
3. **Given** date, payment method, or currency is omitted, **When** defaults or safe inference exist, **Then** the assistant should not ask for those fields.

---

### User Story 3 - Keep Confirmation Safety (Priority: P2)

As a user, I want the AI to be smarter without silently saving wrong expenses.

**Why this priority**: The app must stay confirmation-first even when it infers defaults.

**Independent Test**: Verify inferred previews still require user confirmation and can be edited before save.

**Acceptance Scenarios**:

1. **Given** the AI infers payment method, date, or currency, **When** preview appears, **Then** the user can edit those fields before confirming.
2. **Given** the AI suggests a category that does not exist, **When** preview appears, **Then** the app clearly shows it as a suggestion and creates it only after confirmation.

### Edge Cases

- `last night` should resolve to yesterday, while `tonight` and `today` resolve to today.
- Arabic equivalents for yesterday/today and common category words must remain supported.
- If the remote gateway returns low confidence but the client can confidently fill safe defaults, the client should not show a broad misleading clarification.
- Amount and category remain critical; they should not be invented when absent.
- The UI must not claim an expense is saved until the user confirms.

## Requirements

### Functional Requirements

- **FR-001**: The AI flow MUST infer date, currency, and payment method from input or app defaults before asking for clarification.
- **FR-002**: The AI flow MUST treat amount and category as the only critical add-expense fields that require clarification when they cannot be inferred.
- **FR-003**: The AI flow MUST resolve common English relative dates including `last night`, `yesterday`, `today`, and `tonight`.
- **FR-004**: The AI flow MUST preserve Arabic relative-date and category inference already supported by the app/gateway.
- **FR-005**: Clarification messages MUST list only the missing critical fields, not a generic list of all fields.
- **FR-006**: The confirmation preview MUST still be required before any expense write.
- **FR-007**: The local mock service and Cloudflare gateway normalization MUST follow the same inference rules for add-expense text.
- **FR-008**: Tests MUST cover the reported sentence and missing-critical-field cases.

### Key Entities

- **AiContext**: Current app defaults and user data used to infer omitted fields.
- **AiResponse**: Parsed intent and payload from local or remote AI services.
- **AiExpensePayload**: Parsed add-expense data before preview.
- **AiActionPreview**: Editable confirmation preview produced before saving.
- **Gateway Structured Response**: Cloudflare-normalized provider output for remote AI calls.

## Success Criteria

### Measurable Outcomes

- **SC-001**: `spent 100 dollar on food last night` produces a preview without clarification.
- **SC-002**: Inputs missing only payment method, date, or currency produce previews using defaults/inference.
- **SC-003**: Inputs missing amount ask only for amount; inputs missing category ask only for category.
- **SC-004**: Existing AI confirmation and category-suggestion safety tests continue to pass.

## Assumptions

- The user's default payment method from Settings is safe to use when payment method is omitted.
- The user's base currency is safe to use when currency is omitted.
- Amount and category must remain explicit or confidently inferred; the app should not guess them from nothing.
- Provider prompt, gateway normalization, and client fallback should be aligned so release behavior is consistent whether the gateway is configured or not.
