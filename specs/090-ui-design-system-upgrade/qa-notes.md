# QA Notes

**Feature**: `090-ui-design-system-upgrade`  
**Date**: 2026-05-27

## Automated Checks

- Widget tests cover the new base components in English/Arabic direction,
  compact width, high text scale, status action, and transaction row rendering.

## Manual QA Still Needed

- Android Arabic small screen: Home, Add Expense, Expenses, Reports, Settings.
- Android English small screen: Home, Add Expense, Expenses, Reports, Settings.
- Add Expense with keyboard open: amount, category, AI input, advanced fields,
  and Save button.
- Reports charts: week/month tabs, empty state, category drilldown, and monthly
  story.
- Settings scroll extent: no blank infinite scroll at the bottom.

## Screenshot Status

No screenshots were captured in this phase because the current task was a code
and component migration pass. Device screenshot capture remains required before
accepting the visual redesign for release.
