# Implementation Plan: Guided Product Tour

**Branch**: `043-guided-product-tour` | **Date**: 2026-05-18 | **Spec**: `specs/043-guided-product-tour/spec.md`  
**Input**: Feature specification from `specs/043-guided-product-tour/spec.md`

## Summary

Add a replayable first-use guided tour with spotlight overlays. The first step highlights AI Assistant, then teaches manual entry, AI preview confirmation, budgets, reports, categories, settings, and Free/Premium behavior without calling AI/ad/purchase/permission services.

## Technical Context

**Language/Version**: Dart 3.x, Flutter  
**Primary Dependencies**: Flutter widgets, Flutter Bloc/Cubit, existing SettingsRepository/UserSettings, l10n  
**Storage**: User settings profile or small user-scoped preference model for tour completion/skipped version  
**Testing**: `flutter analyze`, guided tour widget tests, Home/Settings tests, full suite if navigation wrappers change  
**Target Platform**: Flutter mobile app with Android priority  
**Project Type**: Mobile app UI feature  
**Performance Goals**: Overlay appears within 2 seconds after Home is ready and animations remain light  
**Constraints**: No provider calls, no quota use, no ads, no purchase flow, no permission prompts from tour steps  
**Scale/Scope**: One guided tour version for current core features, replay from Settings, versioned future updates

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- Speckit workflow is used before implementation.
- State is managed with Cubit/Bloc and repository boundaries.
- Settings remain behind SettingsRepository.
- UI strings use l10n.
- AI safety rule is preserved: tour never triggers AI mutations.
- Verification includes analyzer and relevant widget tests.

**Gate Status**: PASS. The plan is UI/state guidance and does not bypass domain services.

## Project Structure

### Documentation (this feature)

```text
specs/043-guided-product-tour/
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
lib/guided_tour/
lib/screens/home/views/main_screen.dart
lib/screens/ai_assistant/
lib/screens/settings/
lib/l10n/
packages/expense_repository/lib/src/models/user_settings.dart
packages/expense_repository/lib/src/entities/user_settings_entity.dart
test/guided_tour/
test/home/
test/settings/
```

**Structure Decision**: Add reusable guided-tour infrastructure under `lib/guided_tour/`, register targets from feature screens, and persist state through user settings or a user-scoped settings sub-model.

## Phase 0: Research

See `research.md`.

## Phase 1: Design

See `data-model.md` and `quickstart.md`.

## Risk Notes

- Overlay target registration can break with scrollable screens. Mitigation: allow steps to request route/scroll preparation and skip unavailable targets safely.
- Guidance can annoy returning users. Mitigation: persist versioned completion/skipped state and provide replay from Settings.
- Animations can distract or reduce accessibility. Mitigation: include reduced-motion mode and keep pulse subtle.
- Tour could accidentally trigger feature actions. Mitigation: separate "spotlight target" from actual tap behavior unless the step explicitly allows navigation.

## Deferred Items To Keep In Mind

Relevant existing deferred items from `docs/implementation_plans/deferred-and-advanced-work.md`:

- First real-user feedback should refine onboarding and tour copy.
- Full Arabic RTL visual QA remains manual and deferred.
- Feature flag wiring for guided tour can be added later through the observability/remote-config backlog.

## Complexity Tracking

No constitution violations.

