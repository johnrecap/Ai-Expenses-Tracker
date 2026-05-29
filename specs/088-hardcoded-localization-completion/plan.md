# Implementation Plan: Hardcoded Localization Completion

**Branch**: `088-hardcoded-localization-completion` | **Date**: 2026-05-27 | **Spec**: `specs/088-hardcoded-localization-completion/spec.md`  
**Input**: Feature specification from `specs/088-hardcoded-localization-completion/spec.md`

## Summary

Perform a full hardcoded-string sweep for user-visible app-owned copy and ensure language changes refresh visible text. The plan prioritizes trust-critical surfaces: finance totals, Add Expense, AI, sync, Settings/Profile, auth, errors/toasts, reports, export, monetization, and account deletion.

## Technical Context

**Language/Version**: Dart 3.12 / Flutter 3.44  
**Primary Dependencies**: `flutter_localizations`, generated `AppLocalizations`, ARB files under `lib/l10n`  
**Storage**: Existing `UserSettings.languagePreference`  
**Testing**: `flutter gen-l10n`, widget tests for language switching and RTL, analyzer  
**Target Platform**: Android-first Flutter app, Arabic/English  
**Project Type**: Mobile app  
**Performance Goals**: No meaningful runtime overhead beyond localization lookup  
**Constraints**: Do not translate user data; do not alter finance calculations; avoid layout overlap  
**Scale/Scope**: User-visible Flutter source under `lib/`

## Constitution Check

- User-facing strings must use ARB/localization: PASS.
- User-generated content must not be translated: PASS.
- Currency must not be inferred from language: PASS.
- Localization-only work must not alter finance/auth/storage behavior: PASS.

## Project Structure

```text
lib/l10n/app_en.arb
lib/l10n/app_ar.arb
lib/l10n/app_localizations*.dart
lib/screens/
lib/widgets/
lib/ai/
lib/services/
test/localization/
test/widgets/
```

**Structure Decision**: Add missing keys to ARB and replace hardcoded strings in place. Add helper functions only where service-generated copy cannot access `BuildContext`.

## Implementation Strategy

1. Run a source scan for hardcoded `Text`, `SnackBar`, `AlertDialog`, button labels, and service-generated messages.
2. Classify findings as user-facing, user-generated, debug-only, or external/provider text.
3. Add ARB keys with short Arabic/English copy.
4. Replace core user-facing hardcodes with `context.l10n`.
5. Add language-switch tests for the worst offenders.
6. Add RTL small-screen QA checklist and fix blocking overlaps.

## Risks

- Over-localizing user data such as category names. Mitigation: classify before replacing.
- Service-level copy may need new localized result types. Mitigation: prefer structured codes mapped in UI.
- Large generated diffs. Mitigation: group ARB changes and run `flutter gen-l10n` once per implementation pass.

## Verification

```text
flutter gen-l10n
flutter test --no-pub test/localization test/widgets --reporter=expanded --timeout=45s
flutter analyze --no-pub
```

Manual QA:

```text
Small Android viewport, Arabic, keyboard open: Home, Add Expense, Expenses, Reports, Settings, AI.
```

## Deferred Items Considered

Deferred PDF visual inspection, Play Store screenshots, and full device QA remain release follow-ups. This plan focuses on app UI and critical copy.
