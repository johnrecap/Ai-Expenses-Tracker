# Implementation Plan: Wallets Accounts And Transfers

**Branch**: `075-wallets-transfers` | **Date**: 2026-05-20 | **Spec**: `specs/075-wallets-transfers/spec.md`

## Summary

Plan the transition from expense-only tracking to wallet/account-aware personal finance. The first version should add manual wallets and transfers without bank sync and without changing expense totals incorrectly.

## Technical Context

**Language/Version**: Dart 3.x, Flutter  
**Primary Dependencies**: `expense_repository`, Add Expense, Expenses filters, Reports, Firestore rules  
**Storage**: New user-owned wallet and transfer collections plus optional expense wallet reference  
**Testing**: Repository/entity/rules tests, report tests, wallet UI tests  
**Target Platform**: Flutter mobile  
**Project Type**: Finance domain expansion  
**Performance Goals**: Local wallet/report calculations over loaded data  
**Constraints**: Transfers not counted as expenses; no bank sync; no silent mixed-currency balances  
**Scale/Scope**: One user's manually managed wallets

## Constitution Check

- User-owned Firestore data: PASS.
- Repository boundaries required: PASS.
- Mixed-currency policy required: PASS.
- No unrelated bank integration: PASS.

## Project Structure

```text
packages/expense_repository/lib/src/models/
packages/expense_repository/lib/src/entities/
packages/expense_repository/lib/src/
firestore.rules
functions/test/firestoreRules.rules.ts
lib/screens/wallets/
lib/screens/add_expense/
lib/screens/expenses/
lib/screens/reports/
test/wallets/
test/reports/
test/repository/
```

## Implementation Strategy

1. Add wallet and transfer domain model/repository/rules.
2. Add wallet management screen.
3. Add optional wallet selection to expenses.
4. Add transfer create/edit/archive flow.
5. Update filters/reports so transfers do not count as expenses.

## Risks

- Balance policy can become accounting-heavy. Mitigation: document policy before display.
- Data migration for existing expenses. Mitigation: wallet reference remains optional.

## Deferred Items Considered

This is intentionally P3. Core trust, release readiness, localization, and Add Expense UX should happen first.

