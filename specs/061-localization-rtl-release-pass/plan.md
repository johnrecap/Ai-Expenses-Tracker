# Implementation Plan: Localization RTL Release Pass

**Branch**: `061-localization-rtl-release-pass` | **Date**: 2026-05-19 | **Spec**: `specs/061-localization-rtl-release-pass/spec.md`  
**Input**: Feature specification from `specs/061-localization-rtl-release-pass/spec.md`

## Summary

Complete the remaining app-owned English-to-Arabic localization work and RTL release readiness for high-use app surfaces. This follows up on the partially complete `specs/047-localization-rtl-completion` plan by auditing current strings, adding missing ARB keys, replacing hardcoded app-owned copy, strengthening localized widget tests, and updating manual RTL QA status.

## Technical Context

**Language/Version**: Dart 3.x, Flutter  
**Primary Dependencies**: `flutter_localizations`, `intl`, generated `AppLocalizations`, Flutter widget tests  
**Storage**: No new storage. Existing user-generated content remains unchanged.  
**Testing**: `flutter gen-l10n`, `flutter analyze --no-pub`, targeted localized widget tests  
**Target Platform**: Flutter mobile app, primarily Android with Arabic RTL support  
**Project Type**: Mobile app  
**Performance Goals**: Localization lookups must not add network calls or expensive runtime work.  
**Constraints**: Do not translate user-generated content or provider/debug identifiers; do not change finance/AI/ads behavior.  
**Scale/Scope**: Add Expense, Expenses/filter, AI Assistant, Settings, Free/Premium, Export, Reports, Saving Goals, Recurring, and shared monetization/AI widgets.

## Constitution Check

- Spec Kit artifacts live under `specs/061-localization-rtl-release-pass/`: PASS.
- Static app-owned strings introduced or touched by this plan use ARB l10n: PASS.
- User-generated content must not be translated: PASS.
- Existing Bloc/repository architecture remains unchanged: PASS.
- Verification includes `flutter gen-l10n`, analyze, and targeted tests: PASS.

## Project Structure

### Documentation

```text
specs/061-localization-rtl-release-pass/
|-- spec.md
|-- plan.md
`-- tasks.md

docs/localization/hardcoded-string-audit.md
docs/qa/arabic-rtl-checklist.md
docs/implementation_plans/deferred-and-advanced-work.md
```

### Source Code

```text
lib/l10n/app_en.arb
lib/l10n/app_ar.arb
lib/l10n/app_localizations*.dart

lib/screens/add_expense/
lib/screens/expenses/
lib/screens/ai_assistant/
lib/screens/settings/
lib/screens/monetization/
lib/screens/export/
lib/screens/reports/
lib/screens/saving_goals/
lib/screens/recurring_expenses/
lib/monetization/
```

### Tests

```text
test/helpers/
test/add_expense/
test/expenses/
test/settings/
test/monetization/
test/ai_assistant/
test/export/
```

## Complexity Tracking

No constitution violations. This is broad but bounded UI text work; execute surface-by-surface to keep reviews and regressions manageable.

