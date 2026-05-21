# Feature Specification: Expense Model Upgrade

**Feature Branch**: `003-expense-model-upgrade`
**Created**: 2026-05-15
**Status**: Draft

## User Scenarios & Testing

### User Story 1 - Expenses Store Complete Details (P1)
As a user, every expense stores amount, category, date, description, payment method, currency, and source.

**Acceptance Criteria**
- New expense documents include all upgraded fields.
- Existing simple documents still deserialize safely.

### User Story 2 - Expenses Can Be Updated And Deleted (P1)
As a user, I can correct or remove expenses after saving.

**Acceptance Criteria**
- Repository exposes update and delete methods.
- UI and AI flows can call those methods through Bloc/repository layers.

## Functional Requirements

- Add `PaymentMethod` enum.
- Add `ExpenseSource` enum.
- Add category snapshot fields.
- Add timestamps.
- Add update/delete/get/filter repository methods.
- Update Add Expense and Home rendering.

## Out Of Scope

- Full advanced filtering UI.
- AI Assistant actions.
- Budget logic.

## Success Metrics

- Serialization tests pass for old and new expense documents.
- No UI code writes directly to Firestore.

## Detailed Requirements And Edge Cases

- Old documents with embedded `category` must continue to load.
- New documents should prefer `categoryId` plus category snapshot fields for list rendering.
- Missing `paymentMethod`, `currency`, `description`, and `source` must have safe defaults.
- Update operations must refresh `updatedAt`.
- Delete operations must only delete the expense document, not the related category.
- Amount remains integer in this phase unless a separate money precision decision is approved.
