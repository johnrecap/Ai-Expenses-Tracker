# Wallets Accounts And Transfers Research

## Balance And Transfer Policy

Wallet balances are derived from wallet documents plus loaded user-owned finance
documents. The app must not promise bank-grade ledger accounting in this phase.

- Opening balance: `WalletAccount.openingBalance` is the starting amount for the
  wallet's own `currency`.
- Expenses: expenses with `walletAccountId` decrease that wallet by
  `Expense.amount` only when the expense currency matches the wallet currency.
  Expenses without a wallet remain valid and do not affect wallet balances.
- Transfers: transfers are separate documents under `users/{userId}/transfers`.
  They are never stored as expenses and must not be included in spending totals.
- Transfer debit/credit: a transfer decreases `sourceWalletId` by `amount` and
  increases `destinationWalletId` by `amount` when the transfer currency matches
  each wallet's currency. Cross-currency transfers require a later explicit
  exchange policy and must not be silently netted into one balance.
- Transfer fees: `feeAmount` is optional and defaults to zero. Fees are treated
  as wallet balance reductions from `feeWalletId` when present, otherwise from
  `sourceWalletId`. Fees are not expenses until a future plan defines whether
  and how they should create categorized spending records.
- Archived wallets: archived wallets are hidden from new selections by default
  but remain readable and renderable for historical expenses and transfers.
- Multi-currency totals: wallet summaries should group balances per currency or
  use the existing saved-rate conversion boundary with explicit converted and
  unconverted metadata. The first implementation must not add incompatible
  currencies together.
- Edits and archives: editing a transfer changes derived balances the next time
  balances are recalculated. Archiving a transfer excludes it from active balance
  calculations but preserves the historical record.

## Firestore Structure

Wallets live under:

```text
users/{userId}/wallets/{walletId}
```

Required wallet fields:

- `walletId`: document id.
- `userId`: authenticated owner id.
- `name`: non-empty display name.
- `type`: one of `cash`, `bank`, `card`, `mobile_wallet`, or `other`.
- `currency`: three-letter uppercase ISO-like code.
- `openingBalance`: non-negative number in the wallet currency.
- `isArchived`: archive flag.
- `createdAt`: timestamp.
- `updatedAt`: timestamp.

Transfers live under:

```text
users/{userId}/transfers/{transferId}
```

Required transfer fields:

- `transferId`: document id.
- `userId`: authenticated owner id.
- `sourceWalletId`: non-empty wallet id.
- `destinationWalletId`: non-empty wallet id, different from source.
- `amount`: positive number.
- `currency`: three-letter uppercase ISO-like code.
- `feeAmount`: non-negative number.
- `date`: timestamp.
- `note`: bounded optional string.
- `isArchived`: archive flag.
- `createdAt`: timestamp.
- `updatedAt`: timestamp.

Optional transfer fields:

- `feeWalletId`: wallet id charged for fees. If omitted, the source wallet is
  charged by balance calculators.

Expense wallet linkage is optional for migration safety:

- `walletAccountId`: nullable wallet id.
- `walletAccountName`: nullable historical wallet display snapshot.

## Indexes

Expected query order:

- Wallets: `createdAt desc`, optionally filtered locally by `isArchived`.
- Transfers: `date desc`, optionally filtered locally by `isArchived`.
- Expenses: current date-scoped reads remain the primary query path; wallet
  filtering composes as local filtering on loaded expenses to avoid requiring a
  new compound index in the first implementation.
