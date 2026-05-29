# UI Reference Research: UI Design System Upgrade

**Feature**: `090-ui-design-system-upgrade`  
**Date**: 2026-05-27

This file seeds the reference matrix for the UI redesign. These references are
for evaluation and inspiration only. Do not copy code or add dependencies until
license, maintenance, Flutter compatibility, performance, and rollback risk are
documented during implementation.

## Candidate Reference Matrix

These references are not implementation dependencies. They define a review
matrix so later UI work can borrow interaction patterns safely without copying
unvetted code.

| Reference | License / Status To Verify | Relevance | Activity / Maintenance Risk | Compatibility Risk | Decision |
|---|---|---|---|---|---|
| Flutter Templates (`bimsina/fluttertemplates.dev`) | Verify repository license before copying any code | Broad Flutter component patterns for forms, cards, navigation, dashboard, and profile surfaces | Template repositories can mix production and demo quality | May introduce generic template styling that does not match finance trust needs | Use as visual/layout reference only; reimplement locally with app tokens |
| Expense Manager (`nkuppan/expensemanager`) | Verify current license and third-party assets before reuse | Strong transaction list, edit/delete, budget, and account affordance reference | Kotlin/Compose app activity does not guarantee Flutter relevance | Not Flutter; code is not portable into this project | Use UX flow ideas only, especially edit/delete affordances |
| Trackify (`aswin-blix/trackify`) | Verify license and package compatibility before any adaptation | Flutter finance tracker with offline-first direction and modern surfaces | Could be a personal/demo app with stale dependencies | Architecture may conflict with current BLoC/repository boundaries | Use screenshots/patterns as inspiration, not architecture |
| Finmori UI Kit | Verify licensing terms for commercial use | Finance-specific screens: add transaction, balance cards, analytics, profile/settings, category breakdowns | External kit may not track Flutter or this app's dependencies | React Native, not Flutter | Use design tokens, hierarchy, and flow ideas only |
| gskinner Flutter Vignettes | Verify license for any copied snippet | Polished Flutter motion examples and micro-interactions | Examples are intentionally experimental | Motion can distract from financial clarity | Use isolated animation ideas after performance review |
| `save_points_showcaseview` | Verify pub.dev license and release health | Guided-tour coach marks and pointer behavior | Adds dependency where a custom tour already exists | API mismatch may increase tour maintenance | Compare only; current custom tour remains default |
| `liquid_glass_renderer` / `liquid_glass_kit` | Verify package license, supported Flutter version, and shader behavior | User-requested glass/water treatment for tour/profile accent areas | Visual packages can be GPU-heavy or abandoned | Risky inside scrolling lists and low-end Android | Spike only for isolated accent surfaces; no core list usage |
| `oc_liquid_glass` | Verify license, platform support, and shader limitations | Droplet/water pointer effect ideas for guided-tour callouts | Shader effects may be fragile across Android GPUs | Could fail on devices without suitable shader support | Spike only if custom painter cannot deliver the effect |
| GitHub Dart expense-tracker topic | Per-repo license required | Additional comparison for finance rows, empty states, budget cards | Many repos are stale tutorials | Quality varies heavily | Use only as discovery source, never direct dependency |

## Current UI Audit

| Surface | Current Pattern | Issues To Fix In Later Phases | Design System Need |
|---|---|---|---|
| Home | Large gradient summary, white repeated cards, custom transaction rows, sync banner | Mixed radii, repeated hardcoded spacing, sync pending state is visually loud, transaction row hierarchy differs from Expenses | Shared finance cards, transaction row, compact status banner, amount text |
| Add Expense | Manual form plus AI fill card, many custom inputs, expandable advanced fields | Top card competes with core fields, dropdown/input shapes differ, keyboard-open layout needs stricter constraints | Shared input, AI/draft status banner, stable field spacing |
| Expenses | Dedicated list/actions with edit/delete flow | Must match Home row affordances and show metadata/pending state consistently | Transaction row and action slots |
| Reports | Summary and chart containers use local card styling | Mixed card radii and report caveat styling; chart cards need clearer headers and empty states | Finance card, status/caveat banner, amount text |
| Settings/Profile | `SettingsSection` has local card styling and typography | Plain identity/profile surfaces, scroll density varies, section headers differ from finance cards | Shared card section, text hierarchy tokens |
| AI Assistant | Text input and preview cards are locally styled | Home AI and Add Expense AI differ; suffix actions can crowd on small screens | Shared input and status/action surfaces |

## Design Guardrails

- Financial clarity wins over decorative effects.
- Do not place cards inside cards; use full-width sections and compact repeated cards.
- Repeated list rows must avoid heavy blur, shader, and backdrop effects.
- Arabic RTL, keyboard-open Add Expense, and small Android viewports are mandatory
  checks before accepting a redesigned surface.
- Any adopted package must have an exit path: local wrapper, isolated usage, and
  no direct dependency from core finance logic.
- Money values must never depend on visual style choices. UI components display
  already-calculated values and must not perform exchange-rate math.
- Any visual package adoption needs a local wrapper and a rollback path before
  it reaches production screens.

## Source Links

- Flutter Templates: https://github.com/bimsina/fluttertemplates.dev
- Expense Manager: https://github.com/nkuppan/expensemanager
- Trackify: https://github.com/aswin-blix/trackify
- Finmori UI Kit: https://finmori-uikits.vercel.app/
- gskinner Flutter Vignettes: https://github.com/gskinnerTeam/flutter_vignettes
- save_points_showcaseview: https://pub.dev/packages/save_points_showcaseview
- liquid_glass_renderer: https://pub.dev/packages/liquid_glass_renderer
- oc_liquid_glass: https://github.com/heyarny/oc_liquid_glass
- GitHub Dart expense tracker topic: https://github.com/topics/expense-tracker?l=dart
