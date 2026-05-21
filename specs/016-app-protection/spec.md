# Feature Specification: App Protection

**Feature Branch**: `016-app-protection`
**Created**: 2026-05-15
**Status**: Draft

## User Scenarios & Testing

### User Story 1 - User Enables PIN Lock (P1)
As a user, I protect the app with a PIN.

**Acceptance Criteria**
- PIN setup requires confirmation.
- PIN is stored as salted hash, not plain text.

### User Story 2 - User Unlocks With Biometrics (P2)
As a user, I unlock with fingerprint or Face ID when available.

**Acceptance Criteria**
- Biometrics can be enabled only when supported.
- PIN fallback is always available.

## Functional Requirements

- Add secure storage.
- Add local auth integration.
- Add app lock Cubit.
- Add create PIN and unlock screens.
- Add security settings section.

## Out Of Scope

- Remote device management.
- Password manager integration.

## Success Metrics

- PIN verification tests pass.
- App locks on launch/resume when enabled.

## Detailed Requirements And Edge Cases

- Plain PIN must never be stored.
- Biometric unlock is optional and device-dependent.
- PIN fallback must always be available.
- Lock must be user-configurable from settings.
- App should not lock users out if biometrics are unavailable after being enabled.
