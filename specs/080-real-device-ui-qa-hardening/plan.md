# Implementation Plan: Real Device UI QA Hardening

**Branch**: `080-real-device-ui-qa-hardening` | **Date**: 2026-05-20 | **Spec**: `specs/080-real-device-ui-qa-hardening/spec.md`  
**Input**: UI/UX risks from latest review and previous user screenshots.

## Summary

Create a focused UI hardening pass for real mobile behavior that automated unit tests cannot fully prove: Settings bottom scroll, Add Expense with keyboard, immediate language switching, and text fitting in finance cards.

## Technical Context

**Language/Version**: Dart 3.x, Flutter  
**Primary Dependencies**: Existing widget tests, Flutter layout system, generated l10n  
**Storage**: None  
**Testing**: Widget tests plus manual Android QA checklist; build only if requested  
**Target Platform**: Android small viewport first  
**Project Type**: Mobile app  
**Performance Goals**: No added layout jank; no expensive rebuild loops during language/settings changes  
**Constraints**: Do not alter finance calculations; do not require production Firebase setup; avoid release build unless explicitly requested  
**Scale/Scope**: Settings, Add Expense, Home, Reports, Budget, Transactions

## Constitution Check

- Spec Kit artifacts live under `specs/080-real-device-ui-qa-hardening/`: PASS.
- UI changes must preserve existing behavior and data boundaries: PASS.
- Localization/RTL changes must use generated l10n: PASS.
- Verification must separate automated tests from manual device QA: PASS.
- Release/device blockers remain tracked in deferred backlog: PASS.

## Project Structure

```text
lib/screens/settings/views/settings_screen.dart
lib/screens/add_expense/views/add_expense.dart
lib/screens/add_expense/widgets/ai_expense_form_fill_card.dart
lib/screens/home/views/main_screen.dart
lib/screens/reports/views/reports_screen.dart
lib/screens/budget/widgets/budget_progress_card.dart
lib/screens/expenses/views/expenses_screen.dart
test/settings/settings_screen_widget_test.dart
test/add_expense/
test/home/
test/reports/
docs/qa/
```

## Design Decisions

### Decision 1: Reproduce with deterministic fixtures first

Use widget tests and seeded fake data to reproduce layout risk before manual device verification.

### Decision 2: Prefer responsive constraints over cosmetic fixes

Fix overflow with stable layout constraints, wrapping, max lines, and scroll behavior rather than one-off padding.

### Decision 3: Manual QA is required for keyboard and OS-specific behavior

Keyboard layout, device safe areas, and Arabic input methods need a real-device checklist even if widget tests pass.

## Implementation Strategy

1. Strengthen widget tests for Settings bottom scroll, Add Expense keyboard-like constraints, and language switching.
2. Fix layout issues found by tests.
3. Add a manual QA checklist with exact data and pass/fail evidence.
4. Run targeted widget tests and analyzer.
5. Build only when the user explicitly asks for a testable artifact.

## Risks

- Widget tests cannot perfectly emulate Android keyboard behavior.
- Large finance numbers and Arabic text can create different issues across fonts/devices.
- Over-constraining text can hide important financial details, so truncation must be used carefully.

## Deferred Items Considered

The persistent backlog still includes production-device QA, Arabic PDF visual inspection, and release artifact inspection. This plan prepares and executes focused UI QA, but Play Store/release readiness remains separate.

