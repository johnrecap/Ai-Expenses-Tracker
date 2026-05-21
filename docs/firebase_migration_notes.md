# Firebase Migration Notes

## Plan 002 Decision

Plan 002 changes authenticated production data from global Firestore collections to user-owned subcollections:

- `users/{userId}/expenses`
- `users/{userId}/categories`

The old global collections are treated as legacy only:

- `expenses`
- `categories`

No automatic migration is implemented in this plan because the repository does not include evidence of real production data or an owner mapping for old documents.

## If Legacy Data Exists Later

Do not copy every legacy document to every user. A future migration must first decide ownership for each legacy document.

Recommended options:

1. Assign all legacy documents to one chosen user only when the data is known to belong to that account.
2. Export legacy documents and let users re-import their own data.
3. Add an admin-reviewed mapping file that maps each legacy document id to a specific Firebase Auth user id.

After migration, authenticated app traffic should continue to use only `users/{userId}/...` paths.
