# Implementation Plan: Localization And RTL Completion

**Branch**: `047-localization-rtl-completion` | **Date**: 2026-05-18 | **Spec**: `specs/047-localization-rtl-completion/spec.md`  
**Input**: Remaining hardcoded English strings and incomplete Arabic RTL coverage.

## Summary

Complete a broad but controlled localization pass for core finance, AI, monetization, and settings surfaces; regenerate l10n files; add representative localized widget tests; and document manual RTL QA.

## Technical Context

**Language/Version**: Dart 3.x, Flutter generated localization  
**Primary Dependencies**: `flutter_localizations`, `intl`, ARB files, existing widget tests  
**Storage**: ARB files and generated Dart localization files  
**Testing**: `flutter gen-l10n`, `flutter analyze --no-pub`, targeted localized widget tests  
**Target Platform**: Android priority with Flutter multi-platform support  
**Project Type**: Flutter mobile app  
**Performance Goals**: No runtime slowdown beyond existing generated localization lookup  
**Constraints**: Do not translate user-generated content; avoid broad UI refactors while replacing strings  
**Scale/Scope**: Add Expense, Expenses, Categories, Recurring, Reports, Export, Settings, AI, monetization, Saving Goals

## Constitution Check

- Static user-facing strings in localized surfaces must use ARB.
- User-generated content must not be translated.
- Preserve Bloc/Cubit and repository patterns.
- Run `flutter gen-l10n` after ARB edits.

**Gate Status**: PASS.

## Project Structure

```text
lib/l10n/app_en.arb
lib/l10n/app_ar.arb
lib/l10n/app_localizations*.dart
lib/screens/add_expense/
lib/screens/expenses/
lib/screens/categories/
lib/screens/recurring_expenses/
lib/screens/reports/
lib/screens/export/
lib/screens/settings/
lib/screens/ai_assistant/
lib/monetization/
test/localization/
docs/localization/
docs/qa/
```

**Structure Decision**: Keep all app-owned copy in existing ARB files. Add focused widget tests under existing test folders or `test/localization/` when reusable wrappers are needed.

## Implementation Notes

- Start with an audit command and classify strings as app-owned, user-generated, provider/debug, or test-only.
- Replace strings feature-by-feature to keep diffs reviewable.
- Prefer existing l10n naming style; group related keys with stable names.
- Use tests with localized wrappers instead of asserting raw English where possible.
- For RTL checklist, include keyboard-open Add Expense/AI input, filter sheets, export options, settings groups, plan cards, and PDF samples.

## Verification

```text
flutter gen-l10n
flutter analyze --no-pub
flutter test --no-pub test/localization --reporter expanded --concurrency=1 --timeout 45s
flutter test --no-pub test/settings test/ai --reporter expanded --concurrency=1 --timeout 45s
```

## Deferred Items To Keep In Mind

Manual Arabic RTL QA on a small Android viewport and Arabic PDF visual inspection remain deferred if no device or visual inspection path is available during local implementation.

## Complexity Tracking

No constitution violations.
