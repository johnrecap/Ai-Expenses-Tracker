# Tasks: UI Design System Upgrade

**Input**: Design documents from `specs/090-ui-design-system-upgrade/`  
**Prerequisites**: `plan.md`, `spec.md`

## Phase 1: Reference Matrix And Design Audit

- [X] T001 Expand external UI reference matrix in `specs/090-ui-design-system-upgrade/research.md`. Why: user asked for GitHub/tools help, but unsafe adoption is risky. Expected: license, relevance, activity, compatibility, risk for each candidate. Risk: copying bad/stale code. Modification: include Flutter Templates, Expense Manager, Trackify, Finmori, gskinner Flutter Vignettes, save_points_showcaseview, liquid_glass_renderer/liquid_glass_kit, oc_liquid_glass.
- [X] T002 Audit current core UI screens in `lib/screens/home/`, `lib/screens/add_expense/`, `lib/screens/expenses/`, `lib/screens/reports/`, `lib/screens/settings/`, `lib/screens/ai_assistant/`. Why: design system must solve actual inconsistencies. Expected: list of spacing, typography, card, input, color, and RTL issues. Risk: redesign without diagnosis. Modification: capture screenshots if possible.
- [X] T003 Define finance UI principles in `specs/090-ui-design-system-upgrade/plan.md`. Why: prevent decorative but confusing UI. Expected: clarity, trust, speed, scanability, RTL-first, AI-as-assistant-not-obstacle. Risk: one-note flashy redesign. Modification: keep operational app constraints.

## Phase 2: Foundational Design System

- [X] T004 [P] Add design tokens in `lib/theme/`. Why: shared spacing/radius/typography/colors prevent screen drift. Expected: token file(s) with named values. Risk: hardcoded visual constants continue. Modification: no behavior changes.
- [X] T005 [P] Add reusable finance card/status/input components in `lib/widgets/`. Why: core screens need consistent building blocks. Expected: `FinanceCard`, `MoneyAmountText`, `TransactionRow`, `AppStatusBanner`, `AppTextField` or equivalent. Risk: every screen custom-builds UI. Modification: keep components small and composable.
- [X] T006 Add widget tests for base components in `test/widgets/`. Why: shared components become high-impact. Expected: render in Arabic/English, small width, high text scale. Risk: design system breaks many screens. Modification: include overflow checks where feasible.

## Phase 3: User Story 1 - Coherent Financial Design System (P1)

**Independent Test**: Core screens share visual language.

- [X] T007 Migrate Home cards and transaction rows in `lib/screens/home/`. Why: Home is first impression and trust anchor. Expected: consistent card spacing, clearer hierarchy, no nested card feel. Risk: existing finance behavior changes. Modification: keep `HomeSummaryCalculator` untouched.
- [X] T008 Migrate Expenses list rows/actions in `lib/screens/expenses/`. Why: transactions should look consistent across Home and list. Expected: same row component and edit/delete affordances. Risk: row overflow in Arabic. Modification: test Arabic long category names.
- [X] T009 Migrate Reports summary/chart cards in `lib/screens/reports/`. Why: reports must feel trustworthy and scannable. Expected: consistent headers, totals, caveats, chart containers. Risk: chart readability regression. Modification: keep `ReportCalculator` untouched.
- [X] T010 Migrate Settings/Profile cards in `lib/screens/settings/` and `lib/screens/account/`. Why: current profile/settings UI looks plain and trust-sensitive. Expected: cleaner sections, clear account identity, better hierarchy. Risk: settings scroll/empty-space regression. Modification: verify max scroll extent.

## Phase 4: User Story 2 - Faster Cleaner Add Expense (P1)

**Independent Test**: User can add a simple expense quickly on small screen.

- [X] T011 Redesign Add Expense top flow in `lib/screens/add_expense/views/add_expense.dart`. Why: user screenshot shows clutter and weak hierarchy. Expected: AI capture at top, amount/category/date visible, advanced fields collapsed. Risk: manual entry becomes slower. Modification: keep core fields accessible.
- [X] T012 Integrate shared AI copilot surface from Plan 085 when available. Why: `+` flow must match Home AI. Expected: one AI capture widget. Risk: duplicate AI design remains. Modification: use feature flag/adapter if Plan 085 not merged yet.
- [X] T013 Improve keyboard-open layout. Why: Add Expense is keyboard-heavy. Expected: Save action reachable, fields not hidden. Risk: user cannot save. Modification: use safe bottom padding/sticky action if needed.
- [X] T014 Add Add Expense UI tests in `test/add_expense/`. Why: core daily workflow. Expected: no overflow, important fields visible, manual save still works. Risk: pretty but unusable screen.

## Phase 5: User Story 3 - Safe UI Reference Adoption (P2)

**Independent Test**: Dependency/package not added until reviewed.

- [X] T015 Evaluate `liquid_glass_kit` and `oc_liquid_glass` in an isolated spike only if needed. Why: user asked for water/glass effect, but core UI performance matters. Expected: accept/reject decision with screenshots/perf notes. Risk: heavy shaders in list screens. Modification: do not add dependency to production path without approval.
- [X] T016 Evaluate Flutter Templates and Finmori component patterns for local adaptation. Why: they provide finance/forms/dashboard references. Expected: selected local patterns, not copied wholesale. Risk: inconsistent imported style. Modification: adapt into local tokens/components.
- [X] T017 Document selected references and rejected ones. Why: future agents need context. Expected: plan/research notes with URLs and reasons. Risk: repeated debate. Modification: include license and risk.

## Phase 6: RTL And Device QA

- [ ] T018 Run Arabic small-screen QA for migrated screens. Why: UI quality fails fast in RTL if not checked. Expected: no blocking overlap. Risk: English-only polish. Modification: capture screenshots.
- [ ] T019 Run English small-screen QA. Why: changes must improve both languages. Expected: clean layout and readable totals. Risk: Arabic fix breaks English.
- [ ] T020 Run analyzer and targeted widget tests. Why: UI refactors can break imports/layout. Expected: tests pass. Risk: release build failure.

Blocked note: T018-T019 require Android device screenshot QA. T020 analyzer ran with
only existing info-level lint notes, but Flutter test execution was blocked by
the local Codex approval/session failure and must be rerun after re-auth.

## Dependencies

- T001-T006 block broad screen migrations.
- T011 can start after T004-T006 but should align with Plan 085 for AI.
- T015-T017 are required before adding any new UI dependency.

## MVP Scope

Complete T001-T014 and T020 first: design system foundation, Home/Expenses/Reports/Settings consistency, and Add Expense cleanup. Visual-effect package adoption remains optional after evaluation.
