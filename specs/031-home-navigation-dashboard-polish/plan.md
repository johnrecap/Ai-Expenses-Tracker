# Implementation Plan: Home Navigation And Dashboard Polish

**Branch**: `031-home-navigation-dashboard-polish` | **Date**: 2026-05-17 | **Spec**: `specs/031-home-navigation-dashboard-polish/spec.md`  
**Input**: Fix no-op Home controls, keep dashboard data real, and improve action discoverability.

## Summary

Audit Home actions, connect the Settings icon, remove or implement no-op controls, verify dashboard values come from real summaries, and add tooltips/semantics plus responsive constraints for action rows.

## Technical Context

**Language/Version**: Dart 3.x, Flutter  
**Primary Dependencies**: Flutter Material navigation, Bloc/Cubit home/settings state  
**Storage**: Existing repositories only; no schema changes  
**Testing**: Home calculator tests, Home widget tests, navigation tests, small viewport visual/manual check  
**Target Platform**: Android/mobile first, Flutter all targets  
**Project Type**: Flutter app  
**Performance Goals**: Home renders without extra expensive recalculation in widgets  
**Constraints**: No fake finance values; no new routing package; no UI overlap  
**Scale/Scope**: Home screen action row, settings navigation, dashboard state rendering

## Constitution Check

- Home financial totals must use `HomeSummaryCalculator`.
- Widgets must not reintroduce hardcoded names, fake income, or fake balances.
- Settings access must go through existing Settings screen/repository patterns.
- Preserve existing navigation style.

## Project Structure

```text
lib/screens/home/
|-- views/main_screen.dart
|-- models or calculators
`-- widgets/

lib/screens/settings/
test/home/
```

**Structure Decision**: Keep changes inside Home screen/widgets and existing Settings route. Extract an action model/widget only if it reduces duplicated icon-button logic.

## Implementation Notes

- Start with the no-op Settings icon because it is a direct bug.
- If action row is too crowded, group secondary actions into a menu while keeping primary actions visible.
- Tooltips should be short and localized when localization exists.
- Keep logout confirmation if already present or add one if accidental logout is likely.

## Risks

- Moving actions can confuse existing users. Mitigation: keep primary controls in familiar positions and label secondary menu clearly.
- Calculator tests may reveal existing dashboard mismatch. Mitigation: fix data flow rather than hardcoding.
