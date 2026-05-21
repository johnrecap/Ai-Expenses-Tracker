# Implementation Plan: AI-Assisted Add Expense Form

**Branch**: `059-ai-first-add-entrypoint` | **Date**: 2026-05-19 | **Spec**: `specs/059-ai-first-add-entrypoint/spec.md`

## Summary

Keep the Home central plus button wired to the existing Add Expense screen, but embed an AI form-fill widget at the top of that screen. The AI result should populate the existing manual form fields automatically, while the user still reviews and presses Save through the normal Add Expense path.

## Technical Context

**Language/Version**: Dart 3.x, Flutter  
**Primary Dependencies**: Flutter Bloc, existing AI parsing services/cubit, existing `AddExpense`, existing Home repository/provider wiring  
**Storage**: No schema change  
**Testing**: Home navigation widget tests, Add Expense widget tests, AI cubit/service tests, guided tour text tests if needed  
**Primary Files**:

- `lib/screens/home/views/home_screen.dart`
- `lib/ai/cubit/ai_assistant_cubit.dart`
- `lib/ai/models/ai_action_preview.dart`
- `lib/screens/ai_assistant/widgets/`
- `lib/screens/add_expense/views/add_expense.dart`
- `lib/guided_tour/`
- `lib/l10n/app_en.arb`
- `lib/l10n/app_ar.arb`
- `test/home/home_navigation_test.dart`
- `test/add_expense/`
- `test/ai/`
- `test/guided_tour/`

## Implementation Approach

1. Keep the floating plus button route as the existing `AddExpense` screen.
2. Extract a compact AI add widget that can parse text and emit an `AiActionPreview` or equivalent form-fill result without saving an expense.
3. Insert the AI widget above the manual amount field in `AddExpense`.
4. Map AI result fields into the existing form controllers and selected values.
5. Leave missing AI fields blank/defaulted and editable.
6. Preserve the existing Save button as the only Firestore commit path.
7. Update guided-tour copy/target descriptions so users understand the plus button now supports AI-assisted form fill.
8. Localize new UI copy.

## UX Rules

- The first visible control after the title should be the AI input/fill widget.
- The manual form must remain visible and usable underneath the AI widget.
- AI parse success should feel like "fill the form for me", not a separate confirmation flow.
- AI failure/quota/settings guard should not trap the user; the manual form remains available.
- AI must not auto-save the expense; Save remains the explicit commit.
- Top sparkle icon should be reviewed during implementation:
  - Preferred option: keep it for broader assistant commands if clearly distinct from quick add.
  - Alternative: route it to Add Expense if duplication confuses users during QA.

## Verification

```text
flutter test --no-pub test/home/home_navigation_test.dart test/ai test/add_expense --reporter=expanded --timeout=45s
flutter analyze --no-pub
```

Manual device check:

```text
Tap plus -> Add Expense opens -> AI widget visible above form -> manual fields usable.
AI parse -> fields fill automatically -> edit field -> Save -> Home refresh.
Exhaust/disable AI settings -> manual form remains usable.
```

## Deferred Items To Keep In Mind

Broader AI onboarding copy, funnel analytics, and experimentation around top sparkle behavior should wait until the embedded AI form-fill flow is stable.
