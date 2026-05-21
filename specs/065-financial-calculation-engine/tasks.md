# Tasks: Financial Calculation Engine

**Input**: `specs/065-financial-calculation-engine/spec.md`, `plan.md`

## Phase 1: Audit And Regression Fixtures

- [X] T001 Create a shared mixed-currency fixture in `test/fixtures/finance_fixtures.dart`.
  - **Why**: Every surface must be tested against the same data.
  - **Benefit**: Prevents Home and Reports passing with different assumptions.
  - **Expected**: Fixture includes base EGP, USD/EUR/SAR expenses, valid rates, missing rates, old dates, and category spread.

- [X] T002 Add audit tests for Home, Reports, Monthly Budget, Category Budgets, Subscriptions, Export, AI summaries, and weekly digest.
  - **Why**: Current risk is inconsistent totals across surfaces.
  - **Benefit**: Reveals exactly where finance math diverges.
  - **Expected**: Each surface is classified as conversion-aware, same-currency-only, or broken.

## Phase 2: Shared Calculation Contract

- [X] T003 Add `MoneyBreakdown` and `ConvertedMoneyRow` models under `lib/services/finance/`.
  - **Why**: UI needs metadata, not just a number.
  - **Benefit**: Every surface can explain converted and missing currencies.
  - **Expected**: Models expose total, base currency, source rows, converted currencies, unconverted currencies, and rate timestamp.

- [X] T004 Add `FinancialCalculationService` under `lib/services/finance/`.
  - **Why**: Conversion rules must live in one place.
  - **Benefit**: Reduces duplicate logic and future currency bugs.
  - **Expected**: Service wraps `MoneyConversionService` and returns `MoneyBreakdown`.

- [X] T005 Add unit tests for invalid rates, base currency changes, missing rates, and offline stale-rate behavior.
  - **Why**: Rate edge cases are common and dangerous.
  - **Benefit**: Keeps calculations financially conservative.
  - **Expected**: Invalid rates are excluded and surfaced as missing/unconverted.

## Phase 3: Surface Migration

- [X] T006 [US1] Migrate Home totals in `lib/screens/home/services/home_summary_calculator.dart`.
  - **Why**: Home is the first trust surface.
  - **Benefit**: Keeps dashboard math aligned with the new contract.
  - **Expected**: Existing Home tests pass with shared breakdown metadata.

- [X] T007 [US1] Migrate Reports in `lib/services/report_calculator.dart`.
  - **Why**: Reports must agree with Home.
  - **Benefit**: Prevents regression of Plan 063.
  - **Expected**: Converted/unconverted metadata comes from shared service.

- [X] T008 [US1] Migrate AI summary/advice and weekly digest call sites.
  - **Why**: AI and digest must not tell a different financial story.
  - **Benefit**: User gets consistent answers in all places.
  - **Expected**: AI/digest tests use the same fixture totals.

- [ ] T009 [US1] Audit and update Category Budgets and Subscription Center.
  - **Why**: These are known secondary mixed-currency risks.
  - **Benefit**: Removes hidden inconsistencies or labels them honestly.
  - **Expected**: Each surface either converts through the service or shows same-currency-only copy.

- [ ] T010 [US1] Update Export totals and metadata.
  - **Why**: Exported reports must match what users saw in the app.
  - **Benefit**: Prevents support disputes about exported numbers.
  - **Expected**: Export includes base total and missing-rate notes when applicable.

## Phase 4: Historical Rate Policy

- [X] T011 [US3] Document latest-rate behavior in `docs/finance/currency-policy.md`.
  - **Why**: Historical reports currently use latest saved rates.
  - **Benefit**: Makes current behavior honest before adding storage changes.
  - **Expected**: Policy explains rate refresh, offline stale rates, and historical report implications.

- [X] T012 [US3] Add a follow-up decision task for transaction-date rate snapshots if immutable historical reports are required.
  - **Why**: Snapshot storage affects data model and rules.
  - **Benefit**: Avoids sneaking a migration into this broad audit.
  - **Expected**: Deferred backlog has a concise historical-rate snapshot item if not implemented here.

## Phase 5: Verification

- [X] T013 Run targeted finance tests for home, reports, budget, category budgets, subscriptions, export, AI, and engagement.
  - **Why**: The change touches multiple trust surfaces.
  - **Benefit**: Confirms the shared fixture behaves consistently.
  - **Expected**: All targeted tests pass.

- [X] T014 Run `flutter analyze --no-pub`.
  - **Why**: Shared model/signature changes can leave stale call sites.
  - **Benefit**: Static safety before manual QA.
  - **Expected**: No analyzer issues.
