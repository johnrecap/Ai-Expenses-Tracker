# Implementation Plan: Localization Export And UX Polish

**Branch**: `036-localization-export-ux-polish` | **Date**: 2026-05-18 | **Spec**: `specs/036-localization-export-ux-polish/spec.md`  
**Input**: Audit findings around hardcoded English strings, PDF Unicode warnings, Add Expense no-op category field, and unfinished production polish.

## Summary

Complete Arabic/English localization across core surfaces, fix PDF export Arabic rendering with a bundled Unicode font, and remove no-op or misleading UI interactions from the main user flows.

## Technical Context

**Language/Version**: Dart 3.x, Flutter  
**Primary Dependencies**: `flutter_localizations`, `intl`, generated l10n, `pdf`, existing export services  
**Storage**: ARB files and bundled font asset; no database schema changes  
**Testing**: `flutter gen-l10n`, widget tests, export tests, manual RTL/device checks  
**Target Platform**: Android priority with multi-platform Flutter compatibility  
**Project Type**: Multi-platform Flutter app  
**Performance Goals**: No noticeable UI slowdown; PDF export remains responsive for normal expense ranges  
**Constraints**: Do not translate user-generated content; keep existing screen structure  
**Scale/Scope**: Core screen strings, export font, no-op controls, logout confirmation

## Constitution Check

- Static user-facing strings introduced in localized surfaces must use ARB files and generated localization.
- User-generated content must not be translated.
- Export features must stay inside `lib/services/export`.
- Preserve existing Bloc/Cubit and repository patterns.
- Verify with `flutter gen-l10n`, `flutter analyze`, and `flutter test`.

## Project Structure

```text
lib/l10n/app_en.arb
lib/l10n/app_ar.arb
lib/l10n/generated files
lib/services/export/
lib/screens/add_expense/
lib/screens/home/
lib/screens/settings/
lib/screens/ai_assistant/
lib/screens/monetization/
assets/fonts/
test/localization/
test/export/
```

**Structure Decision**: Keep localization resources under existing l10n setup and keep PDF font loading inside export service code.

## Implementation Notes

- Use `AppLocalizations.of(context)` in widgets, not ad-hoc string maps.
- Keep domain/user strings unchanged: category names, descriptions, notes, provider messages if already user data.
- Add font to `pubspec.yaml` assets or load from root bundle specifically for PDF generation.
- Avoid broad UI refactors; fix only clear no-op/misleading interactions.

## Risks

- Large ARB edits can miss generated files. Mitigation: always run `flutter gen-l10n`.
- Arabic PDF shaping can require font and text direction handling. Mitigation: test with actual Arabic sample data.
- Replacing strings may accidentally change test finders. Mitigation: update tests to use l10n where appropriate.
