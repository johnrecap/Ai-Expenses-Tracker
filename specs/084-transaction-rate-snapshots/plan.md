# Implementation Plan: Transaction Rate Snapshots

**Branch**: `084-transaction-rate-snapshots` | **Date**: 2026-05-27 | **Spec**: `specs/084-transaction-rate-snapshots/spec.md`  
**Input**: Feature specification from `specs/084-transaction-rate-snapshots/spec.md`

## Summary

Persist conversion evidence on each expense so historical base-currency totals do not change when the daily exchange-rate cache refreshes. The implementation will add snapshot fields to the expense domain, serialization layers, local/VPS sync schema, and finance calculators. Aggregation surfaces will use the snapshot first and show clear localized fallback status for legacy or missing-rate expenses.

## Technical Context

**Language/Version**: Dart 3.12 / Flutter 3.44; TypeScript/Fastify for VPS sync schema where needed  
**Primary Dependencies**: `expense_repository`, existing `MoneyConversionService`, `ExchangeRateRefreshService`, `HomeSummaryCalculator`, `ReportCalculator`, export and AI summary services  
**Storage**: Firestore legacy expense documents, local migration store/Drift boundary, PostgreSQL `sync_changes` payloads  
**Testing**: Flutter unit/widget tests, repository serialization tests, server migration/sync tests if schema contracts change  
**Target Platform**: Android-first Flutter app with Firebase legacy and VPS pilot modes  
**Project Type**: Mobile finance app with repository package and VPS sync backend  
**Performance Goals**: No network calls during rendering; O(n) aggregation over loaded expenses  
**Constraints**: No hardcoded exchange rates; no silent mixed-currency summing; no provider secrets in Flutter; local-first writes must survive offline mode  
**Scale/Scope**: One user's loaded/date-scoped expense history, including legacy records

## Constitution Check

- Spec Kit artifacts live under `specs/084-transaction-rate-snapshots/`: PASS.
- Money conversion remains behind shared service/calculation boundaries: PASS.
- Widgets must not perform conversion directly: PASS.
- User settings remain accessed through `SettingsRepository`: PASS.
- No provider keys or hardcoded rates in Flutter: PASS.
- Firebase/VPS sync must preserve user-owned data fields: PASS.
- Localization is required for new user-facing finance status copy: PASS.

## Project Structure

```text
specs/084-transaction-rate-snapshots/
|-- spec.md
|-- plan.md
`-- tasks.md

packages/expense_repository/lib/src/models/expense.dart
packages/expense_repository/lib/src/entities/expense_entity.dart
packages/expense_repository/lib/src/local/
packages/expense_repository/lib/src/sync/

lib/screens/home/services/
lib/services/report_calculator.dart
lib/services/export/
lib/ai/
lib/engagement/
lib/l10n/

server/src/db/schema/
server/src/sync/
test/
server/tests/
```

**Structure Decision**: Add the snapshot to the shared expense model/entity first, then migrate calculation services and sync payloads. UI surfaces consume prepared breakdowns and do not own conversion rules.

## Implementation Strategy

1. Define a `MoneySnapshot` value object and add optional snapshot fields to expenses.
2. Update entity serialization for Firestore, local store, backup/export, and sync payloads.
3. Add a snapshot factory that uses current settings rates at save/edit time and returns explicit missing-rate failures.
4. Update manual, AI, receipt, recurring, and edit save paths to create or preserve snapshots.
5. Update finance calculators to prefer snapshots and return metadata for legacy/missing/incompatible cases.
6. Add migration/backfill handling for legacy expenses without snapshots.
7. Add localized status copy and focused tests for old-rate/new-rate scenarios.

## Risks

- Broad model change can break serialization. Mitigation: add backward-compatible parsing and tests before UI changes.
- Existing expenses lack snapshots. Mitigation: use conservative fallback and explicit migration task.
- Base-currency changes are tricky. Mitigation: never mutate old snapshots; mark incompatible snapshot targets rather than guessing.
- VPS pilot sync can drop unknown payload fields if not audited. Mitigation: sync schema tests.

## Verification

```text
flutter gen-l10n
flutter test --no-pub test/repository test/home test/reports test/export test/ai --reporter=expanded --timeout=45s
flutter analyze --no-pub
cd server && npm run typecheck && npm test
```

## Deferred Items Considered

Existing deferred items already mention exact minor-unit money storage, historical exchange-rate provider selection, transaction-date rates, offline freshness indicators, and secondary finance surface conversion. This plan fixes immutable saved conversions first; provider-grade historical rate lookup remains later unless explicitly pulled in.
