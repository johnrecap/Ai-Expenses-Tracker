# Implementation Plan: App Protection

## Technical Context

App lock is optional and user-controlled. PIN must be stored securely.

## Architecture

Use secure storage for PIN hash and local auth for biometrics. Gate the app with unlock screen on launch/resume.

## Files

- Modify: `pubspec.yaml`
- Create: `lib/security/app_lock_service.dart`
- Create: `lib/security/pin_service.dart`
- Create: `lib/security/biometric_service.dart`
- Create: `lib/screens/app_lock/cubit/app_lock_cubit.dart`
- Create: `lib/screens/app_lock/views/create_pin_screen.dart`
- Create: `lib/screens/app_lock/views/unlock_screen.dart`
- Create: `lib/screens/settings/widgets/security_settings_section.dart`

## Data Model

Security settings: app lock enabled, biometric enabled, lock timeout.

## Risks

- Biometric support differs by platform/device.
- Never store plain PIN.

## Verification

- PIN hashing tests.
- App lock state transition tests.
- Manual biometric fallback test.

## Detailed Execution Guidance

- Implement PIN service and tests before UI.
- Use secure storage for secrets and hashes.
- Biometric unlock is additive; PIN is the reliable fallback.
- App lock should be optional and user-controlled.
- Lifecycle handling should be tested manually because platform behavior varies.
