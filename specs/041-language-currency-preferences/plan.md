# Implementation Plan: Language And Currency Preferences

**Branch**: `041-language-currency-preferences` | **Date**: 2026-05-18 | **Spec**: `specs/041-language-currency-preferences/spec.md`  
**Input**: Feature specification from `specs/041-language-currency-preferences/spec.md`

## Summary

Add explicit user language preference and make currency preference fully independent. The implementation should extend existing settings models/repositories, wire app localization to settings, propagate locale through AI and voice services, and remove risky silent fallbacks in expense creation paths.

## Technical Context

**Language/Version**: Dart 3.x, Flutter  
**Primary Dependencies**: Flutter Bloc, `flutter_localizations`, `intl`, Firebase repository package, existing AI/voice services  
**Storage**: Firestore user settings document at `users/{userId}/settings/profile` through `SettingsRepository`  
**Testing**: `flutter analyze`, targeted settings/AI tests, full Flutter tests if app-root localization changes are broad  
**Target Platform**: Flutter mobile app with Android priority and existing multi-platform folders  
**Project Type**: Mobile-first Flutter app with shared package repository  
**Performance Goals**: App locale changes should rebuild visible UI without adding startup blocking network calls beyond existing settings load  
**Constraints**: Do not infer currency from language; do not infer language from currency; keep manual finance usable if AI is unavailable  
**Scale/Scope**: One settings profile per authenticated user, two current app languages, existing supported currency list plus user-supported currencies

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- Speckit workflow is used before implementation.
- Existing Bloc/Cubit and repository boundaries remain intact.
- Settings stay behind `SettingsRepository`; widgets do not write Firestore directly.
- AI provider keys remain outside Flutter; only locale/context metadata changes.
- New user-facing strings must use ARB localization files.
- Verification must include analyzer and focused tests.

**Gate Status**: PASS. The plan extends existing settings/localization patterns and does not introduce new architecture.

## Project Structure

### Documentation (this feature)

```text
specs/041-language-currency-preferences/
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
packages/expense_repository/lib/src/models/user_settings.dart
packages/expense_repository/lib/src/entities/user_settings_entity.dart
packages/expense_repository/lib/src/firebase_settings_repo.dart
packages/expense_repository/lib/src/settings_repo.dart
lib/app_view.dart
lib/screens/settings/
lib/ai/services/
lib/ai/voice/
lib/screens/ai_assistant/
lib/l10n/
test/settings/
test/ai/
test/repository/
```

**Structure Decision**: Keep preference persistence in the repository package, app locale wiring at the app root, settings UI under `lib/screens/settings`, and AI/voice locale propagation under existing AI service abstractions.

## Phase 0: Research

See `research.md`.

## Phase 1: Design

See `data-model.md` and `quickstart.md`.

## Risk Notes

- App-root locale wiring can create provider ordering issues because `MaterialApp` currently sits above authenticated repository providers. Mitigation: choose a settings bootstrap/state approach that handles unauthenticated and authenticated states clearly.
- Settings migration must not erase existing documents. Mitigation: make `languagePreference` default during entity parsing and only persist when settings are saved.
- Hardcoded locale values exist in AI gateway client and voice controller setup. Mitigation: introduce a single locale source in `AiContext` and pass it through all AI endpoints.
- Removing fallbacks too aggressively can block manual entry. Mitigation: block only saves that depend on missing settings; allow explicit user-provided currency/payment values.

## Deferred Items To Keep In Mind

Relevant existing deferred items from `docs/implementation_plans/deferred-and-advanced-work.md`:

- Broad localization/RTL QA remains a later manual pass.
- AI real-device QA with real `AI_GATEWAY_URL` remains external.
- Currency conversion remains deferred; mixed-currency totals stay conservative.

## Complexity Tracking

No constitution violations.

