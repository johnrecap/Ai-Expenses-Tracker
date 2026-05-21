# Tasks: Localization RTL Final Pass

**Input**: `specs/066-localization-rtl-final-pass/spec.md`, `plan.md`

## Phase 1: Audit

- [X] T001 Re-run hardcoded string searches for `lib/screens`, `lib/ai`, `lib/monetization`, and `lib/services/export`.
  - **Why**: Existing audit may be stale after recent plans.
  - **Benefit**: Finds remaining English literals before manual QA.
  - **Expected**: Updated list of app-owned, provider, debug, and user-generated strings.

- [X] T002 Update `docs/localization/hardcoded-string-audit.md`.
  - **Why**: The audit is the source of truth for localization follow-up.
  - **Benefit**: Prevents translating data/provider strings incorrectly.
  - **Expected**: Each finding is classified with target file and action.

## Phase 2: ARB And Source Fixes

- [X] T003 Add missing English keys to `lib/l10n/app_en.arb`.
  - **Why**: Source widgets need generated getters.
  - **Benefit**: Keeps English and Arabic surfaces aligned.
  - **Expected**: Keys follow existing lowerCamelCase naming.

- [X] T004 Add matching Arabic keys to `lib/l10n/app_ar.arb`.
  - **Why**: Arabic users must get complete app-owned copy.
  - **Benefit**: Reduces mixed-language UI.
  - **Expected**: Arabic copy is production-ready and not machine-literal where user trust matters.

- [X] T005 Replace remaining app-owned literals in primary screens with `context.l10n`.
  - **Why**: Hardcoded strings do not update on language switch.
  - **Benefit**: Live language change becomes reliable.
  - **Expected**: Add Expense, Settings, Account, AI, Export, Reports, Budget, Categories, and Monetization surfaces use l10n.

- [X] T006 Run `flutter gen-l10n`.
  - **Why**: ARB changes require generated localization code.
  - **Benefit**: Catches malformed ARB early.
  - **Expected**: Generated files update without errors.

## Phase 3: RTL And Keyboard Layout

- [ ] T007 [US1] Fix Arabic overflow in buttons, chips, cards, list rows, and settings sections.
  - **Why**: Overflow makes the app feel unprofessional.
  - **Benefit**: Arabic UI becomes visually trustworthy.
  - **Expected**: No P1 visible overflow on the chosen small viewport.

- [ ] T008 [US2] Verify and fix keyboard-open Add Expense and AI input layouts.
  - **Why**: These are daily-use input flows.
  - **Benefit**: Users can add expenses quickly in Arabic.
  - **Expected**: Primary action remains reachable with keyboard open.

- [ ] T009 [US2] Verify and fix keyboard-open account/settings/search/export forms.
  - **Why**: Secondary forms still need safe input behavior.
  - **Benefit**: Prevents blocked edits and hidden save buttons.
  - **Expected**: Each form can complete its main action.

## Phase 4: PDF QA

- [X] T010 [US3] Create or document an Arabic mixed-language export fixture.
  - **Why**: PDF QA needs repeatable data.
  - **Benefit**: Makes visual inspection reproducible.
  - **Expected**: Fixture includes Arabic descriptions, English merchant-like text, dates, and mixed currencies.

- [ ] T011 [US3] Generate and visually inspect Arabic PDF output.
  - **Why**: Automated tests cannot fully prove Arabic PDF readability.
  - **Benefit**: Confirms professional export output.
  - **Expected**: Result recorded in `docs/qa/arabic-rtl-checklist.md` or a linked QA note.

## Phase 5: Tests And Verification

- [ ] T012 Add localized widget tests for Add Expense and AI Assistant.
  - **Why**: These are frequent Arabic input paths.
  - **Benefit**: Catches regressions after copy/layout changes.
  - **Expected**: English and Arabic tests cover representative states.

- [ ] T013 Add localized widget tests for Settings/Account and Export.
  - **Why**: These contain many labels and action rows.
  - **Benefit**: Reduces stale-string risk.
  - **Expected**: Language switch and core labels are asserted.

- [X] T014 Run `flutter analyze --no-pub`.
  - **Why**: L10n changes can leave missing getters or stale imports.
  - **Benefit**: Static validation before manual QA.
  - **Expected**: No analyzer issues.

- [X] T015 Run targeted localization/widget tests.
  - **Why**: The changed surfaces need focused verification.
  - **Benefit**: Confirms both locales render.
  - **Expected**: Targeted tests pass.
