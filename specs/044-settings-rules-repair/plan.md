# Implementation Plan: Settings Rules Repair

**Branch**: `044-settings-rules-repair` | **Date**: 2026-05-18 | **Spec**: `specs/044-settings-rules-repair/spec.md`  
**Input**: Review finding that Firestore settings rules reject current `UserSettingsEntity` fields.

## Summary

Bring Firestore `validSettings` into sync with the current settings entity, update rules tests so they use the current profile schema, and make the rules verification command explicit.

## Technical Context

**Language/Version**: Firebase Security Rules v2, TypeScript rules tests, Dart entity context  
**Primary Dependencies**: Firebase emulator/rules-unit-testing, existing `functions` test setup  
**Storage**: Firestore `users/{userId}/settings/profile`  
**Testing**: `npm test`, `npm run test:rules`, `flutter analyze --no-pub` for app context if touched  
**Target Platform**: Firebase backend used by Flutter clients  
**Project Type**: Mobile app with Firebase backend rules  
**Performance Goals**: No runtime impact; rules remain simple bounded predicates  
**Constraints**: Preserve user isolation; do not loosen settings validation broadly; keep app defaults backward-compatible  
**Scale/Scope**: `firestore.rules`, `functions/test/firestoreRules.rules.ts`, `functions/package.json`, docs if needed

## Constitution Check

*GATE: Must pass before implementation.*

- Firestore data remains user-scoped under `users/{userId}`.
- Widgets and app code must not write settings directly outside `SettingsRepository`.
- Rules changes require emulator tests.
- AI, ads, purchases, and local auth are not involved.

**Gate Status**: PASS.

## Project Structure

### Documentation (this feature)

```text
specs/044-settings-rules-repair/
|-- spec.md
|-- plan.md
|-- tasks.md
`-- checklists/
    `-- requirements.md
```

### Source Code Targets

```text
firestore.rules
functions/test/firestoreRules.rules.ts
functions/package.json
docs/firebase/ or README.md
packages/expense_repository/lib/src/entities/user_settings_entity.dart
```

**Structure Decision**: Rules remain at repo root. Rules tests stay in `functions/test` because that is the current rules-unit-testing setup. The Dart entity is reference context only unless implementation reveals a mapper bug.

## Implementation Notes

- Add a `validLanguagePreference(value)` helper in `firestore.rules`.
- Expand `validSettings(data, userId)` `hasOnly` and `hasAll` lists to include `languagePreference`, `onboardingCompleted`, `onboardingVersion`, `guidedTourCompletedVersion`, `guidedTourSkippedVersion`, and `guidedTourLastStepId`.
- Validate `guidedTourLastStepId` with `optionalString(data, 'guidedTourLastStepId')`.
- Validate version fields with `nonNegativeInt`.
- Preserve existing validation for currencies, payment method, notification settings, and `updatedAt`.
- Update the TypeScript `validSettings()` fixture to match `UserSettingsEntity.toDocument()`.
- Add negative tests for invalid new settings fields.
- Decide whether to add an aggregate script such as `test:all` only if it does not require unavailable emulators for normal `npm test`.

## Verification

```text
cd functions
npm test
npm run test:rules
cd ..
flutter analyze --no-pub
```

If `npm run test:rules` fails because Firebase emulator tooling is unavailable, record the exact missing prerequisite and keep the app-safe unit tests separate.

## Deferred Items To Keep In Mind

From `docs/implementation_plans/deferred-and-advanced-work.md`: deploying Firestore rules/indexes and running a real Firebase smoke test with a real user remain production setup blockers and are not part of this local repair.

## Complexity Tracking

No constitution violations.
