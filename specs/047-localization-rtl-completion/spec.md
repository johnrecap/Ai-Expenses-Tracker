# Feature Specification: Localization And RTL Completion

**Feature Branch**: `047-localization-rtl-completion`  
**Created**: 2026-05-18  
**Status**: Draft  
**Input**: Review finding that many screens still contain hardcoded English strings and Arabic RTL coverage remains incomplete.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Core Finance Screens Are Localized (Priority: P1)

Arabic and English users must see localized labels, empty states, errors, buttons, and filters across core finance flows.

**Why this priority**: Manual expense tracking must be usable for Arabic users before launch.

**Independent Test**: Add Expense, Expenses/filter, Categories, Recurring, Reports, Saving Goals, Export, and Settings smoke tests can render in English and Arabic without hardcoded app-owned English labels.

**Acceptance Scenarios**:

1. **Given** the app locale is Arabic, **When** a user opens core finance screens, **Then** app-owned UI text appears in Arabic and layout direction is RTL.
2. **Given** the app locale is English, **When** the same screens are opened, **Then** app-owned UI text appears in English and layout direction is LTR.

---

### User Story 2 - AI And Monetization Surfaces Are Localized (Priority: P2)

AI Assistant, quota, Free/Premium, ads consent-facing copy, and purchase-disabled placeholders must use the same l10n system as the rest of the app.

**Why this priority**: AI and monetization are high-trust areas and inconsistent language weakens confidence.

**Independent Test**: AI Assistant and Free/Premium widget tests render localized labels and do not rely on hardcoded English finders.

**Acceptance Scenarios**:

1. **Given** Arabic locale, **When** a user opens AI Assistant, **Then** input hints, preview labels, error messages, and confirmation copy are Arabic except user/provider content.
2. **Given** Arabic locale, **When** a user opens Free/Premium screens, **Then** plan labels and CTA copy are Arabic.

---

### User Story 3 - Manual RTL QA Is Documented And Repeatable (Priority: P3)

Manual QA must verify Arabic layout on a small Android viewport with keyboard open and mixed Arabic/English data.

**Why this priority**: Automated widget tests do not catch all text overflow, keyboard, and directionality issues.

**Independent Test**: A QA checklist exists with concrete screens, sample data, viewport, and expected observations.

**Acceptance Scenarios**:

1. **Given** a tester has an Android device or emulator, **When** they follow the checklist, **Then** they cover all localized high-risk screens.
2. **Given** Arabic export is generated, **When** the PDF is inspected, **Then** Arabic and mixed rows are readable and aligned.

## Edge Cases

- User-generated content such as category names, descriptions, notes, and receipt text must not be translated.
- Provider or backend error codes should be mapped to safe localized app messages where displayed.
- Arabic text may expand and overflow buttons or cards.
- Mixed currency/code values should remain readable in RTL.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: All new app-owned strings must live in `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb`.
- **FR-002**: Hardcoded app-owned strings must be removed from the targeted screens.
- **FR-003**: User-generated strings must remain unchanged.
- **FR-004**: `flutter gen-l10n` must regenerate localization files after ARB edits.
- **FR-005**: Widget tests must cover representative English and Arabic rendering for high-risk screens.
- **FR-006**: Manual RTL QA checklist must include small viewport, keyboard-open, and mixed Arabic/English data.
- **FR-007**: PDF export Arabic visual inspection must remain tracked if not completed locally.

### Key Entities

- **Localization Key**: Named string entry in ARB files.
- **Localized Surface**: Screen/widget where app-owned text is sourced from generated l10n.
- **Manual RTL Checklist**: Human-verification checklist for layout issues not caught by tests.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Targeted hardcoded-string search count is reduced for core app-owned strings in selected screens.
- **SC-002**: `flutter gen-l10n` completes after ARB updates.
- **SC-003**: At least four representative localized widget tests pass or produce clear failures.
- **SC-004**: Manual RTL QA checklist exists with at least ten concrete checks.

## Assumptions

- This pass focuses on app-owned copy, not user data or provider raw content.
- Full real-device Arabic QA remains deferred until device access is available.
- Plan 036 remains historical context; this plan is the current executable localization completion pass.
