# Tasks: Production Readiness Gate

**Input**: `specs/064-production-readiness-gate/spec.md`, `plan.md`

## Phase 1: Release Gate Foundation

- [X] T001 Audit `docs/qa/production-device-qa.md`, `docs/release/play-store-checklist.md`, `docs/release/android-release.md`, `docs/ai/production-ai-setup.md`, and `docs/monetization/manual-qa.md`.
  - **Why**: Release readiness is currently split across multiple docs.
  - **Benefit**: Prevents missing a blocker because it was hidden in another file.
  - **Expected**: A list of duplicate, missing, and conflicting release checks.

- [X] T002 Create or update `docs/release/internal-release-gate.md` as the single owner-facing release gate.
  - **Why**: The tester needs one command center before internal testing.
  - **Benefit**: Reduces mistakes during release preparation.
  - **Expected**: Checklist includes environment, artifact, Firebase, AI, ads, account, export, app lock, notifications, and evidence sections.

- [X] T003 Add a blocker matrix to `docs/release/internal-release-gate.md`.
  - **Why**: Some failures must block release while others only limit a feature.
  - **Benefit**: Makes go/no-go decisions explicit.
  - **Expected**: P0 blockers include Firebase/Auth failure, missing AI URL when AI is expected, unintended test ads, unsigned artifact, and failed core finance flow.

## Phase 2: Smoke Journeys

- [X] T004 [US1] Add clean-device install/startup steps to `docs/release/internal-release-gate.md`.
  - **Why**: Startup, onboarding, settings load, and auth gate issues often only appear on clean installs.
  - **Benefit**: Catches first-run failures before users see them.
  - **Expected**: Tester records artifact path, install date, device, Android version, and startup result.

- [X] T005 [US2] Add Firebase Auth smoke scenarios for Google and email/password.
  - **Why**: Both auth methods are supported and can fail differently.
  - **Benefit**: Confirms provider setup and user-owned app state.
  - **Expected**: Login, logout, and re-login evidence for both providers or a documented provider-specific blocker.

- [X] T006 [US2] Add Firestore write smoke scenarios for settings, expenses, categories, budgets, recurring expenses, saving goals, and AI action logs.
  - **Why**: Rules can reject one collection while others pass.
  - **Benefit**: Prevents permission-denied surprises in production.
  - **Expected**: Each user-owned path has a pass/fail result.

- [X] T007 [US3] Add AI gateway readiness checks for `AI_GATEWAY_URL`, Arabic parse, provider failure, quota exhausted, receipt, and advice.
  - **Why**: Mock fallback can hide production AI failures.
  - **Benefit**: Confirms AI is real when release claims AI support.
  - **Expected**: Build without real gateway is labelled internal-only or AI-disabled.

- [X] T008 [US3] Add AdMob readiness checks for app ID, ad unit IDs, consent flow, test-ad state, and Premium no-ad behavior.
  - **Why**: Test IDs must not leak into production unless ads are disabled.
  - **Benefit**: Reduces ad policy and trust risk.
  - **Expected**: Release is blocked if ad config is ambiguous.

## Phase 3: Verification Commands

- [X] T009 Add preflight command references for `flutter analyze --no-pub`, targeted Flutter tests, Worker `npm test`/`npm run typecheck`, and Functions `npm run test:rules`.
  - **Why**: The release gate must point to the right verification command for each subsystem.
  - **Benefit**: Avoids using `npm test` when rules emulator tests are required.
  - **Expected**: Every command has working directory, purpose, and pass/fail field.

- [X] T010 Add a manual sign-off section for external-only tasks.
  - **Why**: Keystore, Firebase deploy, and Play Store policy cannot be proven by local code.
  - **Benefit**: Keeps responsibility explicit.
  - **Expected**: Owner initials/date/evidence links for each external blocker.

## Phase 4: Handoff

- [X] T011 Update `docs/implementation_plans/deferred-and-advanced-work.md` only if a new release blocker is discovered.
  - **Why**: Deferred backlog must stay accurate.
  - **Benefit**: Prevents duplicate or forgotten blockers.
  - **Expected**: New blocker added concisely or no change if already covered.

- [X] T012 Run documentation consistency checks with `rg "AI_GATEWAY_URL|AdMob|test ad|Firebase smoke|release gate" docs specs`.
  - **Why**: Release claims must not contradict each other.
  - **Benefit**: Keeps docs trustworthy.
  - **Expected**: No contradictory release guidance remains.
