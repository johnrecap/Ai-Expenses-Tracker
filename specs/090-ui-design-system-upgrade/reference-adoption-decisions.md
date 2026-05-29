# Reference Adoption Decisions

**Feature**: `090-ui-design-system-upgrade`  
**Date**: 2026-05-27

## Adopted Locally

| Reference | Decision | Reason |
|---|---|---|
| Finmori UI Kit | Adopt hierarchy ideas only | Finance cards, transaction rows, and add-transaction flow inspired the local component set, but no code was copied because it is not Flutter. |
| Flutter Templates | Adopt component inventory ideas only | Useful for deciding the reusable building blocks: cards, inputs, status banners, and rows. |
| Expense Manager | Adopt edit/delete affordance direction only | The existing app already has edit/delete. The UI work keeps actions clear without copying non-Flutter code. |
| Trackify | Adopt modern finance density direction only | Offline-first and modern cards are relevant, but architecture is not imported. |

## Rejected For Production Path Now

| Reference | Decision | Reason |
|---|---|---|
| `save_points_showcaseview` | Do not add dependency now | The app already has a custom guided-tour overlay. Plan 089 improved it without adding dependency risk. |
| `liquid_glass_renderer` / `liquid_glass_kit` | Spike only later | User wants water/glass effects, but repeated finance screens must stay fast. A later isolated spike can target the tour/profile accent only. |
| `oc_liquid_glass` | Spike only later | Shader/platform risk is not acceptable in core flows until tested on Android hardware. |
| GitHub Dart expense tracker topic | Discovery only | Quality and maintenance vary too much for direct adoption. |

## Current Implementation Choice

The production path uses local Flutter widgets:

- `FinanceCard`
- `MoneyAmountText`
- `TransactionRow`
- `AppStatusBanner`
- `AppTextField`

This keeps rollback simple: screens can move back to local widgets without
removing any package dependency.
