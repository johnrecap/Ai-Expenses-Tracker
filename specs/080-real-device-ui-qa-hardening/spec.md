# Feature Specification: Real Device UI QA Hardening

**Feature Branch**: `080-real-device-ui-qa-hardening`  
**Created**: 2026-05-20  
**Status**: Draft  
**Input**: Review and user screenshots showed UI risks that automated widget tests may not fully catch: Settings scroll, Add Expense keyboard layout, Arabic/English switching, and small-screen finance cards.

## User Scenarios & Testing

### User Story 1 - Settings scroll ends cleanly on real devices (Priority: P1)

As a user, I want Settings to stop at the last real section instead of scrolling into a blank area, so the screen feels stable and complete.

**Why this priority**: The user specifically observed excessive blank scroll area in Settings.

**Independent Test**: On a small Android viewport, scroll Settings to the bottom in English and Arabic. The last visible content is Support/Privacy/expected final section near the bottom, with no large empty region.

### User Story 2 - Add Expense works with keyboard open (Priority: P1)

As a daily user, I want Add Expense, AI fill, and manual fields to remain usable when the keyboard is open, so recording expenses stays fast.

**Why this priority**: Add Expense is the app's most repeated workflow.

**Independent Test**: Open Add Expense, focus manual amount and AI natural-language input on small viewport, type Arabic and English text, and verify no important buttons/fields are hidden without scroll access.

### User Story 3 - Language changes update visible screens immediately (Priority: P2)

As a bilingual user, I want switching between Arabic and English to update visible labels immediately, so I do not need to restart the app.

**Why this priority**: The user previously saw text that only changed after app restart.

**Independent Test**: Change language in Settings and verify visible labels, current route text, and subsequent navigation reflect the new language without restart.

### User Story 4 - Finance cards fit real data (Priority: P2)

As a user with long names, mixed currencies, and Arabic text, I want Home, Reports, Budget, and transaction rows to fit without overlap.

**Why this priority**: Finance cards are the user's primary trust surface.

**Independent Test**: Use seeded data with long category names, large amounts, mixed currencies, and Arabic descriptions on a small viewport. No text overlaps amounts or navigation controls.

## Requirements

- **FR-001**: Settings MUST avoid large blank bottom scroll after the final section on supported mobile viewports.
- **FR-002**: Add Expense MUST keep Save, amount, category, AI input, receipt failure, and settings-load warning reachable with keyboard open.
- **FR-003**: Language changes MUST update visible labels immediately for Settings and newly opened routes.
- **FR-004**: Home, Reports, Budget, and Transactions MUST not overlap text and amounts with long Arabic/English content.
- **FR-005**: Manual QA steps MUST be documented with exact viewport/device assumptions and expected screenshots.
- **FR-006**: Widget tests SHOULD cover the deterministic parts; real-device manual QA remains required for keyboard/PDF/OS behavior.

## Key Entities

- **ViewportScenario**: Screen size, locale, keyboard state, and data fixture.
- **UISurfaceCheck**: A repeatable check for scroll, overlap, keyboard access, or language refresh.
- **ManualQAEvidence**: Screenshot/log note proving a scenario was checked.

## Success Criteria

- **SC-001**: Settings bottom-scroll widget test passes and manual small-device check shows no large blank area.
- **SC-002**: Add Expense keyboard-open checklist passes for manual, AI, and receipt states.
- **SC-003**: Language switch widget tests pass for Settings and at least one secondary route.
- **SC-004**: Real-device QA notes document pass/fail status for each target surface.

## Assumptions

- This plan can use debug/internal builds for visual QA, but release build is only required when the user asks.
- It focuses on UI behavior, not changing financial calculations.

