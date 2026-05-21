# Tasks: Daily Exchange Rate Cache

**Input**: Design documents from `specs/060-daily-exchange-rate-cache/`  
**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `quickstart.md`

## Phase 1: Setup

**Purpose**: Align Spec Kit context and baseline files before implementation.

- [x] T001 Update current Spec Kit pointers in `AGENTS.md` and `.specify/feature.json` to `specs/060-daily-exchange-rate-cache`.

---

## Phase 2: Foundational

**Purpose**: Add persisted refresh metadata and repository support required by all stories.

- [x] T002 [P] Extend `packages/expense_repository/lib/src/models/user_settings.dart` with nullable `exchangeRatesUpdatedAt` normalization, copy, entity mapping, and equality-safe behavior.
- [x] T003 [P] Extend `packages/expense_repository/lib/src/entities/user_settings_entity.dart` to serialize/deserialize `exchangeRatesUpdatedAt` while preserving existing users without the field.
- [x] T004 Update `packages/expense_repository/lib/src/settings_repo.dart` and `packages/expense_repository/lib/src/firebase_settings_repo.dart` with a focused method for saving refreshed exchange rates and timestamp.
- [x] T005 Update `firestore.rules` and `functions/test/firestoreRules.rules.ts` so `exchangeRatesUpdatedAt` and conversion rates remain valid under deployed rules.
- [x] T006 [P] Add repository/entity tests in `test/repository/user_settings_entity_test.dart` for timestamp round-trip and missing-field compatibility.

**Checkpoint**: Settings can persist daily refresh metadata without breaking old documents.

---

## Phase 3: User Story 1 - Daily Cached Rates (Priority: P1)

**Goal**: Refresh supported non-base rates once per local day and use saved rates for Home calculations.

**Independent Test**: Home loads with stale settings and a fake provider; rates are saved once and converted totals use the saved rate.

- [x] T007 [US1] Refactor `lib/services/exchange_rates/exchange_rate_service.dart` so provider fetch remains a source-only service and no hardcoded fallback rates exist.
- [x] T008 [US1] Add a daily refresh coordinator in `lib/services/exchange_rates/exchange_rate_refresh_service.dart` that checks freshness, fetches supported non-base rates, validates positive rates, saves successful results, and returns effective settings.
- [x] T009 [US1] Update `lib/screens/home/views/main_screen.dart` to consume already-effective settings and remove per-build live-rate fetching.
- [x] T010 [US1] Update `lib/screens/home/views/home_screen.dart` to run daily refresh around `watchSettings()` results and pass effective settings into `MainScreen`.
- [x] T011 [US1] Add targeted tests in `test/services/exchange_rate_refresh_service_test.dart` and `test/home/home_navigation_test.dart` for once-per-day refresh and converted Home totals.

**Checkpoint**: Home uses saved daily rates and avoids repeated same-day provider calls.

---

## Phase 4: User Story 2 - Offline Continuity (Priority: P2)

**Goal**: Preserve and use last saved rates when refresh fails.

**Independent Test**: Refresh provider throws; saved rates remain and Home still calculates converted totals.

- [x] T012 [US2] Ensure `ExchangeRateRefreshService` catches provider failures and returns unchanged settings without clearing `conversionRates`.
- [x] T013 [US2] Add tests in `test/services/exchange_rate_refresh_service_test.dart` proving stale saved rates survive provider failures and missing rates remain missing when no cache exists.

**Checkpoint**: Offline or provider failure does not break existing converted totals.

---

## Phase 5: User Story 3 - Supported Currency Scope (Priority: P3)

**Goal**: Refresh only enabled non-base currencies.

**Independent Test**: Supported currencies EGP/USD/EUR request USD and EUR only; base currency is never requested or saved.

- [x] T014 [US3] Add refresh target selection coverage in `test/services/exchange_rate_refresh_service_test.dart` for supported-currency filtering and base-currency exclusion.
- [x] T015 [US3] Confirm existing settings filtering keeps removed currency rates out when supported currencies change.

---

## Final Phase: Verification and Documentation

- [x] T016 Run `dart format` on changed Dart files.
- [x] T017 Run `flutter analyze --no-pub`.
- [x] T018 Run targeted Flutter tests from `quickstart.md`.
- [x] T019 Build Android release APK with `flutter build apk --release`.
- [x] T020 Update `.specify/memory/constitution.md` to document daily cached exchange-rate behavior.
- [x] T021 Fix Frankfurter pair direction so cached rates store source currency to base currency values, e.g. USD to EGP for EGP base.
- [x] T022 Add regression coverage proving USD expenses convert to EGP by multiplication with the USD-to-EGP rate.

## Dependencies & Execution Order

- Phase 1 must complete first.
- Phase 2 blocks all user stories.
- US1 is MVP and must complete before US2/US3 verification because it provides the refresh coordinator.
- US2 and US3 can be implemented after US1 in either order.
- Verification runs last.

## Parallel Opportunities

- T002, T003, and T006 touch different files and can be parallelized after T001.
- T011, T013, and T014 can expand the same test file but should be coordinated if done by separate workers.

## Implementation Strategy

1. Complete settings schema and rules support.
2. Implement daily refresh service.
3. Wire Home to refresh settings once per day.
4. Prove offline fallback and supported-currency filtering with tests.
5. Run targeted verification and release build.
