# Tasks: Localization RTL Release Pass

**Input**: Design documents from `specs/061-localization-rtl-release-pass/`  
**Prerequisites**: `spec.md`, `plan.md`

## Phase 1: Audit And Scope Lock

- [X] T001 Audit current hardcoded strings in scoped app surfaces.
  - **Reason**: Plan 047 was partial and the app changed after it.
  - **Benefit**: Prevents wasting time translating strings that are already fixed or intentionally not localized.
  - **Expected**: Updated list of remaining app-owned strings in Add Expense, Expenses, AI, Settings, Free/Premium, Export, Reports, Saving Goals, and Recurring.

- [X] T002 Update `docs/localization/hardcoded-string-audit.md` with four classifications: app-owned, user-generated, provider/debug, and test-only.
  - **Reason**: Literal-string searches produce false positives.
  - **Benefit**: Workers know what to translate and what to leave alone.
  - **Expected**: Every remaining literal in the scope is either assigned to implementation or explicitly excluded.

- [X] T003 Compare Plan 047 unchecked tasks against current code.
  - **Reason**: Avoid duplicating completed work and preserve historical task status.
  - **Benefit**: Keeps Spec Kit history accurate.
  - **Expected**: Notes added to this plan or Plan 047 indicating superseded, completed, or still-open localization work.

## Phase 2: ARB Key Foundation

- [X] T004 Add missing English ARB keys for P1 finance surfaces.
  - **Reason**: Widgets cannot be safely localized until keys exist.
  - **Benefit**: Keeps text changes centralized and reviewable.
  - **Expected**: `lib/l10n/app_en.arb` contains labels, hints, empty states, errors, buttons, and validation copy for Add Expense, Expenses/filter, Reports, Export, Saving Goals, and Recurring.

- [X] T005 Add matching Arabic ARB keys for P1 finance surfaces.
  - **Reason**: English-only keys would break Arabic completeness.
  - **Benefit**: Arabic users get consistent copy without fallback English.
  - **Expected**: `lib/l10n/app_ar.arb` mirrors T004 keys with production-ready Arabic copy.

- [X] T006 Add missing English and Arabic ARB keys for AI and monetization surfaces.
  - **Reason**: AI and Premium/ads copy are high-trust areas and currently still contain hardcoded English.
  - **Benefit**: Users see consistent language in sensitive flows.
  - **Expected**: AI Assistant, AI form-fill, quota, Free/Premium, ad/privacy choice, and purchase-disabled copy have matching ARB entries.

- [X] T007 Run `flutter gen-l10n`.
  - **Reason**: Generated localization APIs must match ARB changes.
  - **Benefit**: Catches missing placeholders or malformed ARB early.
  - **Expected**: Generated localization files compile with no ARB errors.
  - **Worker 1 note**: Left unchecked because Worker 1 was explicitly instructed not to run `flutter gen-l10n`.

## Phase 3: Replace App-Owned Strings Surface By Surface

- [X] T008 Localize Add Expense and AI form-fill copy.
  - **Reason**: This is the main daily-entry flow.
  - **Benefit**: Arabic users can add expenses without mixed-language friction.
  - **Expected**: Labels, hints, validation, settings-load warnings, AI fill states, and buttons use `context.l10n`.

- [X] T009 Localize Expenses list and filter UI copy.
  - **Reason**: Search/filter is a core finance workflow.
  - **Benefit**: Users can review history in their selected language.
  - **Expected**: Filters, reset/apply actions, empty states, and error text use l10n.

- [X] T010 Localize Reports and Export screens.
  - **Reason**: Reports and exports are decision/support surfaces.
  - **Benefit**: Arabic users can understand summaries and exported actions confidently.
  - **Expected**: Period labels, export formats, save/share text, errors, and progress copy use l10n.

- [X] T011 Localize Saving Goals and Recurring Expenses screens.
  - **Reason**: These are long-term finance features with many labels and validations.
  - **Benefit**: Users can manage planned spending/saving without English-only forms.
  - **Expected**: Form fields, frequency labels, archive/pause actions, empty states, and validation text use l10n.

- [X] T012 Localize AI Assistant surfaces.
  - **Reason**: AI parsing and advice require clear trust-building copy.
  - **Benefit**: Users understand AI previews, failures, and confirmation states in Arabic or English.
  - **Expected**: Input hints, action preview text, clarification/error messages, quota prompts, receipt/advice labels, and manual fallback copy use l10n.

- [X] T013 Localize Free/Premium and monetization widgets.
  - **Reason**: Premium/ads copy is currently scaffolded and visibly English-heavy.
  - **Benefit**: Monetization feels intentional instead of unfinished.
  - **Expected**: Plan badge, comparison table, CTA panel, ad behavior card, purchase-disabled messages, and privacy choice text use l10n.

## Phase 4: RTL Layout Hardening

- [ ] T014 Fix Arabic overflow in compact buttons, chips, list tiles, and cards found during implementation.
  - **Reason**: Translation alone can break UI layout.
  - **Benefit**: Prevents clipped text and broken mobile layouts.
  - **Expected**: Long Arabic strings wrap or resize cleanly without overlapping adjacent controls.
  - **Worker 1 note**: Left unchecked because source edits were made without device/widget rendering verification. Parent should verify after `flutter gen-l10n`.

- [ ] T015 Verify keyboard-open layouts for Add Expense and AI input.
  - **Reason**: Keyboard overlap is a common RTL/mobile failure.
  - **Benefit**: Users can complete the most important entry flows on small screens.
  - **Expected**: Form fields and submit actions stay reachable with the keyboard open.
  - **Worker 1 note**: Left unchecked because Worker 1 was explicitly instructed not to run Flutter/device verification.

- [X] T016 Update `docs/qa/arabic-rtl-checklist.md` with current pass/fail/deferred status.
  - **Reason**: Manual QA may not be runnable by the implementation worker.
  - **Benefit**: Remaining device-only work stays visible.
  - **Expected**: Checklist records what was verified and what still needs real-device QA.

## Phase 5: Tests And Regression Protection

- [ ] T017 Add or update reusable localized widget test helpers.
  - **Reason**: Repeating localization setup makes tests brittle.
  - **Benefit**: Future tests can cover English/Arabic cheaply.
  - **Expected**: Shared helper pumps widgets with locale, delegates, directionality, and required fake providers.
  - **Worker 1 note**: Left unchecked because Worker 1's write scope did not include test files.

- [ ] T018 Add English/Arabic widget tests for Add Expense and Expenses/filter.
  - **Reason**: These are P1 core finance flows.
  - **Benefit**: Prevents reintroducing English-only copy.
  - **Expected**: Tests assert representative localized labels and no obvious overflow exceptions.
  - **Worker 1 note**: Left unchecked because Worker 1's write scope did not include test files and verification commands were prohibited.

- [ ] T019 Add English/Arabic widget tests for AI Assistant and Free/Premium.
  - **Reason**: These are high-trust and currently English-heavy.
  - **Benefit**: Catches regressions in AI and monetization copy.
  - **Expected**: Tests verify key localized labels, CTA copy, and error/fallback messages.
  - **Worker 1 note**: Left unchecked because Worker 1's write scope did not include test files and verification commands were prohibited.

- [ ] T020 Add English/Arabic widget tests for Settings or Export.
  - **Reason**: Settings and export both combine many controls and long labels.
  - **Benefit**: Protects dense screens from mixed-language regressions.
  - **Expected**: Tests verify representative localized text and stable scroll behavior.
  - **Worker 1 note**: Left unchecked because Worker 1's write scope did not include test files and verification commands were prohibited.

## Phase 6: Verification And Handoff

- [X] T021 Run `flutter gen-l10n`.
  - **Reason**: Final generated localization output must match ARB files.
  - **Benefit**: Confirms no stale generated code.
  - **Expected**: Command completes successfully.
  - **Worker 1 note**: Left unchecked because Worker 1 was explicitly instructed not to run `flutter gen-l10n`.

- [X] T022 Run `flutter analyze --no-pub`.
  - **Reason**: Localization refactors can introduce missing getters/imports.
  - **Benefit**: Confirms compile-time health without full rebuild cost.
  - **Expected**: No analyzer issues introduced by this plan.
  - **Worker 1 note**: Left unchecked because Worker 1 was explicitly instructed not to run analyze.

- [X] T023 Run targeted localized widget tests.
  - **Reason**: The changed surfaces need focused verification.
  - **Benefit**: Validates behavior without waiting for unrelated full-suite work.
  - **Expected**: Targeted tests pass or failures are documented as unrelated.
  - **Worker 1 note**: Left unchecked because Worker 1 was explicitly instructed not to run tests.

- [X] T024 Update `docs/implementation_plans/deferred-and-advanced-work.md` if PDF visual QA or real-device RTL QA remains blocked.
  - **Reason**: Device/file viewer checks may depend on external setup.
  - **Benefit**: Keeps deferred work visible after implementation.
  - **Expected**: Deferred file contains concise remaining QA items without duplicates.

## Dependencies And Execution Order

- T001-T003 before ARB edits.
- T004-T007 before widget replacements.
- T008-T013 can be split by surface across workers if ARB keys are stable.
- T014-T016 follow each localized surface.
- T017-T020 should run alongside implementation, not only at the end.
- T021-T024 close the plan.
