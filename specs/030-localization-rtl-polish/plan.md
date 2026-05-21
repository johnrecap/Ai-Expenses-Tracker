# Implementation Plan: Localization And RTL Polish

**Branch**: `030-localization-rtl-polish` | **Date**: 2026-05-17 | **Spec**: `specs/030-localization-rtl-polish/spec.md`  
**Input**: Add Arabic/English localization foundation, fix broken text, and make core layouts RTL-safe.

## Summary

Introduce Flutter localization resources for core screens, migrate hardcoded strings gradually, fix the visible bad separator, and run Arabic/English UI checks on key screens. This plan focuses on user-visible polish, not changing data models.

## Technical Context

**Language/Version**: Dart 3.x, Flutter localization tooling  
**Primary Dependencies**: `flutter_localizations`, `intl`, generated app localizations  
**Storage**: Optional future locale preference in user settings; not required for first slice  
**Testing**: Localization generation, widget tests with Arabic/English locales, manual RTL screenshots  
**Target Platform**: Flutter app all targets, Android priority  
**Project Type**: Multi-platform Flutter app  
**Performance Goals**: Localization lookup must not affect normal screen responsiveness  
**Constraints**: Do not translate user-generated data; avoid layout clipping; no new state-management package  
**Scale/Scope**: Core screens and shared widgets first

## Constitution Check

- Preserve existing Bloc/Cubit and repository patterns.
- User settings must go through `SettingsRepository` if a persisted language preference is added.
- Formatting remains based on `intl`.
- UI text must not overlap or clip on mobile.

## Project Structure

```text
lib/
|-- l10n/
|   |-- app_en.arb
|   `-- app_ar.arb
|-- generated or gen_l10n output
|-- screens/
`-- widgets/

l10n.yaml
pubspec.yaml
```

**Structure Decision**: Use Flutter's standard localization generation. Keep ARB files under `lib/l10n` unless project conventions already specify another folder.

## Implementation Notes

- Start with core screens and shared messages rather than every string in one risky pass.
- Fix known mojibake immediately even before full localization migration.
- Use localized tooltips for icon buttons.
- Use `Directionality` only when needed for mixed text previews; let app locale drive normal direction.

## Risks

- Large string migrations can cause missed keys. Mitigation: slice by screen and run generation/analyze frequently.
- Arabic labels may be longer. Mitigation: responsive layouts, icon buttons, and wrap where needed.
- Generated localization setup may affect build config. Mitigation: keep changes standard and documented.
