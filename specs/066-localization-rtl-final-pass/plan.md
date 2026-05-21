# Implementation Plan: Localization RTL Final Pass

**Branch**: `066-localization-rtl-final-pass` | **Date**: 2026-05-20 | **Spec**: `specs/066-localization-rtl-final-pass/spec.md`

## Summary

Finish localization trust by auditing all app-owned strings, fixing Arabic RTL layout issues, testing keyboard-open forms, and visually inspecting Arabic PDF export. This plan closes the remaining localization risks from Plans 047 and 061.

## Technical Context

**Language/Version**: Dart 3.x, Flutter  
**Primary Dependencies**: `flutter_localizations`, ARB files, generated l10n, PDF exporter  
**Storage**: No new storage  
**Testing**: `flutter gen-l10n`, `flutter analyze --no-pub`, localized widget tests, manual Android/PDF QA  
**Target Platform**: Android small viewport first  
**Project Type**: Mobile app localization/UX pass  
**Performance Goals**: No layout jank or blocked actions in keyboard-open flows  
**Constraints**: User-generated/provider text must not be translated as app-owned copy  
**Scale/Scope**: Core screens plus export PDF

## Constitution Check

- ARB for app-owned strings: PASS.
- User-generated content not translated: PASS.
- Manual RTL/PDF QA acknowledged: PASS.
- No unrelated feature work: PASS.

## Project Structure

```text
lib/l10n/app_en.arb
lib/l10n/app_ar.arb
lib/screens/
lib/ai/
lib/monetization/
lib/services/export/pdf_exporter.dart
docs/localization/hardcoded-string-audit.md
docs/qa/arabic-rtl-checklist.md
test/localization/
test/helpers/localized_test_app.dart
```

## Implementation Strategy

1. Re-run hardcoded string audit for primary UI paths.
2. Localize remaining app-owned copy.
3. Fix RTL and keyboard-open layout issues in highest-use forms.
4. Add representative widget tests.
5. Run manual Android and PDF QA and record evidence.

## Risks

- Provider output may be mistaken for app-owned copy. Mitigation: classify each finding.
- Manual QA can be skipped. Mitigation: make it a blocking task with evidence.

## Deferred Items Considered

Relevant deferred items: broad localization pass, small-screen RTL QA, keyboard-open QA, Arabic PDF visual inspection, localized widget tests.

