# Feature Specification: Add Expense Quick Capture UX

**Feature Branch**: `068-add-expense-quick-capture-ux`  
**Created**: 2026-05-20  
**Status**: Draft  
**Input**: User requested a plan for making Add Expense faster and less crowded while keeping AI draft behavior.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Add A Simple Expense Fast (Priority: P1)

As a daily user, I need to record a simple expense such as "coffee 50" in a few seconds without navigating a complex form.

**Why this priority**: Add Expense is the most repeated journey.

**Independent Test**: A user can create a valid simple expense from Home with minimal taps and no AI dependency.

**Acceptance Scenarios**:

1. **Given** the user taps add, **When** they choose quick expense, **Then** they can enter amount/category/defaults and save quickly.
2. **Given** AI is unavailable, **When** the user adds manually, **Then** manual entry still works.

---

### User Story 2 - Natural Language Draft Is First-Class (Priority: P1)

As a user, I need to type "paid 120 food yesterday" and get an editable draft, not an automatic save.

**Why this priority**: AI should reduce friction without reducing control.

**Independent Test**: Natural input fills known fields and leaves missing fields editable.

**Acceptance Scenarios**:

1. **Given** AI parses amount/category/date, **When** the draft appears, **Then** the user can edit every field before saving.
2. **Given** AI cannot infer payment method, **When** draft appears, **Then** the field remains default/blank and user can choose manually.

---

### User Story 3 - Receipt Capture Is Clear (Priority: P2)

As a receipt user, I need a clear "scan receipt" path that produces the same editable draft as text AI.

**Why this priority**: Receipt capture is valuable but should not complicate simple entry.

**Independent Test**: Receipt scan is reachable as a distinct method and returns to the editable expense form.

**Acceptance Scenarios**:

1. **Given** receipt AI succeeds, **When** extraction completes, **Then** fields are filled as a draft.
2. **Given** receipt AI fails, **When** the error appears, **Then** the manual form remains usable.

## Edge Cases

- AI quota exhausted.
- Settings failed to load.
- Keyboard open on small screen.
- User switches method after typing.
- Offline manual save with pending-write feedback.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Add Expense MUST present clear paths for quick manual entry, natural-language draft, and receipt scan.
- **FR-002**: AI results MUST never save automatically.
- **FR-003**: Manual save MUST remain available when AI or receipt parsing fails.
- **FR-004**: Missing AI fields MUST remain editable instead of blocking the draft.
- **FR-005**: Add flow MUST use user settings defaults only when settings load succeeds or the user explicitly chooses values.
- **FR-006**: Small-screen keyboard-open layout MUST keep save actions reachable.

### Key Entities

- **CaptureMode**: Quick manual, natural language, or receipt.
- **ExpenseDraft**: Editable expense state from manual input, AI, or receipt.
- **DraftSourceStatus**: AI/receipt/manual source, confidence, missing fields, and user review state.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A simple manual expense can be created in under 10 seconds by a returning user.
- **SC-002**: 100% of AI/receipt saves require explicit user Save/Confirm action.
- **SC-003**: Add Expense remains usable when AI gateway is unavailable.
- **SC-004**: Keyboard-open Add Expense has no blocked primary action on small Android viewport.

## Assumptions

- The existing Add Expense screen remains the main creation surface.
- AI and receipt paths fill the same underlying editable draft model.

