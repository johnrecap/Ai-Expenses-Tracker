# Implementation Plan: UI Design System Upgrade

**Branch**: `090-ui-design-system-upgrade` | **Date**: 2026-05-27 | **Spec**: `specs/090-ui-design-system-upgrade/spec.md`  
**Input**: Feature specification from `specs/090-ui-design-system-upgrade/spec.md`

## Summary

Create a coherent finance-focused design system and apply it incrementally to core screens. The plan uses GitHub/open-source references for inspiration and package evaluation, but implementation should prefer local reusable Flutter components unless a dependency clearly reduces risk.

## Technical Context

**Language/Version**: Dart 3.12 / Flutter 3.44  
**Primary Dependencies**: Flutter Material, Font Awesome, `fl_chart`, existing app widgets; candidate UI packages only after review  
**Storage**: None  
**Testing**: Widget/golden-style screenshot checks where feasible, manual Android screenshots, analyzer  
**Target Platform**: Android-first Flutter app with Arabic/English  
**Project Type**: Mobile finance app UI system  
**Performance Goals**: Smooth scrolling on mid-range Android; no heavy effects on repeated list rows  
**Constraints**: Operational app UI, not marketing landing page; no nested cards; no hardcoded strings; low-end Android performance matters  
**Scale/Scope**: Home, Add Expense, Expenses, Reports, Settings, AI surfaces first

## Research References

Detailed reference notes live in `specs/090-ui-design-system-upgrade/research.md`.

- Flutter Templates (`bimsina/fluttertemplates.dev`) provides browsable production-oriented Flutter widget patterns and categories including finance, forms, dashboard, navigation, and profile/account: https://github.com/bimsina/fluttertemplates.dev
- Expense Manager (`nkuppan/expensemanager`) is a production-style open-source finance app. It is Kotlin/Compose, not Flutter, so it is useful for transaction-list and edit/delete UX inspiration only: https://github.com/nkuppan/expensemanager
- Finmori UI Kit lists finance-specific screens/components such as add transaction, analytics, profile/settings, amount input, transaction input, balance cards, charts, and category breakdowns: https://finmori-uikits.vercel.app/
- Trackify is an open-source Flutter personal finance tracker with offline-first finance UX and glassmorphism direction: https://aswin-blix.github.io/trackify/
- gskinner Flutter Vignettes provide permissively licensed Flutter animation/polish examples for isolated interaction ideas, not finance logic: https://github.com/gskinnerTeam/flutter_vignettes
- `liquid_glass_kit` provides glass components and quality controls, but should be tested before adoption because blur can be GPU-expensive: https://pub.dev/packages/liquid_glass_kit
- `oc_liquid_glass` provides liquid-glass droplet effects with shader limitations, useful for isolated tour/accent experiments rather than core lists: https://github.com/heyarny/oc_liquid_glass

## Constitution Check

- UI changes must preserve finance calculation boundaries: PASS.
- User-facing strings must use localization: PASS.
- No card nesting or oversized marketing-style hero for operational screens: PASS.
- Text must fit mobile Arabic/English layouts: PASS.
- New dependencies require documented rationale: PASS.

## Project Structure

```text
lib/theme/
lib/widgets/
lib/screens/home/
lib/screens/add_expense/
lib/screens/expenses/
lib/screens/reports/
lib/screens/settings/
lib/screens/ai_assistant/
test/widgets/
test/home/
test/add_expense/
specs/090-ui-design-system-upgrade/
```

**Structure Decision**: Introduce local theme tokens/components under `lib/theme/` and `lib/widgets/`, then migrate screens one by one. External code is referenced, not copied, unless a later task explicitly adds a vetted dependency.

## Implementation Strategy

1. Expand the reference matrix in `research.md` with license/relevance/risk.
2. Define finance design principles and shared tokens.
3. Create reusable finance components: cards, rows, inputs, status banners, buttons, sheets.
4. Redesign Add Expense around fast daily entry and unified AI.
5. Migrate Home, Expenses, Reports, Settings, and AI surfaces incrementally.
6. Run Arabic/small-screen QA after each surface.

## Finance UI Principles

1. **Numbers are the product**: totals, currencies, dates, conversion caveats,
   and pending states must be more visually important than decoration. UI
   components display values calculated by finance services and never
   recalculate money.
2. **Fast daily capture**: Add Expense must favor the shortest path to record a
   simple expense, with AI as an accelerator and manual fields always reachable.
3. **Draft before commit**: AI output is shown as editable draft data. Any
   uncertain field uses the current app default or remains visibly reviewable;
   no hidden destructive or financial action is performed by presentation code.
4. **Scanable financial hierarchy**: repeated rows use predictable positions for
   category, merchant/description, date, amount, currency, and status.
5. **RTL-first layout**: Arabic text, Arabic keyboard, mixed Latin currency
   codes, and long category names are baseline cases, not edge cases.
6. **Quiet operational style**: cards use restrained radius, no nested card
   layouts, no heavy blur in lists, and no marketing-style hero composition.
7. **Portable polish**: glass/liquid effects are allowed only for isolated
   accents after a spike proves performance and rollback safety.

## Risks

- Big-bang redesign can destabilize the app. Mitigation: migrate one screen at a time.
- Pretty visual effects can reduce usability. Mitigation: finance clarity first; effects only in isolated accents.
- External repos may have incompatible licenses or stale code. Mitigation: reference matrix before adoption.
- UI-only changes can accidentally affect behavior. Mitigation: preserve existing blocs/repositories and add widget tests.

## Verification

```text
flutter gen-l10n
flutter test --no-pub test/widgets test/home test/add_expense --reporter=expanded --timeout=45s
flutter analyze --no-pub
```

Manual QA:

```text
Android device, Arabic/English, small viewport, keyboard open, Home/Add Expense/Expenses/Reports/Settings/AI screenshots.
```

## Deferred Items Considered

Store screenshots, Play Store listing assets, broad design experimentation, and full Figma design system creation remain later unless the user explicitly expands this plan.
