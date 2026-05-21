# Feature Specification: Wallets Accounts And Transfers

**Feature Branch**: `075-wallets-transfers`  
**Created**: 2026-05-20  
**Status**: Draft  
**Input**: User requested a future plan for expanding from expense tracking toward personal finance management.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Track Spending By Wallet (Priority: P3)

As a user, I need to assign expenses to wallets/accounts such as cash, bank, card, or mobile wallet.

**Why this priority**: Advanced users need account-level visibility after expense tracking is stable.

**Independent Test**: User creates wallets, assigns expenses, and filters totals by wallet.

**Acceptance Scenarios**:

1. **Given** multiple wallets exist, **When** user adds an expense, **Then** they can choose the wallet/account.
2. **Given** wallet filter is applied, **When** reports show totals, **Then** only matching wallet expenses appear.

---

### User Story 2 - Record Transfers (Priority: P3)

As a user, I need to move money between wallets without counting it as spending.

**Why this priority**: Transfers are required before the app can be a broader finance manager.

**Independent Test**: Transfer changes wallet balances but does not increase expense totals.

**Acceptance Scenarios**:

1. **Given** a transfer from cash to bank, **When** reports calculate expenses, **Then** transfer is excluded from spending.
2. **Given** wallet balances are shown, **When** transfer is saved, **Then** source and destination balances update according to policy.

## Edge Cases

- Multi-currency wallets.
- Transfer fees.
- Deleting/editing transfer.
- Opening balances.
- Wallet archived with existing expenses.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Users MUST be able to create, edit, and archive wallets/accounts.
- **FR-002**: Expenses SHOULD optionally link to a wallet/account.
- **FR-003**: Transfers MUST not be counted as expenses.
- **FR-004**: Wallet balances MUST have a documented calculation policy before display.
- **FR-005**: Multi-currency wallets MUST not silently combine incompatible currencies.

### Key Entities

- **WalletAccount**: Name, type, currency, archived state, opening balance, created/updated dates.
- **Transfer**: Source wallet, destination wallet, amount, currency, fee, date, and note.
- **WalletBalance**: Calculated or stored balance with policy metadata.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Expenses can be filtered by wallet without changing existing category/payment filters.
- **SC-002**: Transfers do not affect spending totals in report fixtures.
- **SC-003**: Multi-currency wallet totals show clear per-currency or conversion policy.
- **SC-004**: Archived wallets remain visible on historical expenses.

## Assumptions

- This is a P3 expansion after trust, localization, Add Expense UX, and reports are stable.
- No bank sync is included.

