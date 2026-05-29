# Feature Specification: Hardcoded Localization Completion

**Feature Branch**: `088-hardcoded-localization-completion`  
**Created**: 2026-05-27  
**Status**: Draft  
**Input**: User observed many hardcoded strings across the app and wants the app language switch to update every visible text without needing to restart.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - All Static Text Follows Selected Language (Priority: P1)

As an Arabic or English user, I want every static label, button, error, banner, and empty state to switch language immediately when I change app language.

**Why this priority**: Hardcoded language makes the app feel unfinished.

**Independent Test**: Switch from English to Arabic and verify targeted screens update without app restart.

**Acceptance Scenarios**:

1. **Given** the app is in English, **When** the user switches to Arabic, **Then** visible static UI updates to Arabic immediately.
2. **Given** a screen contains generated status copy, **When** language changes, **Then** the copy updates without recreating the account or reinstalling.

---

### User Story 2 - AI, Sync, Finance, and Errors Are Localized (Priority: P1)

As a user, I want AI messages, sync pending text, finance caveats, validation errors, and toasts to be localized, so critical information is understandable.

**Why this priority**: These are high-trust areas; English-only errors are unacceptable.

**Independent Test**: Trigger AI error, missing-rate message, validation error, sync pending state, and verify localized Arabic/English copy.

**Acceptance Scenarios**:

1. **Given** AI quota is exhausted, **When** app language is Arabic, **Then** the quota message is Arabic.
2. **Given** a missing exchange rate blocks conversion, **When** app language is English, **Then** the status is English and precise.
3. **Given** validation fails in Add Expense, **When** app language is Arabic, **Then** the error is Arabic.

---

### User Story 3 - RTL Layout Holds With Long Text (Priority: P2)

As an Arabic user on a small phone, I want translated text to fit without overlap or clipped buttons.

**Why this priority**: Localization without layout QA still looks broken.

**Independent Test**: Run Arabic on a small viewport with keyboard open and verify no overlap in core screens.

**Acceptance Scenarios**:

1. **Given** Arabic language and small screen, **When** the user opens Add Expense, Settings, Home, Reports, and AI, **Then** primary controls remain visible and readable.
2. **Given** Arabic text is longer than English, **When** it appears in cards/buttons, **Then** it wraps or truncates intentionally.

### Edge Cases

- User-generated text such as categories, descriptions, and merchants must not be translated.
- Currency codes remain uppercase Latin codes.
- Mixed Arabic/English rows must remain readable in RTL.
- Generated l10n files must stay consistent with ARB.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: All app-owned static user-facing strings MUST use generated localization.
- **FR-002**: Language changes MUST refresh visible copy without app restart wherever state allows.
- **FR-003**: AI, sync, finance, validation, empty states, settings, auth, monetization, export, and account/profile copy MUST be included in the audit.
- **FR-004**: User-generated content MUST remain unchanged.
- **FR-005**: Arabic and English translations MUST be present for every new key.
- **FR-006**: Core screens MUST receive widget or manual RTL QA coverage.

### Key Entities

- **Localization Key**: ARB entry with English and Arabic values.
- **Hardcoded String Finding**: Static user-facing text not routed through localization.
- **RTL QA Finding**: Layout issue caused or exposed by Arabic/RTL.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Hardcoded string audit reports zero high-priority user-facing hardcoded strings in core screens.
- **SC-002**: Language switch updates visible text in tested screens without app restart.
- **SC-003**: Arabic small-screen QA has no blocking overlap on Home, Add Expense, Reports, Settings, AI, and Expenses.
- **SC-004**: `flutter gen-l10n` and analyzer pass after ARB changes.

## Assumptions

- Full PDF visual QA remains a separate release follow-up unless touched by this plan.
- The first pass prioritizes app-owned strings visible to normal users.
