# Tasks: Transaction Rate Snapshots

**Input**: Design documents from `specs/084-transaction-rate-snapshots/`  
**Prerequisites**: `plan.md`, `spec.md`

## Phase 1: Setup And Audit

- [X] T001 Audit current expense conversion usage in `lib/screens/home/services/`, `lib/services/report_calculator.dart`, `lib/services/export/`, `lib/ai/`, and `lib/engagement/`. Why: identify every place that might currently use today's rates. Expected: list of affected surfaces. Risk: missing one screen keeps the trust bug alive. Modification: document each surface in this tasks file before implementation.
- [X] T002 Audit expense serialization paths in `packages/expense_repository/lib/src/models/expense.dart`, `packages/expense_repository/lib/src/entities/expense_entity.dart`, `packages/expense_repository/lib/src/local/`, and `server/src/sync/`. Why: snapshots must survive every storage mode. Expected: known field map for Firestore/local/VPS. Risk: data loss during sync or rollback. Modification: note required field additions.

Audit notes:
- Conversion surfaces: Home and Reports already flow through `FinancialCalculationService`; export summaries use the same service but per-row conversion columns were using current settings directly; AI summaries/advice/history use `ReportCalculator`/settings-backed finance services; budget progress uses `BudgetCalculator` with `FinancialCalculationService` when the budget currency matches the base currency; weekly digest/engagement surfaces rely on existing report/finance calculators where mixed-currency totals are exposed.
- Serialization/storage paths: Firestore writes use `Expense.toEntity().toDocument()` through `FirebaseExpenseRepo`; local-first sync queues use the same document map in `LocalExpenseRepository`; VPS durable sync stores generic JSON payloads in `sync_changes`; the Drift boundary and PostgreSQL finance schema had legacy conversion-rate columns and now need a complete snapshot JSON column to avoid losing rate evidence.

## Phase 2: Foundational Snapshot Model

- [X] T003 [P] Add a `MoneySnapshot` model in `packages/expense_repository/lib/src/models/`. Why: a typed value object prevents ad hoc conversion fields. Expected: source amount/currency, target currency, rate, converted amount, capturedAt, rateDate/source fields. Risk: weak model lets UI invent conversion semantics. Modification: include validation helpers and equality.
- [X] T004 [P] Add `MoneySnapshotEntity` serialization in `packages/expense_repository/lib/src/entities/`. Why: Firestore and sync need stable document mapping. Expected: backward-compatible `fromDocument` with nullable snapshot. Risk: old expense docs fail to parse. Modification: ignore malformed snapshot and surface missing metadata.
- [X] T005 Update `Expense` in `packages/expense_repository/lib/src/models/expense.dart`. Why: all repository boundaries must carry snapshot data. Expected: optional snapshot field plus copy/equality support. Risk: old constructors/tests break. Modification: keep default null for legacy data.
- [X] T006 Update Firestore rules in `firestore.rules` and rule tests in `functions/test/firestoreRules.rules.ts`. Why: deployed rules must accept new snapshot fields. Expected: valid snapshot writes pass, invalid type/rate writes fail. Risk: production save failures. Modification: add strict but backward-compatible validation.

## Phase 3: User Story 1 - Saved Expenses Keep Original Converted Value (P1)

**Independent Test**: Save USD at 50, change saved rate to 51, verify old contribution remains 500 EGP.

- [ ] T007 [P] Add repository/model tests in `test/repository/expense_money_snapshot_test.dart`. Why: serialization is the first failure point. Expected: old and new documents parse. Risk: snapshots disappear across reads. Modification: include malformed and missing snapshot cases.
- [ ] T008 [P] Add conversion fixture tests in `test/home/home_summary_calculator_snapshot_test.dart`. Why: Home exposed the user-visible bug. Expected: old totals do not move after rate refresh. Risk: fixing storage but not display. Modification: test converted/unconverted metadata.
- [X] T009 Implement snapshot creation helper in `lib/services/finance/` or existing money service boundary. Why: save paths need one rule. Expected: returns snapshot or explicit missing-rate result. Risk: manual/AI paths diverge. Modification: no network calls; use settings rates only.
- [X] T010 Wire manual Add Expense save path in `lib/screens/add_expense/views/add_expense.dart`. Why: manual saves are core path. Expected: non-base expense stores snapshot before repository create. Risk: stale fallback silently saved. Modification: block or ask for explicit rate if missing.
- [X] T011 Wire AI Assistant Home save path in `lib/screens/ai_assistant/` and relevant cubits. Why: AI-created expenses must not bypass snapshot logic. Expected: same snapshot as manual save. Risk: AI expenses remain mutable with rate changes. Modification: reuse T009 helper.
- [X] T012 Wire receipt and recurring expense creation paths in `lib/screens/add_expense/`, `lib/ai/`, and recurring services. Why: every expense source must obey accounting rules. Expected: recurring and receipt expenses have snapshots where applicable. Risk: inconsistent totals by source. Modification: add source-specific tests.

## Phase 4: User Story 2 - Editing Recomputes Only When Money Inputs Change (P1)

**Independent Test**: Edit description only and verify snapshot unchanged; edit amount and verify snapshot recomputed.

- [ ] T013 [P] Add edit snapshot tests in `test/expenses/expense_edit_sheet_snapshot_test.dart`. Why: edit behavior is easy to regress. Expected: non-money edit preserves snapshot; money edit recomputes. Risk: user changes notes and totals change. Modification: cover amount, currency, date, payment, tags, merchant.
- [X] T014 Update expense edit flow in `lib/screens/expenses/widgets/expense_edit_sheet.dart`. Why: current edit must preserve or refresh snapshot intentionally. Expected: snapshot policy is applied before update. Risk: overwriting existing snapshot with null. Modification: pass previous expense into snapshot decision.
- [X] T015 Update repository update paths in `packages/expense_repository`. Why: update payload must persist new snapshot fields. Expected: Firestore/local/VPS update writes carry snapshot. Risk: edit works in UI but not after reload. Modification: add update serialization coverage.

## Phase 5: User Story 3 - All Financial Surfaces Agree (P2)

**Independent Test**: One fixture produces matching totals across Home, Reports, budget, export, AI summary, and weekly digest.

- [X] T016 [P] Update `MoneyConversionService`/financial calculation boundary to prefer expense snapshots. Why: one shared rule prevents screen drift. Expected: current-rate fallback only for explicit legacy policy. Risk: each screen reimplements logic. Modification: expose included/excluded metadata.
- [X] T017 Update `HomeSummaryCalculator` in `lib/screens/home/services/`. Why: Home is the most visible total. Expected: snapshot totals and clear status. Risk: old bug remains on first screen. Modification: no UI-side rate math.
- [X] T018 Update `ReportCalculator` in `lib/services/report_calculator.dart`. Why: reports must match Home. Expected: weekly/monthly totals use snapshots. Risk: screenshots show conflicting numbers. Modification: update breakdown metadata.
- [ ] T019 Update budget/category-budget/subscription/export/AI/digest consumers where audited in T001. Why: secondary surfaces cannot contradict primary totals. Expected: same fixture answer or explicit "not converted" caveat. Risk: user distrust moves to another screen. Modification: migrate one service at a time.
- [ ] T020 Add localized copy in `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb`. Why: missing-rate/snapshot status is user-facing financial explanation. Expected: Arabic/English messages are clear and short. Risk: hardcoded or confusing finance copy. Modification: run `flutter gen-l10n`.

## Phase 6: VPS/Local Sync And Migration

- [X] T021 Update local store/Drift boundary under `packages/expense_repository/lib/src/local/`. Why: offline-first mode must persist snapshots. Expected: local writes survive restart. Risk: pending sync loses money evidence. Modification: add local repository tests.
- [X] T022 Update VPS sync payload/schema in `server/src/db/schema/` and `server/src/sync/`. Why: pilot backend must not strip snapshot fields. Expected: push/pull preserves snapshots. Risk: local correct value changes after sync. Modification: add server sync fixture tests.
- [ ] T023 Add legacy backfill strategy for old expenses. Why: existing users have no snapshot. Expected: conservative fallback or explicit migration command. Risk: silently changing old history. Modification: document migration limitations in quickstart or tasks notes.

## Phase 7: Verification And Documentation

- [X] T024 Run `flutter gen-l10n`. Why: ARB changes must generate code. Expected: generated localization updates. Risk: build uses stale messages. Modification: commit generated files if changed.
- [ ] T025 Run targeted Flutter tests for repository, Home, reports, expenses, export, and AI. Why: this is a finance correctness change. Expected: snapshot fixtures pass. Risk: hidden regression in totals. Modification: fix before build.
- [X] T026 Run `flutter analyze --no-pub` and backend tests if sync changed. Why: schema/model changes span app and server. Expected: no analyzer/backend failures. Risk: broken pilot build. Modification: record results in plan/tasks.

Verification notes:
- Parent ran `flutter gen-l10n` successfully after worker changes.
- Parent ran `flutter analyze --no-pub`; it completed with no errors or
  warnings, but exits non-zero because Flutter 3.44 reports 62
  `prefer_initializing_formals` info lints across existing constructors.
- Parent ran server typecheck, sync migration/conflict tests, Functions tests,
  and Firestore rules tests successfully.
- Targeted Flutter tests were attempted but the local Flutter/Git toolchain hung
  and left `git.exe` processes; do not treat T025 as complete until the
  toolchain issue is repaired or tests run cleanly.

## Dependencies

- T003-T006 block all save/display work.
- T009 blocks T010-T012 and T014.
- T016 blocks T017-T019.
- T021-T022 should start after the final model shape is stable.

## MVP Scope

Complete T001-T018 and T020 first. That fixes the user's core complaint for Home and Reports before secondary surfaces and VPS migration hardening.
