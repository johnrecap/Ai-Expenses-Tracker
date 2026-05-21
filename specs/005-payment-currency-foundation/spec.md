# Feature Specification: Payment Methods And Currency Foundation

**Feature Branch**: `005-payment-currency-foundation`
**Created**: 2026-05-15
**Status**: Draft

## User Scenarios & Testing

### User Story 1 - User Selects Payment Method (P1)
As a user, I choose whether an expense was paid by Cash, Visa, Wallet, or Bank Transfer.

**Acceptance Criteria**
- Add Expense includes payment method.
- Expense list can display payment method.

### User Story 2 - User Has A Base Currency (P1)
As a user, I choose a base currency so amounts are displayed consistently.

**Acceptance Criteria**
- User settings store base currency.
- New expenses store currency code.
- UI no longer hardcodes `$`.

## Functional Requirements

- Add user settings model and repository.
- Add settings screen.
- Add currency formatter.
- Add payment method selector.

## Out Of Scope

- Live exchange rate conversion.
- Historical exchange rates.

## Success Metrics

- Expenses persist payment method and currency.
- Base currency is saved in user settings.

## Detailed Requirements And Edge Cases

- This feature stores currency codes only; no exchange-rate conversion is allowed here.
- Hardcoded `$` should be removed where an expense has a currency.
- If settings are missing, create safe defaults: `EGP` and `cash`.
- Payment method values must be stable enum strings for Firestore.
- Mixed-currency totals must either be separated or clearly marked as not converted.
