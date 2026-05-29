# Implementation Plan: Expense Editing And Adjustments

**Branch**: `087-expense-editing-adjustments` | **Date**: 2026-05-27 | **Spec**: `specs/087-expense-editing-adjustments/spec.md`  
**Input**: Feature specification from `specs/087-expense-editing-adjustments/spec.md`

## Summary

Make expense editing a first-class, discoverable flow from Home and Expenses. The edit form will cover all expense fields and support quick amount adjustments. Updates will use existing repository/sync boundaries and integrate with transaction-rate snapshots so corrected values update all financial surfaces safely.

## Technical Context

**Language/Version**: Dart 3.12 / Flutter 3.44  
**Primary Dependencies**: Existing Expense model/repository, Expenses screen edit sheet, Home transaction list, Bloc flows, snapshot service from Plan 084  
**Storage**: Firestore legacy, local store/VPS sync queue, PostgreSQL sync payloads  
**Testing**: Widget tests for Home/Expenses edit entry points, repository update tests, calculator tests  
**Target Platform**: Android-first Flutter app  
**Project Type**: Mobile finance app  
**Performance Goals**: Edit sheet opens immediately from loaded expense data; no network call required before form display  
**Constraints**: No direct Firestore/HTTP writes in widgets; no invalid negative/zero amounts; AI/manual expenses share edit flow  
**Scale/Scope**: User's loaded expenses and current categories/settings

## Constitution Check

- Expense writes go through repository/Bloc boundaries: PASS.
- Money conversion uses shared snapshot/calculation service: PASS.
- Category UI uses existing category rendering/selection patterns: PASS.
- User-facing strings must be localized: PASS.
- VPS sync changes go through sync coordinator/queue: PASS.

## Project Structure

```text
lib/screens/home/
lib/screens/expenses/
lib/screens/expenses/widgets/expense_edit_sheet.dart
lib/screens/add_expense/
lib/services/finance/
lib/l10n/
packages/expense_repository/lib/src/
test/home/
test/expenses/
test/repository/
```

**Structure Decision**: Reuse and harden the existing expense edit sheet rather than building a second edit UI. Add Home entry point and optional quick amount adjustment on top of the same update service.

## Implementation Strategy

1. Audit current edit/delete implementation and identify missing entry points/fields.
2. Introduce an edit draft/update service if needed to avoid widget-owned business logic.
3. Add Home transaction row actions for edit.
4. Ensure all fields are editable and validated.
5. Add quick amount adjustment affordance.
6. Integrate snapshot recomputation/preservation.
7. Add tests for manual, AI, pending, and converted expenses.

## Risks

- Editing pending sync records can conflict with queued create. Mitigation: merge pending update or block with clear message until create syncs.
- Field-rich edit form can become visually heavy. Mitigation: keep primary fields visible and advanced fields collapsible.
- Snapshot dependency with Plan 084. Mitigation: implement base edit now and wire snapshot once Plan 084 lands.

## Verification

```text
flutter gen-l10n
flutter test --no-pub test/expenses test/home test/repository --reporter=expanded --timeout=45s
flutter analyze --no-pub
```

## Deferred Items Considered

Expense list scaling remains deferred in Plan 051. This plan works on loaded expenses and does not add global full-history search.
