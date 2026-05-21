# Firestore Rules And Index Deployment

## Files

- Rules: `firestore.rules`
- Indexes: `firestore.indexes.json`
- Firebase CLI mapping: `firebase.json`

## Local Verification

Use the fast Functions unit test command for backend unit tests that do not
start emulators:

```sh
cd functions
npm test
```

The repo includes Firestore rules tests under
`functions/test/firestoreRules.rules.ts`. Run them through the Firebase
Firestore emulator:

```sh
cd functions
npm run test:rules
```

To run both groups from the Functions workspace:

```sh
npm run test:all
```

`firebase.json` pins the local Firestore emulator to `127.0.0.1:18080` so the
tests do not collide with tools that commonly occupy the default `8080` port.
The rules command requires the Firebase CLI and Firestore emulator to be
available locally; emulator startup failures should be reported separately from
ordinary `npm test` failures.

The rules test suite covers:

- Owner can create/read valid documents for every user-scoped collection.
- Unauthenticated and cross-user reads/writes are denied.
- Global `expenses` and `categories` reads/writes are denied.
- Malformed writes are denied for amount, currency, month, owner, AI metadata,
  notification settings, and settings profile fields.

## Deploy

Deploy rules and indexes together only after the parent Flutter verification
suite passes:

```sh
firebase deploy --only firestore
```

To deploy separately:

```sh
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
```

## Expense Pagination Index

Expense list scaling uses a stable newest-first cursor:

```text
users/{userId}/expenses
  orderBy date desc
  orderBy expenseId desc
  startAfter([lastDate, lastExpenseId])
  limit(pageSize + 1)
```

Date filters stay server-scoped with `where date >=` and/or `where date <=`
before local deterministic filtering. Search, category, amount, payment method,
and currency filters are applied to the loaded page scope unless a future
full-history search index is added.

## Rollback

If a production deploy causes permission-denied or missing-index failures:

1. Re-deploy the last known good `firestore.rules` and
   `firestore.indexes.json`.
2. Confirm the Firebase console shows the previous composite indexes as enabled.
3. Re-run emulator scenarios for the failing collection.
4. Capture the denied document payload and update the schema doc before changing
   rules again.

Do not loosen ownership checks. If a valid app write is blocked, prefer adding
the specific field/type the app writes rather than restoring broad subtree
access.
