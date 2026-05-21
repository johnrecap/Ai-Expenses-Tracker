# Tasks: App Protection

## Implementation Intent

Add optional app lock with PIN and biometrics. Security-sensitive data must use secure storage and never store plain PIN values.

---

## Phase 1: Dependencies And Services

### T001 - Add Security Packages

**Status:** Done.

**Files:** Modified `pubspec.yaml` and refreshed `pubspec.lock`.

**Steps:** Add `local_auth`, `flutter_secure_storage`, and `crypto`; run `flutter pub get`.

**Done When:** Packages resolve.

### T002 - Create `PinService`

**Status:** Done.

**Files:** Created `lib/security/pin_service.dart`.

**Steps:** Generate salt, hash PIN, store hash/salt in secure storage, verify entered PIN.

**Done When:** Plain PIN is never persisted.

### T003 - Create `BiometricService`

**Status:** Done.

**Files:** Created `lib/security/biometric_service.dart`.

**Steps:** Check availability, supported biometrics, authenticate with localized reason.

**Done When:** App can request biometric auth safely.

### T004 - Create `AppLockService`

**Status:** Done.

**Files:** Created `lib/security/app_lock_service.dart` and barrel export `lib/security/security.dart`.

**Steps:** Read settings, determine if app should lock on start/resume, coordinate PIN/biometric services.

**Done When:** Lock decision is centralized.

---

## Phase 2: State

### T005 - Create `AppLockCubit`

**Status:** Done.

**Files:** Created `lib/screens/app_lock/cubit/app_lock_cubit.dart` and `lib/screens/app_lock/cubit/app_lock_state.dart`.

**Steps:** Handle setup, locked, unlocking, unlocked, failure.

**Done When:** UI can react to lock state.

### T006 - Add Setup/Lock States

**Status:** Done.

**Steps:** Include noPinSet, setupRequired, locked, unlocked; keep failure message.

**Done When:** Every security flow has explicit state.

### T007 - App Resume/Start Logic

**Status:** Done.

**Files:** Modified `lib/screens/auth/views/auth_gate.dart`.

**Steps:** On app start or resume, check settings; if lock enabled, show unlock screen.

**Done When:** Protected app requires unlock.

---

## Phase 3: UI

### T008 - PIN Setup Screen

**Status:** Done.

**Files:** Created `lib/screens/app_lock/views/create_pin_screen.dart`.

**Steps:** Enter PIN, confirm PIN, validate length, save via PinService.

**Done When:** User can enable PIN.

### T009 - Unlock Screen

**Status:** Done.

**Files:** Created `lib/screens/app_lock/views/unlock_screen.dart`.

**Steps:** Enter PIN, verify, show errors; do not reveal stored info.

**Done When:** User can unlock.

### T010 - Security Settings Section

**Status:** Done.

**Files:** Created `lib/screens/settings/widgets/security_settings_section.dart` and modified `lib/screens/settings/views/settings_screen.dart`.

**Steps:** Toggle app lock, change PIN, toggle biometrics if supported.

**Done When:** User controls protection.

### T011 - Biometric Toggle

**Status:** Done.

**Steps:** Only enable if `BiometricService` says supported; save preference.

**Done When:** Unsupported devices do not show broken controls.

### T012 - PIN Fallback

**Status:** Done.

**Steps:** If biometric fails/canceled, keep PIN unlock available.

**Done When:** User is not locked out by biometric failure.

---

## Phase 4: Tests

### T013 - PIN Hash Tests

**Status:** Done.

Verify correct PIN passes, wrong PIN fails, plain PIN is not stored.

**Files:** Created `test/security/pin_service_test.dart`.

### T014 - App Lock State Tests

**Status:** Done.

Test enabled/disabled, unlock success/failure, biometric fallback.

**Files:** Created `test/security/app_lock_cubit_test.dart`.

### T015 - Manual QA

**Status:** Pending manual device validation.

Enable lock, restart app, unlock, test biometric if device supports it.
