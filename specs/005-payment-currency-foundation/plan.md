# Implementation Plan: Payment Methods And Currency Foundation

## Technical Context

Payment method and currency are required by filters, reports, budget, and AI extraction.

## Architecture

Store payment method on each expense and base currency in user settings. Do not implement conversion in this phase.

## Files

- Create: `packages/expense_repository/lib/src/models/user_settings.dart`
- Create: `packages/expense_repository/lib/src/entities/user_settings_entity.dart`
- Create: `packages/expense_repository/lib/src/settings_repo.dart`
- Create: `packages/expense_repository/lib/src/firebase_settings_repo.dart`
- Create: `lib/screens/settings/blocs/settings_bloc/*`
- Create: `lib/screens/settings/views/settings_screen.dart`
- Modify: `lib/screens/add_expense/views/add_expense.dart`
- Modify: `lib/screens/home/views/main_screen.dart`

## Data Model

`UserSettings`: `baseCurrency`, `supportedCurrencies`, `defaultPaymentMethod`, `updatedAt`.

## Risks

- Mixed-currency totals should not pretend conversion exists.
- Display should use currency codes until conversion is approved.

## Verification

- Settings serialization tests.
- Currency formatter tests.
- Manual settings and add expense flow.

## Detailed Execution Guidance

- Implement settings repository before adding UI controls.
- Use ISO-like currency codes such as `EGP`, `USD`, `EUR` as stored values.
- Payment methods should be stored as stable enum strings, not display labels.
- Default settings should exist for every registered user.
- Totals involving mixed currencies must be visually honest and should not imply conversion.
