# Tasks: Premium Entitlement Backend

**Input**: `specs/074-premium-entitlement-backend/spec.md`, `plan.md`

## Phase 1: Benefits And Honest State

- [X] T001 Define Premium benefit matrix in `docs/monetization/premium-verification.md`.
  - **Why**: Users need concrete value before payment.
  - **Benefit**: Reduces confusion around "coming soon".
  - **Expected**: Benefits include approved limits for ads, AI quota, reports, receipts, export templates, and smart budgets.

- [X] T002 Update Free/Premium UI copy to show current purchase readiness honestly.
  - **Why**: UI must not imply a real payment happens before backend verification.
  - **Benefit**: Builds trust and avoids policy risk.
  - **Expected**: Disabled/unavailable state is clear.

## Phase 2: Entitlement Contract

- [X] T003 Design backend entitlement verification contract under `specs/074-premium-entitlement-backend/contracts/`.
  - **Why**: Client and backend need a stable boundary.
  - **Benefit**: Prevents client-only unlocks.
  - **Expected**: Contract covers purchase verify, restore, refresh, expiry, refund, and errors.

- [X] T004 Add `VerifiedEntitlement` and verification result models.
  - **Why**: Current local entitlement snapshot needs server-owned states.
  - **Benefit**: Supports paid launch safely.
  - **Expected**: Models include status, product, expiry, source, and last verified time.

- [X] T005 Add fake backend verification tests.
  - **Why**: Paid states must be covered before real backend work.
  - **Benefit**: Keeps UI/cubit behavior stable.
  - **Expected**: Valid, invalid, expired, refunded, restore, and backend-down cases pass.

## Phase 3: Client Integration

- [X] T006 [US2] Wire entitlement refresh/restore through `MonetizationCubit`.
  - **Why**: Widgets should not own entitlement logic.
  - **Benefit**: Centralizes plan state.
  - **Expected**: Cubit surfaces loading, free, premium, expired, unavailable, and error states.

- [X] T007 [US2] Keep real purchase calls disabled until backend is configured.
  - **Why**: No paid launch without verification.
  - **Benefit**: Prevents insecure purchases.
  - **Expected**: Purchase button remains unavailable or sandbox-only based on config.

- [X] T008 [US3] Add tests proving manual finance flows work when purchases/ads/quota fail.
  - **Why**: Core tracking must remain free and reliable.
  - **Benefit**: Protects app value.
  - **Expected**: Manual expense creation and local reports are not gated.

- [X] T009 [US2] Add tests proving Premium entitlement suppresses all ad placements.
  - **Why**: No ads is a likely Premium benefit.
  - **Benefit**: Prevents accidental ad display to paying users.
  - **Expected**: Ad widgets collapse/hide for Premium fixtures.

## Phase 4: Backend Implementation Decision

- [X] T010 Choose backend implementation path: Cloudflare Worker, Firebase Functions, or other trusted service.
  - **Why**: Real purchase verification cannot live in Flutter.
  - **Benefit**: Defines deployment/security ownership.
  - **Expected**: Decision documented with rationale and secret storage requirements.

- [ ] T011 If backend is in scope, implement verification endpoint and tests in the selected backend folder.
  - **Why**: Paid launch requires server verification.
  - **Benefit**: Enables real entitlement restore.
  - **Expected**: Backend tests cover receipt verification and entitlement response.

## Phase 5: Verification

- [X] T012 Run monetization widget/unit tests.
  - **Why**: Entitlement state affects many UI surfaces.
  - **Benefit**: Confirms plan gates.
  - **Expected**: Targeted tests pass.

- [ ] T013 Run backend tests for the selected verification service if implemented.
  - **Why**: Backend correctness is required for paid launch.
  - **Benefit**: Confirms server-owned entitlements.
  - **Expected**: Backend verification tests pass.

- [X] T014 Run `flutter analyze --no-pub`.
  - **Why**: New models/cubit states can leave stale call sites.
  - **Benefit**: Static safety.
  - **Expected**: No analyzer issues.
