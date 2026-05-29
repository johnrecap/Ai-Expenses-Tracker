# Tasks: Hardcoded Localization Completion

**Input**: Design documents from `specs/088-hardcoded-localization-completion/`  
**Prerequisites**: `plan.md`, `spec.md`

## Phase 1: Audit

- [x] T001 Run hardcoded string scan across `lib/`. Why: identify all remaining user-facing static copy. Expected: findings grouped by screen/service. Risk: hidden English remains. Modification: use `rg` patterns for `Text(`, `SnackBar`, `AlertDialog`, button labels, and thrown/displayed messages.
- [x] T002 Classify findings. Why: not every string should be localized. Expected: user-facing, user-generated, debug/test, provider/error-code groups. Risk: translating category names/descriptions. Modification: add classification notes to tasks. Completed note: preserved user-generated category names, provider/debug text, and structured service values that are already mapped at UI boundaries.
- [x] T003 Prioritize critical surfaces. Why: finance/AI/sync errors matter most. Expected: P1 list for Add Expense, Home, AI, Sync, Settings/Profile, Auth, Reports, Expenses. Risk: spending time on low-impact debug text first. Modification: mark lower priority as later pass. Completed note: focused this pass on Auth, Budget, Home/Engagement prompts, App Lock messages, and rewarded AI credit copy.

## Phase 2: Foundational Localization Keys

- [x] T004 [P] Add missing English keys to `lib/l10n/app_en.arb`. Why: generated localization needs source copy. Expected: clear concise strings. Risk: inconsistent terminology. Modification: reuse existing terms for expense, sync, AI, rate, category.
- [x] T005 [P] Add matching Arabic keys to `lib/l10n/app_ar.arb`. Why: Arabic users are primary target. Expected: natural Arabic, not literal awkward translations. Risk: overflow and bad UX. Modification: keep mobile copy short.
- [x] T006 Run `flutter gen-l10n`. Why: ARB keys must generate strongly typed accessors. Expected: generated files updated. Risk: compile failures from missing placeholders. Modification: fix ARB metadata.

## Phase 3: User Story 1 - All Static Text Follows Selected Language (P1)

**Independent Test**: Switch language and visible static text updates.

- [x] T007 Replace hardcoded Add Expense strings in `lib/screens/add_expense/`. Why: user screenshot shows this flow in Arabic with mixed issues. Expected: labels/errors/status localized. Risk: first transaction flow feels unfinished. Modification: preserve user-entered content.
- [x] T008 Replace hardcoded Home/transaction strings in `lib/screens/home/`. Why: Home is the first trust surface. Expected: banners, card text, row actions localized. Risk: mixed Arabic/English on first screen. Modification: update tests.
- [x] T009 Replace hardcoded Auth/Profile/Settings strings in `lib/screens/auth/`, `lib/screens/account/`, and `lib/screens/settings/`. Why: account trust depends on readable copy. Expected: login/reset/profile/delete/settings copy localized. Risk: auth errors remain English. Modification: mapped Auth visible copy and preserved backend/Auth failure messages for provider-specific accuracy.
- [x] T010 Add language switch widget test in `test/localization/language_switch_test.dart`. Why: user reported some text changes only after restart. Expected: selected language rebuild updates visible text. Risk: settings save works but UI stays stale. Modification: updated existing localization route-refresh coverage in `test/localization/language_refresh_test.dart` to assert generated English/Arabic copy without mojibake literals.

## Phase 4: User Story 2 - AI, Sync, Finance, And Errors Localized (P1)

**Independent Test**: Trigger critical messages in both languages.

- [x] T011 Replace AI assistant/draft/quota/error copy in `lib/ai/` and `lib/screens/ai_assistant/`. Why: AI value is lost if errors are unclear. Expected: Arabic/English copy for draft, missing fields, provider errors. Risk: hardcoded AI English. Modification: use structured error mapping.
- [x] T012 Replace sync pending/failed/synced copy in `lib/widgets/sync_status_banner.dart` and transaction rows. Why: pending state caused user concern. Expected: reason-specific localized copy. Risk: vague "Pending" remains. Modification: align with Plan 086.
- [x] T013 Replace finance caveat copy in Home/Reports/Budget/Export services. Why: missing-rate and conversion text affect trust. Expected: localized converted/unconverted/stale-rate messages. Risk: users misunderstand totals. Modification: no calculation changes.
- [x] T014 Replace validation/toast/dialog copy in common widgets. Why: errors must be actionable. Expected: localized SnackBars/Dialogs. Risk: mixed language in failure states. Modification: localized App Lock, rewarded AI credit, Auth validation, and Budget validation/failure surfaces.

## Phase 5: User Story 3 - RTL Layout Holds With Long Text (P2)

**Independent Test**: Arabic small-screen core screens have no blocking overlap.

- [x] T015 Add small-screen RTL widget tests for Add Expense and Home. Why: screenshots show cramped Arabic UI. Expected: critical controls findable and no obvious overflow exceptions. Risk: translation fits desktop only. Modification: added constrained Arabic RTL coverage for Add Expense keyboard-open controls and Home cards/transactions.
- [x] T016 Fix button/card text wrapping in core screens. Why: Arabic labels are longer. Expected: no clipped buttons or overlapping copy. Risk: layout looks unprofessional. Modification: reduced Home compact horizontal padding, tightened Home card/icon spacing, constrained transaction row actions, and compacted prompt/budget action buttons.
- [x] T017 Add manual QA checklist notes in `specs/088-hardcoded-localization-completion/tasks.md`. Why: some visual issues require device inspection. Expected: exact device scenarios listed. Risk: "passed tests" but bad phone UX. Modification: include keyboard-open cases.

## Phase 6: Verification

- [x] T018 Run hardcoded scan again. Why: prove cleanup. Expected: no high-priority user-facing hardcodes. Risk: missed strings. Modification: documented accepted false positives: user-entered values, category names, provider messages, and raw service strings that are localized before display.
- [x] T019 Run localization/widget tests. Why: generated strings must work in UI. Expected: language switch and critical copy tests pass. Risk: broken ARB placeholders.
- [x] T020 Run `flutter analyze --no-pub`. Why: replacements can break imports/types. Expected: analyzer clean. Risk: build failure. Completed note: no errors or warnings; analyzer still exits non-zero because of 62 pre-existing `prefer_initializing_formals` infos.

## Manual QA Notes

- Arabic small Android device: open Login, Register, Home, Budget, Add Expense, AI Assistant, App Lock, and Settings; switch language without app restart and confirm visible static copy follows the selected language.
- Arabic keyboard-open pass: Add Expense AI form fill, manual Add Expense, Login, Register, and Budget amount fields must keep primary action buttons reachable.
- Mixed content pass: Arabic UI with English category names, merchant names, and provider/Auth failure text should preserve user/provider text instead of translating it.

## Dependencies

- T004-T006 block string replacements.
- T015-T017 should follow major copy replacement because text length affects layout.

## MVP Scope

Complete T001-T014 and T018-T020 first. RTL layout polish can continue as the second increment if no blocking overlap appears.
