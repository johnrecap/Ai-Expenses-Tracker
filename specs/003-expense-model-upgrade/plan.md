# Implementation Plan: Expense Model Upgrade

## Technical Context

Current `Expense` only stores id, category, date, and integer amount. Future features need richer fields.

## Architecture

Extend model/entity serialization while supporting old documents. Keep repository interface as the boundary for CRUD and filters.

## Files

- Create: `packages/expense_repository/lib/src/models/payment_method.dart`
- Create: `packages/expense_repository/lib/src/models/expense_source.dart`
- Create: `packages/expense_repository/lib/src/models/expense_filter.dart`
- Modify: `packages/expense_repository/lib/src/models/expense.dart`
- Modify: `packages/expense_repository/lib/src/entities/expense_entity.dart`
- Modify: `packages/expense_repository/lib/src/expense_repo.dart`
- Modify: `packages/expense_repository/lib/src/firebase_expense_repo.dart`
- Modify: `lib/screens/add_expense/views/add_expense.dart`
- Modify: `lib/screens/home/views/main_screen.dart`

## Data Model

Expense fields: `expenseId`, `userId`, `categoryId`, category snapshot, `amount`, `currency`, `description`, `paymentMethod`, `date`, `createdAt`, `updatedAt`, `source`, optional recurring and AI ids.

## Risks

- Old documents must not crash deserialization.
- Embedded category object should be phased into category snapshot fields.

## Verification

- Serialization tests for old and new documents.
- Bloc tests for create/update/delete.

## Detailed Execution Guidance

- Update serialization before UI so old Firestore data remains readable during development.
- Add defaults for every new field to prevent runtime crashes from old documents.
- Keep category snapshot fields available for list rendering after category edits/archives.
- Add repository CRUD methods before AI or filters attempt to use them.
- Do not introduce decimal money handling unless a separate precision plan approves it.
