# Feature Specification: AI Category Intelligence

**Feature Branch**: `[019-ai-category-intelligence]`  
**Created**: 2026-05-17  
**Status**: Draft  
**Input**: User wants the AI Assistant to compare the expense source with existing categories such as food, transport, and others, decide whether a matching category exists, and create a safe category suggestion only after user confirmation.

## User Scenarios & Testing

### User Story 1 - Match Expense Source To Existing Category (Priority: P1)

As a user, when I type or speak an expense like "صرفت 100 جنيه على أوبر" or "اشتريت أكل من مطعم", the assistant should compare the source words, merchant words, and description against my active categories and select the best existing category.

**Why this priority**: The current AI can return a generic category name that does not always match the user's real category list, causing preview validation errors.

**Independent Test**: With active categories `Food` and `Transport`, submit Arabic and English expenses that mention restaurants, groceries, Uber, taxi, metro, fuel, bills, shopping, and entertainment. Each should produce a preview with the correct existing category selected.

**Acceptance Scenarios**:

1. **Given** active category `Transport`, **When** the user enters "صرفت 100 جنيه امبارح على المواصلات", **Then** the preview selects `Transport`, date is yesterday, payment defaults to Cash, and the user can edit before confirm.
2. **Given** active category `Food`, **When** the user enters "دفعت 250 في مطعم بالكاش", **Then** the preview selects `Food` and explains the match was based on restaurant words.
3. **Given** both `Shopping` and `Food` categories, **When** the source is ambiguous, **Then** the assistant asks a clarification or shows a low-confidence preview instead of choosing silently.

---

### User Story 2 - Suggest Missing Category Without Auto-Creating It (Priority: P1)

As a user, when the expense source does not match any active category, the assistant should propose a new category name, icon, and color in the preview, but must not create the category until I confirm.

**Why this priority**: Users will naturally mention sources that do not exist yet. Auto-creating categories would clutter Firestore and violates the confirmation-first AI rule.

**Independent Test**: With no `Subscriptions` category, enter "دفعت اشتراك نتفليكس 200 جنيه". The assistant should show an editable suggested category and require explicit confirmation before creating it.

**Acceptance Scenarios**:

1. **Given** no category matches "Netflix", **When** the user submits the expense, **Then** the preview shows a suggested `Subscriptions` category and a separate confirmation step for category creation.
2. **Given** the user edits the suggested category name before confirming, **When** they confirm, **Then** the created expense uses the edited category.
3. **Given** the user cancels the preview, **When** the sheet closes, **Then** no category and no expense are saved.

---

### User Story 3 - Remember User Category Aliases (Priority: P2)

As a user, when I repeatedly map a source word like "أوبر" to `Transport`, the app should remember that preference for my account and use it in future deterministic matching before calling AI.

**Why this priority**: This reduces AI requests, improves consistency, and supports offline/manual fallback.

**Independent Test**: Confirm an expense where "أوبر" maps to `Transport`, then run another command containing "أوبر" while AI is unavailable. The local resolver should still select `Transport`.

**Acceptance Scenarios**:

1. **Given** a confirmed mapping "أوبر" -> `Transport`, **When** AI is unavailable, **Then** local matching still resolves `Transport`.
2. **Given** a category is archived, **When** an alias points to it, **Then** the alias is ignored and the user is asked to select a new active category.

### Edge Cases

- Multiple categories have similar names or aliases.
- The AI returns a category name that is not in the user's active category list.
- The user has zero categories.
- Categories are archived after aliases were learned.
- Arabic text arrives with different spelling: "اوبر", "أوبر", "المواصلات", "مواصلات".
- AI quota is exhausted and only deterministic local matching is available.

## Requirements

### Functional Requirements

- **FR-001**: The system MUST resolve an AI add-expense category by comparing the input against active category ids, names, aliases, known source terms, and recent confirmed mappings.
- **FR-002**: The system MUST prefer an existing active user category over creating or suggesting a new category.
- **FR-003**: The system MUST never create a category directly from AI output without explicit user confirmation.
- **FR-004**: The system MUST show category match confidence and a short reason in the preview when the confidence is not perfect or when a new category is suggested.
- **FR-005**: The system MUST support Arabic and English aliases for common categories: food, transport, shopping, bills, entertainment, health, travel, subscriptions, education, rent, utilities, fuel, and income-like words that should be rejected as expenses unless user confirms.
- **FR-006**: The system MUST ignore archived categories for new expense matching while preserving old expense category snapshots.
- **FR-007**: The system MUST keep deterministic local matching available when the remote AI gateway is unavailable, quota is exhausted, or the user is offline.
- **FR-008**: The Worker prompt and schema MUST return category fields in a way the Flutter parser can validate: existing `categoryId` when known, otherwise `category`, confidence, and clarification/suggestion metadata.
- **FR-009**: If amount, date, or category cannot be inferred confidently, the assistant MUST ask for clarification instead of showing a failing red error.
- **FR-010**: Confirmed alias learning MUST be user-scoped and must not affect other users.

### Key Entities

- **CategoryResolution**: The selected or suggested category result, including categoryId, name, confidence, reason, and source.
- **CategoryAlias**: User-scoped mapping between source words and a category id.
- **CategorySuggestion**: Editable proposed category name, icon key, color, and reason.
- **AiExpensePayload Extension**: Optional metadata for category resolution and suggested category preview.

## Success Criteria

### Measurable Outcomes

- **SC-001**: At least 90% of common Arabic/English test phrases for food, transport, bills, shopping, and entertainment select the expected existing category.
- **SC-002**: 100% of AI-created categories require explicit user confirmation.
- **SC-003**: No high-confidence add-expense preview fails because of missing category when the source clearly maps to a known alias.
- **SC-004**: Local category matching works in under 300 ms for 100 categories and 1,000 aliases on a mid-range Android device.

## Assumptions

- Existing `CategoryRepository` remains the owner of category persistence.
- Existing `AiAssistantCubit` remains the owner of AI preview state.
- New categories will reuse the existing category creation flow rather than adding direct writes to the AI service.
- Initial alias set is curated in code; user-learned aliases are stored per user.
