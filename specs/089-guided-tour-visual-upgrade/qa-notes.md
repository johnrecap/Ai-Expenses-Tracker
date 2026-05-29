# Guided Tour Visual QA Notes

## Baseline Audit

- Current overlay already dims the page and draws a target spotlight, but the
  explanation card has no visual connector to the highlighted element.
- The card uses a plain rectangular surface and can feel detached from the
  target, especially when the target is a small icon near the top edge.
- Arabic RTL copy is present, but compact screens need explicit button and
  connector checks because the card can sit close to top navigation controls.
- Existing target registration is state-driven through `SpotlightTarget`; no
  AI, permission, ads, or purchase flow is invoked by the tour.

## Package Decision

- No third-party package was added.
- `save_points_showcaseview` overlaps with existing state/persistence and would
  require migration risk for little visual benefit.
- `liquid_glass_kit` and `oc_liquid_glass` are references only; shader or glass
  effects are unnecessary for the MVP and could hurt low-end Android performance.

## Manual QA Still Required

- Capture real Android screenshots for Arabic and English on Home tour steps:
  AI assistant, manual expense, budget, reports, categories, and settings.
- Replay from Settings after a language switch.
- Validate low-end device smoothness and reduced animation behavior.
