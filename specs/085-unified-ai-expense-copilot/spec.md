# Feature Specification: Unified AI Expense Copilot

**Feature Branch**: `085-unified-ai-expense-copilot`  
**Created**: 2026-05-27  
**Status**: Draft  
**Input**: User wants one smart AI experience across Home and Add Expense. The AI should fill all fields, create a category when missing, leave truly unknown fields empty for manual review, and behave like a complete assistant rather than a simple form filler.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - One AI Experience Everywhere (Priority: P1)

As a user, I want the AI on Home and inside Add Expense to look and behave the same, so I do not learn two different expense-entry flows.

**Why this priority**: Current inconsistency causes confusion and makes the Add Expense AI feel weaker.

**Independent Test**: Enter the same natural-language text from Home AI and Add Expense AI and verify both produce the same editable draft and save behavior.

**Acceptance Scenarios**:

1. **Given** the user opens Home AI, **When** they type an expense, **Then** the AI creates the same draft model used by Add Expense.
2. **Given** the user opens Add Expense from the `+` button, **When** they use AI, **Then** the same capture widget, fields, validation, and category suggestion behavior appear.
3. **Given** the AI cannot infer a field, **When** it returns a draft, **Then** the field stays empty and the user can fill it manually.

---

### User Story 2 - AI Controls Full Expense Draft (Priority: P1)

As a user, I want AI to fill amount, currency, date, payment method, category, merchant, tags, description, source confidence, and missing fields, so I only review and correct instead of rebuilding the form.

**Why this priority**: This is the core value of paying for or trusting AI.

**Independent Test**: Use Arabic and English prompts with amount, date, merchant, category, and tags; verify every known field maps into the form.

**Acceptance Scenarios**:

1. **Given** text includes "دفعت 300 جنيه أكل امبارح نقدا عند كارفور", **When** AI parses it, **Then** amount, EGP, Food, yesterday date, cash, merchant, and description are filled.
2. **Given** text includes a new category not in the user's list, **When** AI creates a draft, **Then** it proposes a new category with icon/color metadata for review.
3. **Given** text is partial, **When** AI parses it, **Then** unknown fields remain empty with a visible "needs review" status.

---

### User Story 3 - Safe Category Creation During Save (Priority: P1)

As a user, I want AI to create a new category only after I confirm the draft, so the app feels smart without letting AI mutate my data silently.

**Why this priority**: Category writes affect future reporting and must be explicit.

**Independent Test**: Parse an expense with a new category, press Save, and verify the category is created first and the expense uses it.

**Acceptance Scenarios**:

1. **Given** AI suggests a new category, **When** the user confirms Save, **Then** the app creates the category through the existing category repository and then saves the expense.
2. **Given** category creation fails, **When** the user tries to save, **Then** the expense is not saved with an invalid category and a localized retry message appears.
3. **Given** the category already exists by name or alias, **When** AI suggests it, **Then** the existing category is used rather than duplicating it.

### Edge Cases

- AI gateway unavailable: manual form remains usable and AI shows a clear fallback.
- Quota exhausted: manual form remains usable and the AI surface explains the quota state.
- Ambiguous category: AI presents the best match and marks the draft for review.
- Arabic colloquial input: parser should not reject useful partial drafts.
- Settings unavailable: AI must not silently choose fallback currency/payment method.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Home AI and Add Expense AI MUST use the same draft model and capture component.
- **FR-002**: AI MUST be able to populate all editable expense fields when the information is present.
- **FR-003**: AI MUST leave unknown or ambiguous fields empty or marked for review instead of blocking the whole draft.
- **FR-004**: AI-suggested categories MUST remain draft metadata until the user confirms Save.
- **FR-005**: Category creation MUST go through `CategoryRepository` and existing domain flows, not direct AI writes.
- **FR-006**: Expense creation MUST go through existing create expense Bloc/repository flow after user confirmation.
- **FR-007**: The shared AI widget MUST respect app language, RTL, AI quota, gateway errors, and settings load state.
- **FR-008**: AI must not store provider keys or secrets in Flutter.
- **FR-009**: Both entry points MUST support receipt/voice extensions without duplicating business logic.

### Key Entities

- **AiExpenseDraft**: Unified draft containing expense fields, missing fields, confidence, source, and suggested category metadata.
- **SuggestedCategoryDraft**: Proposed category name/icon/color/alias evidence that is not persisted until confirmed.
- **AiExpenseCaptureController**: Shared coordinator for text/voice/receipt parse, draft application, validation, and save orchestration.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The same prompt produces identical draft data from Home AI and Add Expense AI in 100% of shared parser tests.
- **SC-002**: AI-created category save path succeeds in tests without direct widget-level repository writes.
- **SC-003**: At least 90% of provided Arabic/English fixture prompts produce a usable partial or complete draft, not a generic "need amount/category/date/payment" rejection.
- **SC-004**: Manual expense entry remains available when AI gateway, quota, settings, voice, or receipt services fail.

## Assumptions

- AI remains a draft assistant; it does not save expenses without user confirmation.
- The Cloudflare Worker remains the provider-secret boundary.
- Existing `AiCategoryResolver` and category alias behavior are reused and strengthened.
