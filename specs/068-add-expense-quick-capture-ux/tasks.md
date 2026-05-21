# Tasks: Add Expense Quick Capture UX

**Input**: `specs/068-add-expense-quick-capture-ux/spec.md`, `plan.md`

## Phase 1: Current Flow Audit

- [X] T001 Inspect `lib/screens/add_expense/views/add_expense.dart` and current AI form-fill wiring.
  - **Why**: The existing form already has AI integration.
  - **Benefit**: Avoids rebuilding working logic.
  - **Expected**: Current draft, defaults, validation, and save flow are mapped.

- [ ] T002 Add widget tests that describe current simple manual add and AI fill behavior.
  - **Why**: UX refactor needs regression protection.
  - **Benefit**: Confirms manual save is not broken.
  - **Expected**: Baseline tests fail/pass according to current behavior and guide changes.

## Phase 2: Draft And Mode Model

- [X] T003 Add or refine `ExpenseDraft` and `CaptureMode` models in the Add Expense feature.
  - **Why**: Three capture paths need one editable state.
  - **Benefit**: Prevents AI/receipt/manual fields drifting.
  - **Expected**: Draft stores amount, category, date, currency, payment method, description, source, and missing fields.

- [X] T004 Centralize draft fill logic for manual, AI text, and receipt results.
  - **Why**: Duplicate fill paths cause inconsistent validation.
  - **Benefit**: Every input method produces the same editable form state.
  - **Expected**: AI and receipt never bypass the normal save path.

## Phase 3: Quick Manual Entry

- [X] T005 [US1] Add a quick manual mode UI to `add_expense.dart`.
  - **Why**: Daily users need the fastest possible path.
  - **Benefit**: Reduces friction for simple expenses.
  - **Expected**: Amount/category/default fields are immediately reachable.

- [X] T006 [US1] Preserve full manual form access for advanced fields.
  - **Why**: Quick mode must not remove necessary detail.
  - **Benefit**: Supports both fast and detailed users.
  - **Expected**: User can expand or edit description/date/payment/currency.

## Phase 4: AI And Receipt Drafts

- [X] T007 [US2] Add natural-language mode that fills the shared draft.
  - **Why**: AI should be first-class but controlled.
  - **Benefit**: User gets speed without surprise saves.
  - **Expected**: Known fields fill; missing fields remain editable.

- [X] T008 [US3] Add receipt mode entry point that fills the shared draft.
  - **Why**: Receipt capture should be clear and separate.
  - **Benefit**: Reduces clutter in the main form.
  - **Expected**: Receipt success creates an editable draft; failure keeps manual form usable.

- [X] T009 [US2] Handle AI quota/provider/settings failures with non-blocking messages.
  - **Why**: AI can be unavailable.
  - **Benefit**: Manual tracking remains reliable.
  - **Expected**: User can still save manually after failure.

## Phase 5: Localization, Layout, Verification

- [X] T010 Add ARB keys for capture mode labels, draft status, missing fields, and receipt errors.
  - **Why**: New UI copy must be localized.
  - **Benefit**: Arabic/English consistency.
  - **Expected**: `app_en.arb` and `app_ar.arb` contain matching keys.

- [X] T011 Run `flutter gen-l10n`.
  - **Why**: New keys require generated getters.
  - **Benefit**: Catches ARB errors.
  - **Expected**: Generation succeeds.

- [ ] T012 Add Add Expense widget tests for quick manual, AI draft, receipt failure, and settings-load failure.
  - **Why**: These are the main risk paths.
  - **Benefit**: Prevents regression in daily flow.
  - **Expected**: Tests prove no automatic AI save occurs.

- [ ] T013 Manually verify small-screen keyboard-open Add Expense.
  - **Why**: This flow is highly layout-sensitive.
  - **Benefit**: Ensures primary save remains reachable.
  - **Expected**: QA note with pass/fail and screenshot if possible.

- [X] T014 Run `flutter analyze --no-pub`.
  - **Why**: Refactor touches widgets/models/cubits.
  - **Benefit**: Static safety.
  - **Expected**: No analyzer issues.
