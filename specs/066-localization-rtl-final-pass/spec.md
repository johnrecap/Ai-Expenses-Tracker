# Feature Specification: Localization RTL Final Pass

**Feature Branch**: `066-localization-rtl-final-pass`  
**Created**: 2026-05-20  
**Status**: Draft  
**Input**: User requested a complete Spec Kit plan for finishing Arabic/English localization, RTL, keyboard, and Arabic PDF QA.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Arabic UI Feels Native (Priority: P1)

As an Arabic user, I need every app-owned label, button, error, empty state, and setting to appear in Arabic with correct RTL layout.

**Why this priority**: Mixed Arabic/English app-owned UI makes the app feel unfinished.

**Independent Test**: A tester switches to Arabic and checks all primary screens on a small Android viewport.

**Acceptance Scenarios**:

1. **Given** Arabic language is selected, **When** the user opens core screens, **Then** app-owned copy is Arabic and layout direction is RTL.
2. **Given** long Arabic text, **When** it appears in buttons/cards/list rows, **Then** it does not overflow or overlap.

---

### User Story 2 - Keyboard And Forms Are Safe (Priority: P1)

As a daily user, I need Add Expense, AI input, search, account, settings, and export forms to remain usable when the keyboard is open.

**Why this priority**: The most common journeys use text input.

**Independent Test**: Open each form in Arabic on a small screen with the keyboard open and complete the main action.

**Acceptance Scenarios**:

1. **Given** keyboard is open on Add Expense, **When** the user fills fields, **Then** save controls remain reachable.
2. **Given** Arabic AI input, **When** suggestions or errors appear, **Then** they do not cover the input action path.

---

### User Story 3 - Arabic Export Is Professional (Priority: P2)

As an Arabic user exporting data, I need PDF output to show Arabic, English, dates, amounts, and mixed currencies correctly.

**Why this priority**: Broken Arabic PDF output damages professional trust.

**Independent Test**: Generate PDF with Arabic descriptions, English merchant text, and mixed currencies; inspect the file visually.

**Acceptance Scenarios**:

1. **Given** Arabic expense data, **When** PDF is exported, **Then** Arabic text renders correctly.
2. **Given** mixed Arabic/English rows, **When** PDF is opened, **Then** columns remain readable and aligned.

## Edge Cases

- Long Arabic category names.
- Mixed Arabic and English descriptions.
- Eastern/Western Arabic numerals.
- Keyboard covers bottom controls.
- Small screen plus large text size.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: All app-owned strings in primary screens MUST use ARB localization.
- **FR-002**: RTL layouts MUST not overflow, overlap, or hide primary actions on small screens.
- **FR-003**: Keyboard-open forms MUST keep required actions reachable.
- **FR-004**: Arabic PDF export MUST be visually inspected with real mixed-language data.
- **FR-005**: Provider/user/generated data MUST not be translated as app-owned copy.
- **FR-006**: Tests SHOULD cover representative English and Arabic widget states.

### Key Entities

- **LocalizationAuditItem**: File/screen/string status with owner and pass/fail notes.
- **RtlQaScenario**: Screen, viewport, keyboard state, locale, and result.
- **PdfVisualQaResult**: Export fixture and visual inspection result.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of primary app-owned UI strings are localized or intentionally classified as data/provider/debug.
- **SC-002**: No P1 screen has Arabic overflow on the selected small Android viewport.
- **SC-003**: Add Expense and AI input can be completed in Arabic with keyboard open.
- **SC-004**: Arabic PDF visual inspection has recorded pass/fail evidence.

## Assumptions

- Arabic and English remain the supported locales for this pass.
- Manual QA is required for final RTL and PDF confidence.

