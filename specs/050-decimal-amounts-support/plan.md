# Implementation Plan: Decimal Amounts Support

**Branch**: `050-decimal-amounts-support` | **Date**: 2026-05-18 | **Spec**: `specs/050-decimal-amounts-support/spec.md`  
**Input**: Integer-only amount parsing and models block decimal expense values.

## Summary

Upgrade expense amount handling from integer-only to decimal-safe numeric values while preserving existing Firestore documents, display formatting, filters, reports, exports, AI previews, and recurring expense flows.

## Technical Context

**Language/Version**: Dart 3.x, Flutter  
**Primary Dependencies**: Existing repository package, `intl`, Firestore rules numeric helpers  
**Storage**: Existing Firestore `amount` numeric field remains backward-compatible  
**Testing**: Repository entity tests, widget tests, calculator/filter/export tests, rules tests  
**Target Platform**: Flutter app with Firestore backend  
**Project Type**: Finance data model and UI polish  
**Performance Goals**: No material impact on report/filter calculation speed  
**Constraints**: Preserve old integer documents; do not introduce currency conversion; avoid noisy floating display  
**Scale/Scope**: Expense model/entity, add/edit/AI/recurring input, filters, reports, export, tests

## Constitution Check

- Firestore serialization remains in entity/model mapping.
- Validation happens before parsing and saving.
- Existing user-owned data remains backward-compatible.
- UI strings use l10n.
- Rules tests cover backend acceptance.

**Gate Status**: PASS.

## Project Structure

```text
packages/expense_repository/lib/src/models/expense.dart
packages/expense_repository/lib/src/entities/expense_entity.dart
packages/expense_repository/lib/src/models/recurring_expense.dart
packages/expense_repository/lib/src/entities/recurring_expense_entity.dart
lib/screens/add_expense/
lib/screens/expenses/widgets/expense_filter_sheet.dart
lib/screens/ai_assistant/widgets/ai_action_preview_card.dart
lib/ai/models/ai_action_preview.dart
lib/screens/recurring_expenses/
lib/screens/settings/utils/currency_formatter.dart
lib/services/export/
firestore.rules
functions/test/firestoreRules.rules.ts
test/
```

**Structure Decision**: Keep the Firestore field name `amount` and make app parsing/display decimal-safe. Do not introduce a second `amountMinor` field in this pass because it would require a larger migration and currency-specific precision rules.

## Implementation Notes

- Prefer `double` for current app model compatibility, with formatting that rounds for display.
- Centralize amount parsing/formatting helpers where possible to avoid repeated `double.tryParse`.
- Update `Expense.amount` and `ExpenseEntity.amount` types before UI call sites.
- Replace `_intFromValue` with numeric parsing that accepts int, float, num, and numeric strings.
- Audit `int.tryParse` amount usage in add expense, AI preview, recurring forms, and filters.
- Add tests for integer backward compatibility and decimal preservation.

## Verification

```text
flutter analyze --no-pub
flutter test --no-pub test/repository test/services test/expenses test/ai --reporter expanded --concurrency=1 --timeout 45s
cd functions
npm run test:rules
```

## Deferred Items To Keep In Mind

Exact minor-unit money storage, currency-specific decimal precision, and currency conversion are future advanced work and should not be mixed into this compatibility pass.

## Complexity Tracking

No constitution violations.
