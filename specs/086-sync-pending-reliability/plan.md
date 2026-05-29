# Implementation Plan: Sync Pending Reliability

**Branch**: `086-sync-pending-reliability` | **Date**: 2026-05-27 | **Spec**: `specs/086-sync-pending-reliability/spec.md`  
**Input**: Feature specification from `specs/086-sync-pending-reliability/spec.md`

## Summary

Harden local-first sync state so normal online saves acknowledge quickly and genuine pending states explain their cause. The plan audits the VPS `SyncCoordinator`, local queue persistence, expense row status, and Home banner copy. It keeps offline-first behavior but removes vague "waiting to sync" states when the app can push immediately.

## Technical Context

**Language/Version**: Dart 3.12 / Flutter 3.44; TypeScript/Fastify for server idempotency checks  
**Primary Dependencies**: `SyncCoordinator`, `LocalSyncQueue`, `VpsApiClient`, Firebase token provider, local repositories, Home transaction widgets  
**Storage**: Local queue in `packages/expense_repository/lib/src/sync/`; PostgreSQL `sync_changes` on VPS  
**Testing**: Flutter sync coordinator tests, server sync conflict/idempotency tests, Home widget tests  
**Target Platform**: Android device in VPS pilot mode  
**Project Type**: Mobile app with local-first sync backend  
**Performance Goals**: Immediate sync attempt after local write; bounded retry without blocking UI  
**Constraints**: Do not mark unsynced data as synced; do not log secrets; manual and AI saves share the same sync path  
**Scale/Scope**: Current authenticated user queue

## Constitution Check

- Flutter VPS calls go through `VpsApiClient` and sync services: PASS.
- Widgets must not construct HTTP requests or token handling inline: PASS.
- Offline feedback must use repository/sync metadata and localized copy: PASS.
- Sensitive logs must not expose tokens or raw descriptions: PASS.
- Firebase legacy rollback remains available: PASS.

## Project Structure

```text
packages/expense_repository/lib/src/sync/
packages/expense_repository/lib/src/local/
packages/expense_repository/lib/src/api/
lib/screens/auth/views/auth_gate.dart
lib/screens/home/
lib/widgets/sync_status_banner.dart
lib/l10n/
server/src/sync/
server/tests/integration/
test/api/
test/home/
```

**Structure Decision**: Fix state in the sync coordinator and queue first. UI only reflects coordinator state and never guesses sync status.

## Implementation Strategy

1. Reproduce and trace why an AI-created expense stayed Pending.
2. Add explicit status reasons to local queue/coordinator.
3. Trigger immediate push after create/update/delete in VPS mode.
4. Clear pending state on server acknowledgement and persist durable status.
5. Improve banner/row copy and retry controls.
6. Add idempotency and restart tests.
7. Verify on real device after APK build.

## Risks

- Hiding Pending would be unsafe. Mitigation: only clear after server acknowledgement.
- Too-aggressive retry can drain battery or spam server. Mitigation: bounded backoff.
- Queue persistence may still be in-memory in parts of pilot code. Mitigation: audit and add durable queue task.

## Verification

```text
flutter test --no-pub test/api test/home --reporter=expanded --timeout=45s
flutter analyze --no-pub
cd server && npm run typecheck && npm test
```

Device smoke:

```text
Install VPS build, sign in, save AI and manual expenses, verify Pending clears or shows a specific reason.
```

## Deferred Items Considered

The deferred backlog already tracks applying pulled VPS sync changes into local repositories and adding explicit VPS sync UI states. This plan pulls those user-visible parts into active work for create/update/delete reliability.
