# Tasks: Wallets Accounts And Transfers

**Input**: `specs/075-wallets-transfers/spec.md`, `plan.md`

## Phase 1: Domain Policy

- [X] T001 Write wallet balance and transfer policy in `specs/075-wallets-transfers/research.md`.
  - **Why**: Balance math can become complex quickly.
  - **Benefit**: Prevents accidental accounting promises.
  - **Expected**: Policy covers opening balances, transfers, fees, archived wallets, and multi-currency behavior.

- [X] T002 Decide Firestore structure for `users/{userId}/wallets` and `users/{userId}/transfers`.
  - **Why**: New domain data needs rules and repository boundaries.
  - **Benefit**: Keeps user ownership enforceable.
  - **Expected**: Document IDs, required fields, and indexes are listed.

## Phase 2: Models And Repositories

- [X] T003 Add `WalletAccount` and `Transfer` models/entities in `packages/expense_repository`.
  - **Why**: Data must be shared between app and repository layer.
  - **Benefit**: Typed persistence and tests.
  - **Expected**: Models include userId, ids, dates, archive state, and currency fields.

- [X] T004 Add wallet and transfer repository interfaces/Firestore implementations.
  - **Why**: Widgets must not access Firestore directly.
  - **Benefit**: Preserves project architecture.
  - **Expected**: CRUD/archive methods exist behind interfaces.

- [X] T005 Update `firestore.rules` and rules tests.
  - **Why**: New collections must be validated.
  - **Benefit**: Prevents unsafe data writes.
  - **Expected**: Valid writes pass and invalid user/currency/id writes fail.

## Phase 3: UI Flows

- [ ] T006 [US1] Add Wallets screen under `lib/screens/wallets/`.
  - **Why**: Users need to manage wallets.
  - **Benefit**: Enables account-level tracking.
  - **Expected**: Create/edit/archive wallet flows work.

- [ ] T007 [US1] Add optional wallet selector to Add/Edit Expense.
  - **Why**: Expenses need wallet association.
  - **Benefit**: Supports wallet filtering without forcing migration.
  - **Expected**: Existing expenses without wallet still work.

- [ ] T008 [US2] Add Transfer form.
  - **Why**: Transfers are separate from expenses.
  - **Benefit**: Prevents users from recording transfers as spending.
  - **Expected**: User can create transfer with source/destination/date/amount.

## Phase 4: Filters And Reports

- [ ] T009 [US1] Add wallet filter to Expenses.
  - **Why**: Wallet metadata needs to be searchable.
  - **Benefit**: Users can inspect account-specific spending.
  - **Expected**: Wallet filter composes with existing filters.

- [ ] T010 [US2] Ensure Reports exclude transfers from expense totals.
  - **Why**: Transfers are not spending.
  - **Benefit**: Protects financial accuracy.
  - **Expected**: Report fixtures prove transfer exclusion.

## Phase 5: Localization And Verification

- [X] T011 Add ARB keys for wallets, transfers, opening balance, archive, source, destination, and fees.
  - **Why**: New UI copy must be localized.
  - **Benefit**: Arabic/English consistency.
  - **Expected**: Matching keys exist.

- [X] T012 Run `flutter gen-l10n`.
  - **Why**: New keys require generated getters.
  - **Benefit**: Catches ARB errors.
  - **Expected**: Generation succeeds.

- [ ] T013 Run targeted wallet/repository/report tests and `flutter analyze --no-pub`.
  - **Why**: Domain expansion affects storage and reports.
  - **Benefit**: Confirms correctness.
  - **Expected**: Targeted tests and analyzer pass.
