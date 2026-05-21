# Research: Guided Product Tour

## Decision: Build A Lightweight Internal Spotlight System

**Rationale**: The app needs a few predictable spotlight steps with tight control over localization, RTL, persistence, and no accidental feature calls. A custom internal layer avoids adding a package for a small focused workflow.

**Alternatives considered**:

- Add a third-party showcase package: deferred unless implementation discovers a strong local fit; package risk is unnecessary for the first version.
- Use simple dialogs only: rejected because the user explicitly requested dim overlay and focused icon/target.

## Decision: Store Versioned Tour State Per User

**Rationale**: Versioning lets future features introduce new guidance without repeatedly showing old steps.

**Alternatives considered**:

- Store only a local shared preference: rejected because signed-in user state should follow account where practical.
- Show tour every install: rejected because it annoys returning users.

## Decision: AI Assistant Is First Step

**Rationale**: AI is the differentiator and the user specifically requested the AI icon focus first.

**Alternatives considered**:

- Start with Add Expense: rejected because manual entry can be second while AI remains primary differentiation.
- Start with a full onboarding page: rejected because the requested experience is in-context guidance.

## Decision: Steps Must Be Safe And Non-Operational

**Rationale**: The tour should teach without creating expenses, consuming AI quota, displaying ads, starting purchases, or asking permissions.

**Alternatives considered**:

- Interactive demo that sends example AI text: rejected because it can consume quota and fail externally.
- Trigger notification permission during tour: rejected because permissions belong to explicit setup or Settings.

