# Tasks: Real Device UI QA Hardening

**Input**: `specs/080-real-device-ui-qa-hardening/spec.md`, `plan.md`  
**Goal**: Prove and harden the UI issues that matter on small Android screens and keyboard-open flows.

## Phase 1: QA Fixtures And Baseline

- [X] T001 Create deterministic UI fixture data in `test/helpers/ui_fixture_data.dart`. **Why**: Layout bugs need repeatable long names, large amounts, Arabic text, and mixed currencies. **Fixes**: Manual-only reproduction. **Expected**: Tests can render realistic stress data. **Done**: Added `UiFixtureData` with long English/Arabic categories, mixed EGP/USD expenses, large amounts, settings, budget, and user.
- [X] T002 Add a manual QA checklist in `docs/qa/real-device-ui-hardening.md`. **Why**: Keyboard and safe-area behavior cannot be fully trusted from widget tests. **Fixes**: Untracked manual observations. **Expected**: Each scenario has steps, expected result, and pass/fail evidence slot. **Done**: Added checklist with Settings, Add Expense keyboard, language refresh, finance card fit, and parent verification slots.

## Phase 2: Settings Scroll

- [X] T003 [US1] Extend `test/settings/settings_screen_widget_test.dart` with English and Arabic bottom-scroll assertions on compact viewport. **Why**: User reported blank scroll area. **Fixes**: Regression coverage for Settings bottom spacing. **Expected**: Test fails if final content is far above viewport bottom or blank area dominates. **Done**: English assertion already existed; added Arabic support-section bottom assertion.
- [X] T004 [US1] Inspect and adjust `lib/screens/settings/views/settings_screen.dart` bottom padding/list sizing if T003 exposes a real issue. **Why**: Padding/safe-area mistakes can cause empty scrolling. **Fixes**: Large blank bottom region. **Expected**: Settings stops cleanly after final section. **Done**: Inspected existing ListView/SafeArea padding; no source change needed because current bottom padding is bounded to 16 + safe-area inset.
- [ ] T005 [US1] Add screenshot/manual note to `docs/qa/real-device-ui-hardening.md` after real-device check. **Why**: Confirms issue on the environment where it was reported. **Fixes**: Widget-only confidence gap. **Expected**: Settings scenario has recorded result. **Status**: Not run by this worker; checklist evidence slot added for parent real-device QA.

## Phase 3: Add Expense Keyboard And AI Input

- [X] T006 [US2] Add compact viewport widget tests for `lib/screens/add_expense/views/add_expense.dart` in `test/add_expense/add_expense_layout_test.dart`. **Why**: Add Expense is the most frequent flow. **Fixes**: Fields/buttons hidden or unreachable on small screens. **Expected**: Manual, AI, and receipt states render without overflow. **Done**: Added compact keyboard-inset and receipt-unavailable layout tests.
- [X] T007 [US2] Add tests for `AiExpenseFormFillCard` long Arabic input and loading/error messages in `test/add_expense/add_expense_ai_form_fill_test.dart`. **Why**: AI input is likely to be long and keyboard-driven. **Fixes**: AI card overflow. **Expected**: Long text and error states remain usable. **Done**: Added compact long-Arabic-input coverage and receipt/settings error-state coverage via `add_expense_layout_test.dart`.
- [X] T008 [US2] Adjust `lib/screens/add_expense/views/add_expense.dart` and `lib/screens/add_expense/widgets/ai_expense_form_fill_card.dart` for keyboard-safe scrolling and responsive controls. **Why**: Users need Save and required fields reachable. **Fixes**: Keyboard-open friction. **Expected**: User can complete add flow without closing keyboard unnecessarily. **Done**: Added keyboard-dismiss scrolling, bottom padding from `viewInsets`, compact mode-label truncation, and responsive AI helper/action layout.
- [ ] T009 [US2] Record manual keyboard-open QA in `docs/qa/real-device-ui-hardening.md`. **Why**: Android keyboard behavior is device-specific. **Fixes**: Missing real-device evidence. **Expected**: Arabic and English keyboard scenarios are documented. **Status**: Not run by this worker; checklist evidence slot added for parent real-device QA.

## Phase 4: Language Refresh

- [X] T010 [US3] Add language-switch tests covering Settings plus one secondary route in `test/settings/settings_screen_widget_test.dart` or a new `test/localization/language_refresh_test.dart`. **Why**: User previously saw text update only after restart. **Fixes**: Stale visible labels. **Expected**: Visible labels update immediately after language selection. **Done**: Existing Settings refresh test retained; added `test/localization/language_refresh_test.dart` for a newly opened Expenses route after language change.
- [X] T011 [US3] Fix any stale `const Text`, cached locale, or non-l10n labels found in touched routes. **Why**: Cached labels can survive locale changes. **Fixes**: Restart-required language updates. **Expected**: UI rebuilds with current locale. **Done**: Inspected touched routes; no stale locale cache fix was needed for this scope.

## Phase 5: Finance Card Fit

- [X] T012 [US4] Add compact viewport tests for Home finance cards in `test/home/home_layout_test.dart`. **Why**: Home is the main trust screen. **Fixes**: Amount/category/status overlap. **Expected**: Large amounts and mixed-currency statuses fit. **Done**: Added compact Home stress-data test.
- [X] T013 [US4] Add compact viewport tests for Reports cards in `test/reports/reports_layout_test.dart`. **Why**: Reports display totals, charts, and caveats together. **Fixes**: Chart/card text overlap. **Expected**: Report totals and caveats remain readable. **Done**: Added compact Reports mixed-currency stress-data test.
- [X] T014 [US4] Add compact viewport tests for Expenses transaction rows in `test/expenses/expenses_screen_test.dart`. **Why**: Long Arabic descriptions/category names can overlap dates/amounts. **Fixes**: Transaction row readability. **Expected**: Amounts remain visible and text truncates/wraps cleanly. **Done**: Added compact bilingual transaction-row stress test.
- [X] T015 [US4] Adjust layout constraints in `lib/screens/home/views/main_screen.dart`, `lib/screens/reports/views/reports_screen.dart`, and `lib/screens/expenses/views/expenses_screen.dart` as needed. **Why**: Stable dimensions prevent overlap across data sizes. **Fixes**: UI collision. **Expected**: Cards remain professional under stress data. **Done**: Added truncation/constraints for Home rows, Reports summary/caveats, Expenses rows, and Budget card metrics.

## Phase 6: Verification

- [X] T016 Run targeted layout/localization tests: `flutter test --no-pub test/settings test/add_expense test/home test/reports test/expenses --reporter expanded --concurrency=1 --timeout 45s`. **Why**: Confirms UI regressions are controlled. **Fixes**: Layout/localization breakage. **Expected**: Targeted tests pass.
- [X] T017 Run `flutter analyze --no-pub`. **Why**: Layout changes can create stale imports or const issues. **Fixes**: Static errors. **Expected**: Analyzer reports no issues.
- [ ] T018 If the user requests an installable artifact, build the requested non-debug package after tests pass. **Why**: User may need to test on device. **Fixes**: Avoids unnecessary build time before UI is verified. **Expected**: Build happens only on explicit request. **Status**: Not requested and explicitly out of scope for this worker.

## Worker 080 Completion Notes

- **Files changed**: `lib/screens/add_expense/views/add_expense.dart`, `lib/screens/add_expense/widgets/ai_expense_form_fill_card.dart`, `lib/screens/home/views/main_screen.dart`, `lib/screens/reports/views/reports_screen.dart`, `lib/screens/expenses/views/expenses_screen.dart`, `lib/screens/budget/widgets/budget_progress_card.dart`, `test/helpers/ui_fixture_data.dart`, `test/settings/settings_screen_widget_test.dart`, `test/add_expense/add_expense_layout_test.dart`, `test/add_expense/add_expense_ai_form_fill_test.dart`, `test/localization/language_refresh_test.dart`, `test/home/home_layout_test.dart`, `test/reports/reports_layout_test.dart`, `test/expenses/expenses_screen_test.dart`, `docs/qa/real-device-ui-hardening.md`.
- **Parent verification run**: `flutter gen-l10n`, `flutter analyze --no-pub`, and targeted Settings/Add Expense/Home/Reports/Expenses tests passed.
- **Remaining risks**: real Android keyboard/safe-area behavior still needs device QA; manual screenshot evidence slots remain open.

## Dependencies

T001-T002 before new tests. Settings, Add Expense, Language, and Finance card phases can run independently after fixtures exist. T016-T017 run after implementation.

## MVP Scope

MVP is Settings bottom scroll plus Add Expense keyboard-open hardening, because both came directly from user-observed UI friction.
