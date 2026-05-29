# Tasks: Sync Pending Reliability

**Input**: Design documents from `specs/086-sync-pending-reliability/`  
**Prerequisites**: `plan.md`, `spec.md`

## Phase 1: Reproduction And Trace

- [ ] T001 Reproduce pending AI save with current APK/logs using `lib/screens/ai_assistant/` and VPS mode. Why: the bug must be traced before changing UX. Expected: known failing path and logs. Risk: fixing the wrong layer. Modification: document whether save, queue, push, or ack is failing.
- [X] T002 Audit `SyncCoordinator` and `LocalSyncQueue` in `packages/expense_repository/lib/src/sync/`. Why: pending state is owned by sync, not UI. Expected: current lifecycle map. Risk: UI hacks hide real failures. Modification: identify missing trigger/ack/status persistence.
- [X] T003 Audit server idempotency in `server/src/sync/`. Why: retry safety depends on backend behavior. Expected: accepted duplicate retry semantics known. Risk: retry creates duplicates. Modification: list required server tests.

## Phase 2: Foundational Sync Status Model

- [X] T004 [P] Add `SyncStatusReason` to sync models in `packages/expense_repository/lib/src/sync/`. Why: users need reason-specific state. Expected: offline, auth, server, validation, queued, syncing, unknown. Risk: vague Pending remains. Modification: keep raw errors internal.
- [X] T005 [P] Add localized sync copy in `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb`. Why: Arabic users need clear status. Expected: short messages and retry labels. Risk: hardcoded English banner. Modification: run `flutter gen-l10n`.
- [X] T006 Add sync status tests in `test/api/sync_coordinator_status_test.dart`. Why: state mapping must be deterministic. Expected: each failure maps to reason. Risk: random error strings in UI. Modification: fake API/token failures.

## Phase 3: User Story 1 - Online Saves Sync Without Lingering Pending (P1)

**Independent Test**: Online save reaches synced after server acknowledgement.

- [X] T007 Trigger immediate push after local create/update/delete in repository or coordinator boundary. Why: online users should not wait for app resume/manual retry. Expected: push starts after local commit. Risk: pending stays until later lifecycle event. Modification: centralize trigger after local writes.
- [X] T008 Clear pending queue item only after VPS acknowledgement. Why: correctness must beat cosmetic status. Expected: server ack updates local status. Risk: data loss if cleared early. Modification: persist ack revision/cursor.
- [ ] T009 Add tests in `test/api/sync_coordinator_test.dart`. Why: create/update/delete must all transition correctly. Expected: pending -> syncing -> synced. Risk: AI path fixed but manual path broken. Modification: test shared queue.
- [X] T010 Verify AI-created expenses use same queue path as manual expenses. Why: screenshot showed AI save pending. Expected: no separate AI-only pending state. Risk: AI bypass remains. Modification: route through shared repository create.

## Phase 4: User Story 2 - Pending Has a Reason and Action (P1)

**Independent Test**: Offline/auth/server failures show distinct localized messages.

- [X] T011 Implement reason mapping in `VpsApiClient`/sync coordinator. Why: exceptions must become user-safe states. Expected: auth/server/network/validation separated. Risk: "unknown" hides actionable errors. Modification: keep details in debug logs only.
- [X] T012 Update `lib/widgets/sync_status_banner.dart`. Why: banner is user-facing. Expected: message, retry action, and optional last-attempt state. Risk: confusing text or permanent alarm. Modification: hide after success.
- [X] T013 Update transaction row chip in Home/Expenses widgets. Why: row-level Pending should be clear and not noisy. Expected: pending/syncing/failed/synced display policy. Risk: every normal save looks broken. Modification: show chip only when useful.
- [ ] T014 Add Home widget tests in `test/home/`. Why: screenshots show Home confusion. Expected: no banner after success; reason banner on failure. Risk: UI regression in Arabic/RTL. Modification: include Arabic locale test.

## Phase 5: User Story 3 - Clean Normal Finance UI (P2)

**Independent Test**: Successful sync leaves no persistent warning.

- [X] T015 Add transient syncing policy. Why: short normal sync should not scare users. Expected: optional subtle state only while active, no persistent warning after success. Risk: hiding genuine issues. Modification: threshold only for acknowledged success path.
- [X] T016 Add manual retry action. Why: user needs control when server/auth/network recovers. Expected: retry calls coordinator once and updates state. Risk: user trapped with pending row. Modification: throttle repeated taps.
- [ ] T017 Add queue persistence/restart test. Why: offline-first must survive closing the app. Expected: pending item retries on next launch. Risk: local save disappears or never syncs. Modification: cover app resume/start path.

## Phase 6: Server Idempotency And Privacy

- [X] T018 Add server duplicate retry test in `server/tests/integration/syncConflict.test.ts`. Why: retry safety prevents duplicate expenses. Expected: same client change id is idempotent. Risk: retry creates repeated transactions. Modification: enforce user-scope and entity id.
- [ ] T019 Audit logs in `server/src/observability/` and Flutter debug logging. Why: sync diagnostics must not leak tokens or descriptions. Expected: privacy-safe status logs. Risk: sensitive data in VPS logs. Modification: redact raw payload text.

## Phase 7: Verification

- [X] T020 Run `flutter gen-l10n`. Why: sync copy changed. Expected: generated localization updates. Risk: stale generated code. Modification: commit generated files.
- [ ] T021 Run targeted sync/Home tests. Why: pending behavior is stateful. Expected: passing coordinator and widget tests. Risk: online saves still linger. Modification: fix before build.
- [X] T022 Run server tests if idempotency changed. Why: retry correctness spans backend. Expected: no server regressions. Risk: data duplication. Modification: update schema/service safely.
- [ ] T023 Perform real-device VPS smoke after build. Why: emulator/unit tests cannot prove actual network/auth timing. Expected: Pending clears or explains cause. Risk: production pilot sees same issue. Modification: collect screenshot/log if failed.

Verification notes:
- Parent fixed the ack path to prefer `clientChangeId` over `entityId` and mark
  unacknowledged queue items as server failures instead of leaving them syncing.
- Parent ran server typecheck and `server/tests/integration/syncConflict.test.ts`
  successfully after adding the client-change-id assertion.
- Parent ran `flutter gen-l10n` successfully.
- `flutter test --no-pub test/api/sync_coordinator_test.dart` timed out after
  180 seconds due the local Flutter/Git hang seen earlier, so T021 remains open.

## Dependencies

- T004-T006 block UI changes.
- T007-T010 block pending clear behavior.
- T018 should be complete before broad retry rollout.

## MVP Scope

Complete T001-T014 first. That should explain and clear the current user-visible Pending problem.
