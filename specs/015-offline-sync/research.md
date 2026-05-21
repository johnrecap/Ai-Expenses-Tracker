# Research: Offline Mode And Sync Feedback

## Firestore Offline Support

Decision: Use Cloud Firestore offline persistence and snapshot metadata as the
source of truth for the first offline/sync feedback release.

Rationale: Firebase documents that Firestore caches actively used data, accepts
offline reads/writes/queries, and syncs local changes when the device comes back
online. For Android and Apple platforms, persistence is enabled by default. For
web, persistence must be configured explicitly by the app if durable offline
cache behavior is required. Offline persistence is documented as supported for
Android, Apple, and web apps; desktop Flutter targets should be treated as not
covered by Firestore's documented offline persistence guarantee for this plan.

Snapshot metadata exposes pending local writes. FlutterFire supports
`snapshots(includeMetadataChanges: true)`, which is required so listeners emit
again when metadata changes from pending local writes to server-acknowledged
writes.

Sources:
- Firebase Firestore offline guide:
  https://firebase.google.com/docs/firestore/manage-data/enable-offline
- FlutterFire Firestore usage guide:
  https://firebase.flutter.dev/docs/firestore/usage

## Sync Status Model

Decision: Add a non-persisted `SyncStatus` model with `pending`, `synced`, and
`failed` states. Map Firestore `hasPendingWrites` to `pending`; map the absence
of pending writes to `synced`.

Rationale: Firestore metadata does not expose a durable per-document "failed"
state. The `failed` value is reserved for future explicit write-failure UI if a
later plan adds retry tracking.

## Connectivity Package

Decision: Do not add `connectivity_plus` for Plan 015.

Rationale: The requested banner and row indicators can be driven by Firestore
metadata without introducing a new platform dependency. This keeps the first
offline release focused on observable pending writes rather than network
reachability, which can be misleading when a device has network access but
Firestore is still unavailable.

Alternatives considered: Add `connectivity_plus` for an explicit "offline"
banner. Rejected for this plan because pending-write metadata provides the
sync-specific feedback users need, and the task guidance says to use Firestore
metadata first.
