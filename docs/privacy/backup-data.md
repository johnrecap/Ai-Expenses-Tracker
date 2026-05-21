# Backup Data And Privacy

Structured app backups are for user-owned finance data portability. They are
separate from CSV, Excel, and PDF report exports.

## Included Data

- Expenses and their category snapshots.
- Categories, including archived categories needed by old expenses.
- Monthly budgets and category budgets.
- Recurring expense rules.
- Saving goals.
- Wallet accounts and transfers, when present. Transfers remain separate from
  expense totals and are restored as transfer records rather than spending.
- User settings required to restore app preferences, currencies, exchange-rate
  cache metadata, onboarding, guided tour state, and notification preferences.
- Learned category aliases used by AI category matching.

Every backup includes a manifest with schema version, app version, creation
time, source user ID, collection names, and per-collection counts.

## Excluded Sensitive Data

Backups must not include:

- Firebase Auth tokens, refresh tokens, OAuth tokens, or provider credentials.
- Google Sign-In profile tokens or provider secrets.
- AI provider keys, gateway secrets, Authorization headers, or raw backend
  credentials.
- Plain PIN values, PIN hashes, biometric state, secure-storage keys, or local
  app-lock secrets.
- Receipt image files, provider raw responses, raw prompts, or usage logs that
  could expose sensitive personal data.
- Ad, purchase, entitlement verification secrets, or production service keys.

## Restore Safety

Restore/import must parse and validate the backup before any write. The preview
must show adds, updates, skips, conflicts, and warnings, and the user must pick
an explicit conflict policy before repository-backed restore execution.
