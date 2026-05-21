# Research: Spec Cleanup, Navigation Tests, And Deferred Backlog Alignment

## Decision: Treat Historical Specs As Audit Records, Not Disposable Files

**Rationale**: The project has many completed features and overlapping later plans. Deleting old unchecked tasks would remove useful context, while leaving them untouched creates confusion. Annotating them with completion, supersession, or blocker notes preserves history and improves future planning.

**Alternatives considered**:

- Delete old completed task files: rejected because it removes traceability.
- Mark all overlapping tasks complete automatically: rejected because partial/manual QA tasks may still be real.
- Ignore old specs: rejected because it keeps generating duplicate future plans.

## Decision: Add Tests Before Fixing Home/Settings Behavior

**Rationale**: Home and Settings have many providers and feature entry points. Tests should identify whether current wiring works before implementation changes are made. If tests reveal a real route/provider bug, the code fix should be small and linked to the failing test.

**Alternatives considered**:

- Manual-only QA: rejected because repeated regressions need automated coverage.
- Full end-to-end app tests: rejected for this scope because Firebase/plugin/device dependencies would slow or block local verification.

## Decision: Keep Deferred Backlog As The Persistent Source For Later-Stage Work

**Rationale**: `AGENTS.md` now instructs future work to read and update the deferred file automatically. This plan should strengthen that practice by ensuring the current three corrections are present and precise.

**Alternatives considered**:

- Put all future notes only in each `tasks.md`: rejected because future workers need a single persistent backlog.
- Put deferred notes only in final chat responses: rejected because chat context is not durable enough.

## Decision: Do Not Add Release/Device QA To Local Implementation Scope

**Rationale**: The requested three items are local planning, docs, and test coverage. Device QA, Firebase deploy, AdMob production IDs, keystore, and store release are already deferred and require external setup.

**Alternatives considered**:

- Include release build as part of this plan: rejected because no keystore/build intent was requested.
- Include Android device QA as mandatory: rejected because this plan is meant to prepare the project before that later stage.
