# Design Audit: UI Design System Upgrade

**Feature**: `090-ui-design-system-upgrade`  
**Date**: 2026-05-27

## Scope Reviewed

- `lib/screens/home/`
- `lib/screens/add_expense/`
- `lib/screens/expenses/`
- `lib/screens/reports/`
- `lib/screens/settings/`
- `lib/screens/ai_assistant/`

## Findings

| Area | Current Risk | Required Foundation |
|---|---|---|
| Spacing | Screens use repeated local `SizedBox`, `Padding`, and card spacing values. | Shared spacing tokens so migrated screens keep the same density. |
| Radius | Cards range from 8 to 12+ radius and some surfaces feel more decorative than operational. | Shared radius tokens, with repeated finance cards capped at 8px. |
| Typography | Amounts, subtitles, labels, and status text are styled locally. | Shared amount, title, body, caption, and status styles. |
| Colors | Primary cyan/magenta/orange are useful but applied directly in many places. | Semantic color helpers from `ColorScheme` for surface, accent, success, warning, danger, and muted text. |
| Transaction rows | Home and list rows do not share a common layout contract. | A reusable row with stable leading icon, content, amount/date, and optional status/action slots. |
| Status surfaces | Sync, warning, and AI review states use separate visual patterns. | A compact status banner with predictable severity tones and optional action. |
| Inputs | Add Expense and AI input fields use custom border/fill/suffix behavior. | Shared input wrapper that supports icons, long labels, high text scale, and RTL. |
| RTL | Mixed Arabic text and Latin currency codes can crowd rows and buttons. | Components must be tested in RTL with long labels and small width. |
| Effects | User asked for water/glass guided-tour polish, but repeated finance screens need speed. | Keep effects outside lists and wrap any future package usage behind local components. |

## Phase 2 Acceptance

Phase 2 is considered complete when shared tokens and reusable base widgets
exist with widget tests. Applying them to live screens starts in Phase 3, so
this audit intentionally does not require visual screenshots yet.
