# Feature Specification: Flexible AI Expense Drafts

**Feature Branch**: `056-ai-flexible-expense-drafts`  
**Created**: 2026-05-19  
**Status**: Draft  
**Input**: User wants AI to handle any expense input by creating an editable draft, leaving unknown fields empty instead of asking for missing details.

## User Scenarios & Testing

### User Story 1 - Draft From Any Expense Text (Priority: P1)

As a user, I want the AI assistant to turn any non-empty expense text into an editable draft, even when some fields are missing or unclear.

**Independent Test**: Submit vague text like `food last night` and verify an editable preview appears with missing amount blank and validation shown, not a clarification-only response.

### User Story 2 - Leave Unknown Fields For Manual Completion (Priority: P1)

As a user, I want missing or uncertain amount/category fields to remain editable rather than blocking the flow with repeated questions.

**Independent Test**: Submit text missing amount or category and verify the preview remains visible, confirm is disabled, and the user can fill the missing field manually.

### User Story 3 - Preserve Confirmation Safety (Priority: P1)

As a user, I want flexible AI drafting without automatic saving.

**Independent Test**: Any inferred or incomplete draft must remain unsaved until the user fixes validation errors and confirms.

## Requirements

- **FR-001**: The AI add-expense parser MUST accept add-expense payloads with missing amount or category.
- **FR-002**: The AI assistant MUST show an editable preview for non-empty add-expense input even when amount/category is missing.
- **FR-003**: Missing amount MUST display as an empty amount field, not `0`.
- **FR-004**: Missing category MUST keep the manual category-name field visible and editable.
- **FR-005**: The confirmation button MUST remain disabled while validation errors exist.
- **FR-006**: Unknown/non-empty parse responses SHOULD fall back to an editable expense draft when no safer command intent is available.
- **FR-007**: Worker normalization MUST stop returning clarification questions for missing draft fields and should let the client show editable validation.
- **FR-008**: Confirmation and category-suggestion creation behavior MUST remain unchanged.

## Success Criteria

- **SC-001**: `food last night` shows a draft preview with blank amount and Food/yesterday when inferable.
- **SC-002**: `spent 100 last night` shows a draft preview with amount/date/defaults and an editable empty category field.
- **SC-003**: Completely vague non-empty input shows an editable draft with description/defaults and validation errors instead of a blocking clarification.
- **SC-004**: No expense is created before explicit confirmation.

## Out Of Scope

- No automatic expense writes.
- No provider secret changes.
- No Worker deployment or production AI gateway QA.
