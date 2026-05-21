# Feature Specification: Manual Expense Edit And Delete

**Feature Branch**: `049-manual-expense-edit-delete`  
**Created**: 2026-05-18  
**Status**: Draft  
**Input**: UX review finding that expenses can be updated/deleted through AI command confirmation paths but there is no explicit manual UI for editing or deleting an expense.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Edit An Existing Expense Manually (Priority: P1)

Users must be able to correct amount, category, description, payment method, currency, and date for an existing expense from the expense list.

**Why this priority**: Manual finance tracking must not depend on AI for basic corrections.

**Independent Test**: A widget or bloc test opens an expense edit flow with existing values, saves a change, and verifies `ExpenseRepository.updateExpense` is called with updated fields while preserving ownership and ids.

**Acceptance Scenarios**:

1. **Given** a user sees an expense in the list, **When** they choose edit, **Then** the edit form opens with the current expense values.
2. **Given** the user changes valid fields and saves, **When** the repository update succeeds, **Then** the list reflects the updated expense.
3. **Given** invalid input is entered, **When** the user tries to save, **Then** the app shows a localized validation message and does not update the expense.

---

### User Story 2 - Delete An Expense Manually With Confirmation (Priority: P1)

Users must be able to delete an incorrect expense only after an explicit confirmation step.

**Why this priority**: Deletion is destructive and must be available without AI while remaining safe.

**Independent Test**: A widget/bloc test confirms delete and verifies `ExpenseRepository.deleteExpense(expenseId)` is called only after confirmation.

**Acceptance Scenarios**:

1. **Given** a user chooses delete on an expense, **When** the confirmation dialog appears, **Then** it shows enough context to avoid accidental deletion.
2. **Given** the user cancels, **When** the dialog closes, **Then** no repository delete occurs.
3. **Given** the user confirms, **When** repository delete succeeds, **Then** the expense disappears from the list and a localized success message appears.

---

### User Story 3 - Keep Manual And AI Mutation Paths Consistent (Priority: P2)

Manual edit/delete must use the same repository boundaries and user-safe validation principles as AI confirmation.

**Why this priority**: Two mutation paths should not diverge in ownership, sync status, or validation behavior.

**Independent Test**: Repository fake tests verify both manual and AI paths update/delete through `ExpenseRepository` without direct Firestore writes in widgets.

**Acceptance Scenarios**:

1. **Given** manual edit saves, **When** code is inspected, **Then** widgets do not import Firestore directly.
2. **Given** manual delete succeeds or fails, **When** UI handles the result, **Then** localized feedback is shown.

## Edge Cases

- Existing category snapshots must remain consistent when category changes.
- Deleting a recurring-generated expense must not delete or archive the recurring rule.
- Deleting an AI-created expense must not delete the AI action log.
- Update failures due to offline/pending writes should show safe feedback without losing local state.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Expenses list must expose edit and delete actions for each expense.
- **FR-002**: Edit flow must prefill existing expense values.
- **FR-003**: Edit flow must validate positive amount, category, currency, payment method, and date before saving.
- **FR-004**: Edit save must call `ExpenseRepository.updateExpense` through existing Bloc/Cubit/repository boundaries.
- **FR-005**: Delete flow must show a confirmation dialog before calling `ExpenseRepository.deleteExpense`.
- **FR-006**: Delete cancel must not call the repository.
- **FR-007**: All new user-facing strings must use l10n.
- **FR-008**: Manual edit/delete must not use AI services.
- **FR-009**: Manual delete must not remove category, recurring rule, or AI action log documents.

### Key Entities

- **Editable Expense**: Existing expense with id, owner, category snapshot, amount, date, description, payment method, currency, source, and optional references.
- **Edit Flow**: UI path for updating an existing expense.
- **Delete Confirmation**: Explicit destructive-action dialog.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can edit an existing expense without AI.
- **SC-002**: Users can delete an existing expense only after confirmation.
- **SC-003**: Tests prove canceling delete does not call `deleteExpense`.
- **SC-004**: New edit/delete copy is localized in English and Arabic.

## Assumptions

- Current repository update/delete methods remain the mutation boundary.
- Hard delete of expense documents is acceptable because the repository already exposes `deleteExpense`; category deletion remains archival only.
- Undo after delete is optional and must be explicitly designed if included.
