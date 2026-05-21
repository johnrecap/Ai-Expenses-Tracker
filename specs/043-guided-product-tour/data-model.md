# Data Model: Guided Product Tour

## GuidedTourState

Persisted user-scoped tour status.

Fields:

- `currentVersion`: integer constant for the tour definition.
- `completedVersion`: highest tour version fully completed.
- `skippedVersion`: highest tour version skipped.
- `lastStepId`: optional last active step for resume/replay.
- `updatedAt`: timestamp.

Rules:

- Auto-show if `completedVersion < currentVersion` and `skippedVersion < currentVersion` and onboarding is complete.
- Replay from Settings ignores completed/skipped state for the current session only.

## GuidedTourStep

Static definition of one tour step.

Fields:

- `stepId`: stable id such as `ai_assistant`, `manual_expense`, `ai_preview`, `budget`, `reports`, `categories`, `settings`, `free_premium`.
- `targetId`: stable target registration id.
- `titleKey`: localization key.
- `bodyKey`: localization key.
- `placement`: preferred tooltip/card placement.
- `canSkipIfMissing`: boolean.

Rules:

- Steps must not call domain actions directly.
- Missing targets skip/defer instead of crashing.
- Plan 048 removed the unused `routeName` and `allowTargetTap` fields. Target
  preparation now happens through runtime spotlight registration and
  `Scrollable.ensureVisible`; overlay taps remain absorbed and do not trigger
  target actions.

## SpotlightTarget

Runtime registration for a visible widget.

Fields:

- `targetId`: stable id.
- `context`: widget build context for locating bounds.
- `shape`: circle, rounded rectangle, or custom.
- `padding`: visual padding around target.

Rules:

- Target registration must be removed when widget disposes.
- Bounds must be recalculated on layout changes.

## TourOverlayState

Presentation state.

Fields:

- `activeStep`: current step.
- `targetRect`: measured highlight bounds.
- `isTargetAvailable`: boolean.
- `isReducedMotion`: boolean.
- `direction`: LTR or RTL from app locale.

Rules:

- Overlay must have Skip/Next/Back/Done controls.
- Android back button closes or steps back safely.
