# Implementation Plan: Incomplete Feature Surface Readiness

**Branch**: `079-incomplete-feature-surface-readiness` | **Date**: 2026-05-20 | **Spec**: `specs/079-incomplete-feature-surface-readiness/spec.md`  
**Input**: Incomplete feature risks from review of Premium, Wallets/Transfers, and Backup/Restore.

## Summary

Harden feature surfaces so incomplete foundations do not look like finished user workflows. The plan either safely gates unfinished entry points or completes minimal coherent flows for wallets/transfers and restore before exposing them.

## Technical Context

**Language/Version**: Dart 3.x, Flutter  
**Primary Dependencies**: Existing monetization cubit/services, wallet/transfer repositories, backup serializer/restore preview  
**Storage**: Existing Firestore user-scoped collections for wallets/transfers; restore writes remain blocked until implemented safely  
**Testing**: Widget tests for feature gates, wallet flow tests, restore preview/execution tests, monetization CTA tests  
**Target Platform**: Flutter Android-first mobile app  
**Project Type**: Mobile app  
**Performance Goals**: Feature readiness checks must be local and instant  
**Constraints**: No real purchases without trusted backend; no restore writes without confirmation; no transfers counted as spending  
**Scale/Scope**: Settings, Home/menu entry points, Wallets/Transfers, Backup/Restore, Premium CTA

## Constitution Check

- Spec Kit artifacts live under `specs/079-incomplete-feature-surface-readiness/`: PASS.
- User trust and data safety take priority over exposing incomplete scope: PASS.
- Destructive operations require confirmation and tests: PASS.
- Premium must not unlock permanently from untrusted client-only state: PASS.
- Firestore writes remain user-scoped through repositories: PASS.

## Project Structure

```text
lib/screens/settings/widgets/privacy_settings_section.dart
lib/screens/settings/widgets/monetization_settings_section.dart
lib/screens/monetization/views/free_premium_screen.dart
lib/monetization/
lib/screens/wallets/
lib/screens/add_expense/views/add_expense.dart
lib/screens/expenses/widgets/expense_edit_sheet.dart
lib/screens/reports/
lib/services/backup/
lib/l10n/app_en.arb
lib/l10n/app_ar.arb
```

## Design Decisions

### Decision 1: Gate first, complete second

If a workflow cannot be completed in the plan slice, hide or disable it with honest copy rather than leaving a broken path.

### Decision 2: Restore is opt-in and preview-first

Restore must parse and preview changes before any repository write. Conflicts require a visible policy and explicit confirmation.

### Decision 3: Wallet transfers are not expenses

Transfers must not count in spending reports, budgets, AI summaries, or digest totals. Fees can be handled separately only if explicitly modelled.

## Implementation Strategy

1. Inventory visible entry points for premium, backup/restore, wallets, and transfers.
2. Add feature readiness helpers and localized disabled explanations.
3. Complete or gate each feature surface.
4. Add tests proving high-risk actions cannot proceed when incomplete.
5. Implement minimal wallet/transfer UI only if completing the slice.
6. Keep restore execution blocked until preview, conflict policy, and tests are present.

## Risks

- Hiding too much can make implemented foundation feel unused; use honest "not ready" copy in developer/internal surfaces if needed.
- Restore execution can damage user data; implementation must be conservative.
- Premium UI can confuse users if "coming soon" appears too often.

## Deferred Items Considered

The deferred backlog already tracks production premium backend, server-side entitlement restore, wallet transfer currency policy, and backup/restore execution. This plan turns those into visible-product safety gates and minimal completion slices.

