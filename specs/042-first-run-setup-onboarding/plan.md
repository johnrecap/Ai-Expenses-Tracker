# Implementation Plan: First-Run Setup Onboarding

**Branch**: `042-first-run-setup-onboarding` | **Date**: 2026-05-18 | **Spec**: `specs/042-first-run-setup-onboarding/spec.md`  
**Input**: Feature specification from `specs/042-first-run-setup-onboarding/spec.md`

## Summary

Add a first-run setup flow after authentication and before Home so users explicitly choose language, base currency, and default payment method. The flow also introduces AI safety/limits and optional reminders without calling provider or ad services.

## Technical Context

**Language/Version**: Dart 3.x, Flutter  
**Primary Dependencies**: Flutter Bloc, existing AuthBloc/AuthGate, SettingsRepository, NotificationScheduler abstractions, l10n  
**Storage**: User settings profile under `users/{userId}/settings/profile`; optional local draft state only if needed  
**Testing**: `flutter analyze`, onboarding widget tests, auth routing tests, settings repository/entity tests  
**Target Platform**: Flutter mobile app with Android priority  
**Project Type**: Mobile app with repository package  
**Performance Goals**: Setup screens should render quickly and not block on AI/ad/purchase initialization  
**Constraints**: No silent EGP/Cash defaults; no AI quota consumption; notification setup is optional  
**Scale/Scope**: One onboarding completion state per authenticated user, current app languages/currencies from Plan 041

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- Speckit workflow is used before implementation.
- Auth routing remains owned by AuthBloc/AuthGate and repository providers.
- Settings persistence remains behind SettingsRepository.
- Notification plugin calls stay behind notification service/scheduler abstractions.
- New strings use l10n resources.
- Verification must include analyzer and relevant tests.

**Gate Status**: PASS. The plan adds a routing/setup layer without bypassing repositories.

## Project Structure

### Documentation (this feature)

```text
specs/042-first-run-setup-onboarding/
|-- spec.md
|-- plan.md
|-- research.md
|-- data-model.md
|-- quickstart.md
|-- checklists/
|   `-- requirements.md
`-- tasks.md
```

### Source Code Targets

```text
lib/screens/auth/views/auth_gate.dart
lib/screens/onboarding/
lib/screens/settings/blocs/settings_bloc/
lib/services/notifications/
lib/l10n/
packages/expense_repository/lib/src/models/user_settings.dart
packages/expense_repository/lib/src/entities/user_settings_entity.dart
test/onboarding/
test/auth/
test/settings/
```

**Structure Decision**: Add a new `lib/screens/onboarding/` feature area with Cubit/state/widgets, while using existing AuthGate and SettingsRepository as boundaries.

## Phase 0: Research

See `research.md`.

## Phase 1: Design

See `data-model.md` and `quickstart.md`.

## Risk Notes

- Onboarding can accidentally block existing users. Mitigation: only require setup when completion flag is missing and required fields are absent or invalid.
- Notification permission prompts can disrupt setup. Mitigation: ask permission only after explicit opt-in and keep denial non-blocking.
- Saving partial onboarding state can create confusing behavior. Mitigation: persist completion only after required choices validate and save successfully.
- Routing after auth can become complex. Mitigation: keep an explicit setup gate with simple loading/success/failure states.

## Deferred Items To Keep In Mind

Relevant existing deferred items from `docs/implementation_plans/deferred-and-advanced-work.md`:

- First real-user feedback should refine onboarding wording and step count later.
- Full Arabic RTL visual QA remains manual and deferred.
- Store readiness and production-device QA remain external.

## Complexity Tracking

No constitution violations.

