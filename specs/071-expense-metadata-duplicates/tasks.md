# Tasks: Expense Metadata And Duplicate Detection

**Input**: `specs/071-expense-metadata-duplicates/spec.md`, `plan.md`

## Phase 1: Data Model

- [X] T001 Extend `Expense` and `ExpenseEntity` with optional merchant and tags.
  - **Why**: Metadata must be persisted consistently.
  - **Benefit**: Enables richer search and future AI insights.
  - **Expected**: Old documents still parse with null/empty metadata.

- [X] T002 Update `firestore.rules` and `functions/test/firestoreRules.rules.ts` for metadata validation.
  - **Why**: Rules must accept only safe metadata shapes.
  - **Benefit**: Prevents malformed or oversized fields.
  - **Expected**: Merchant length and tag list limits are enforced.

- [X] T003 Add repository/entity tests for merchant and tags.
  - **Why**: Serialization changes are high risk.
  - **Benefit**: Protects backward compatibility.
  - **Expected**: New and legacy expense documents round-trip.

## Phase 2: Duplicate Detection

- [X] T004 Add `DuplicateExpenseDetector` under `lib/services/finance/` or `lib/screens/add_expense/services/`.
  - **Why**: Duplicate logic should be deterministic and testable.
  - **Benefit**: Keeps warnings consistent across manual/AI/receipt paths.
  - **Expected**: Detector returns candidates, score, and reasons.

- [X] T005 Add detector tests for exact duplicate, near duplicate, legitimate repeated expense, missing category, and different day.
  - **Why**: Duplicate detection can easily be too aggressive.
  - **Benefit**: Balances trust and usability.
  - **Expected**: Warnings appear only for likely duplicates.

## Phase 3: UI And Draft Integration

- [X] T006 [US1] Add merchant and tags inputs to Add Expense full details.
  - **Why**: Users need a way to enrich expense data.
  - **Benefit**: Better later search and reporting.
  - **Expected**: Inputs are optional and do not slow quick entry.

- [X] T007 [US2] Run duplicate detection before manual save.
  - **Why**: Manual duplicate entry is common.
  - **Benefit**: Prevents accidental wrong totals.
  - **Expected**: User sees warning with reason and can save anyway.

- [X] T008 [US2] Run duplicate detection before AI/receipt draft save.
  - **Why**: AI/receipt can produce duplicate drafts too.
  - **Benefit**: Same safety across all capture modes.
  - **Expected**: Warning appears before commit, not after save.

- [X] T009 [US1] Add merchant/tags display and filtering/search support in Expenses.
  - **Why**: Metadata is useful only if users can find it.
  - **Benefit**: Improves investigation and export workflows.
  - **Expected**: Search can match merchant and tags.

- [X] T010 [US1] Include merchant and tags in export outputs.
  - **Why**: Export should preserve useful metadata.
  - **Benefit**: Makes external review more complete.
  - **Expected**: CSV/Excel/PDF include metadata where appropriate.

## Phase 4: Attachments Decision

- [X] T011 Document attachment MVP policy before coding storage.
  - **Why**: Attachments affect storage, privacy, and rules.
  - **Benefit**: Avoids unsafe file persistence.
  - **Expected**: Decide between receipt linkage only, local references, or cloud storage follow-up plan.

- [ ] T012 If in scope, add `ExpenseAttachment` reference model without uploading files.
  - **Why**: A lightweight reference can support receipt history later.
  - **Benefit**: Keeps this plan bounded.
  - **Expected**: Model stores safe metadata only, or task is deferred explicitly.

## Phase 5: Localization And Verification

- [X] T013 Add ARB keys for merchant, tags, duplicate warning, duplicate reasons, and save anyway.
  - **Why**: New user-facing copy must be localized.
  - **Benefit**: Arabic users understand warnings.
  - **Expected**: Matching English/Arabic keys.

- [X] T014 Run `flutter gen-l10n`.
  - **Why**: ARB changes need generated getters.
  - **Benefit**: Catches localization errors.
  - **Expected**: Generation succeeds.

- [X] T015 Run `cd functions; npm run test:rules` if Firestore rules changed.
  - **Why**: Metadata persistence depends on rules accepting current schema.
  - **Benefit**: Catches permission regressions.
  - **Expected**: Rules tests pass or emulator blocker is recorded.

- [X] T016 Run targeted repository/add_expense/expenses/export tests and `flutter analyze --no-pub`.
  - **Why**: Model changes touch several flows.
  - **Benefit**: Confirms end-to-end safety.
  - **Expected**: Targeted tests and analyzer pass.
