# Research: First-Run Setup Onboarding

## Decision: Gate After Authentication, Before Main App

**Rationale**: User-scoped settings require a user id. AuthGate already owns routing from unauthenticated to authenticated app, so setup can sit between auth success and main screen.

**Alternatives considered**:

- Show setup before login: rejected because settings are user-scoped.
- Show setup as dismissible Home banner only: rejected because mandatory preferences must be chosen before saves rely on defaults.

## Decision: Required Setup Fields Are Language, Base Currency, Payment Method

**Rationale**: These are the fields that prevent silent defaults and affect every new expense.

**Alternatives considered**:

- Include budgets/categories in mandatory setup: rejected because it increases friction and can be handled by later guided tour.
- Include Premium/ads consent in mandatory setup: rejected because it is not needed for core finance tracking.

## Decision: AI Intro Is Informational Only

**Rationale**: Users need to understand AI safety and limits, but onboarding must not consume AI quota or depend on provider availability.

**Alternatives considered**:

- Run a real AI example during setup: rejected because it consumes free quota and can fail due to external provider issues.
- Hide AI limits until first use: rejected because free-plan expectations should be transparent.

## Decision: Notification Setup Is Optional

**Rationale**: Reminders help retention, but permission denial must not block core app use.

**Alternatives considered**:

- Force notification permission before Home: rejected because it is hostile and unnecessary.
- Hide reminders until Settings: rejected because first-run setup is the best moment to ask if the user wants help remembering expenses.

