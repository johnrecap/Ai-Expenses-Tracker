# Feature Specification: Localization And RTL Polish

**Feature Branch**: `030-localization-rtl-polish`  
**Created**: 2026-05-17  
**Status**: Draft  
**Input**: Review found hardcoded English strings, Arabic usage needs, RTL layout risk, and a visible mojibake/separator issue.

## User Scenarios & Testing

### User Story 1 - Arabic UI Reads Correctly (Priority: P1)

An Arabic-speaking user can use core app screens without broken text, mojibake, or layout overlap.

**Why this priority**: The target user is using Arabic input and expects an Arabic-friendly expense tracker.

**Independent Test**: Run the app in Arabic locale and verify Home, Add Expense, Expenses, Stats, Categories, Settings, and AI Assistant.

**Acceptance Scenarios**:

1. **Given** device locale is Arabic, **When** Home opens, **Then** visible labels are Arabic or intentionally localized and layout is RTL-safe.
2. **Given** Expenses screen renders details, **When** category/date/payment separators appear, **Then** they use valid readable punctuation, not mojibake.

---

### User Story 2 - English UI Still Works (Priority: P2)

An English-speaking user keeps the existing app experience with no missing localization keys.

**Why this priority**: Localization must not regress existing English users.

**Independent Test**: Run app in English locale and confirm all localized strings resolve.

**Acceptance Scenarios**:

1. **Given** device locale is English, **When** each core screen opens, **Then** no raw localization keys or missing strings appear.
2. **Given** a validation error appears, **When** locale is English, **Then** the message remains understandable.

---

### User Story 3 - Locale-Sensitive Formatting (Priority: P3)

Dates, amounts, currencies, and AI examples format naturally for the selected locale.

**Why this priority**: The app already uses `intl`; localization should extend formatting consistency.

**Independent Test**: Switch locale fixtures and confirm date/number formatting changes appropriately.

**Acceptance Scenarios**:

1. **Given** Arabic locale, **When** a transaction date renders, **Then** it uses Arabic-friendly date formatting.
2. **Given** currency is EGP, **When** amounts render, **Then** amount and currency display consistently across Home, Expenses, and Reports.

### Edge Cases

- Mixed Arabic and English text may require explicit text direction in input/preview areas.
- Some icon-only buttons need tooltips/semantics in both languages.
- User-generated category names should not be translated automatically.

## Requirements

### Functional Requirements

- **FR-001**: The app MUST use Flutter localization resources for user-facing static strings.
- **FR-002**: Arabic and English MUST be supported at minimum.
- **FR-003**: Core screens MUST be RTL-safe: Home, Add Expense, Expenses, Stats/Reports, Categories, Settings, AI Assistant, Free/Premium.
- **FR-004**: Existing mojibake text such as the bad separator in Expenses MUST be replaced with valid punctuation or localized layout.
- **FR-005**: User-generated values such as category names, descriptions, and notes MUST not be auto-translated.
- **FR-006**: Dates and numbers MUST continue using `intl` and respect selected/device locale.
- **FR-007**: Icon-only controls MUST have localized tooltips or semantic labels where appropriate.

### Key Entities

- **Localization Key**: Stable identifier for a user-facing string.
- **Locale Preference**: Device or future user-selected language setting.
- **RTL-Safe Layout**: UI arrangement that works when text direction is right-to-left.

## Success Criteria

### Measurable Outcomes

- **SC-001**: Core screens contain no visible mojibake or broken separators.
- **SC-002**: Arabic and English app runs show no missing localization keys.
- **SC-003**: No primary button label is clipped on common phone widths in Arabic.
- **SC-004**: At least 90% of static user-facing strings in core screens are moved to localization resources in the first implementation slice.

## Assumptions

- Full language picker can be a later extension; this plan can start with device locale support.
- User-entered content remains exactly as entered.
- `intl` remains the formatting library.
