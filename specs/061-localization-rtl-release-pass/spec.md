# Feature Specification: Localization RTL Release Pass

**Feature Branch**: `061-localization-rtl-release-pass`  
**Created**: 2026-05-19  
**Status**: Draft  
**Input**: User asked for a follow-up implementation plan for incomplete localization and RTL readiness after prior partial localization work.

## User Scenarios & Testing

### User Story 1 - App-Owned Text Is Localized In Arabic And English (Priority: P1)

Arabic and English users must see app-owned labels, buttons, validation messages, errors, empty states, and helper copy in the selected app language across high-use screens.

**Why this priority**: Mixed English/Arabic UI makes the app feel unfinished and can block Arabic users from trusting finance, AI, and account actions.

**Independent Test**: Run representative widget tests for Add Expense, Expenses, Settings, AI Assistant, and Free/Premium in English and Arabic and confirm app-owned text comes from `AppLocalizations`.

**Acceptance Scenarios**:

1. **Given** Arabic is selected, **When** the user opens Add Expense, Expenses filters, AI Assistant, Settings, Reports, Export, Saving Goals, Recurring, and Free/Premium, **Then** app-owned text appears in Arabic.
2. **Given** English is selected, **When** the same screens open, **Then** app-owned text appears in English.
3. **Given** user-generated expense/category/receipt text exists, **When** the locale changes, **Then** that user content remains unchanged.

---

### User Story 2 - RTL Layout Works On Small Mobile Screens (Priority: P1)

Arabic users must be able to use the app on a small Android viewport without clipped labels, broken alignment, or keyboard overlap in core flows.

**Why this priority**: Localization is not complete unless the layout survives real Arabic text length and right-to-left direction.

**Independent Test**: Run localized widget tests for overflow-prone surfaces and execute the manual RTL checklist on a small Android device or emulator.

**Acceptance Scenarios**:

1. **Given** Arabic locale on a small viewport, **When** the keyboard is open in Add Expense and AI input, **Then** fields, buttons, and error messages remain reachable and readable.
2. **Given** Arabic locale, **When** the user scrolls Settings, Reports, Export, and Free/Premium, **Then** no text overlaps, clips, or creates large blank gaps.

---

### User Story 3 - Localization Regressions Are Easy To Detect (Priority: P2)

Future work must not accidentally add new app-owned hardcoded English strings in localized surfaces.

**Why this priority**: The app has repeated localization drift; automated checks reduce rework.

**Independent Test**: A documented hardcoded-string audit and targeted tests identify remaining app-owned strings and expected exclusions.

**Acceptance Scenarios**:

1. **Given** a developer adds a screen label, **When** localization checks are run, **Then** app-owned hardcoded text in targeted surfaces is flagged or covered by tests.
2. **Given** provider/debug/test-only text appears, **When** the audit runs, **Then** it is explicitly classified rather than blindly translated.

## Edge Cases

- Currency codes, payment provider names, package/product IDs, debug identifiers, Firebase/Auth provider messages, and user-generated text must not be translated blindly.
- Arabic translations may be longer than English and must not overflow compact buttons, chips, cards, or bottom sheets.
- Mixed Arabic and Latin content must remain readable in RTL.
- Localized date, time, and currency labels must still preserve finance correctness.
- PDF export Arabic visual inspection requires manual device/file QA and may remain blocked until test data and viewer are available.

## Requirements

### Functional Requirements

- **FR-001**: All app-owned UI copy in the scoped surfaces MUST use `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb`.
- **FR-002**: All ARB keys added in English MUST have matching Arabic entries before implementation is complete.
- **FR-003**: `flutter gen-l10n` MUST run after ARB edits and generated files MUST be committed with the implementation.
- **FR-004**: User-generated content MUST remain stored and rendered exactly as entered.
- **FR-005**: Add Expense, Expenses/filter, AI Assistant, Settings, Free/Premium, Export, Reports, Saving Goals, and Recurring MUST be audited for app-owned strings.
- **FR-006**: Representative localized widget tests MUST cover English and Arabic rendering for at least five high-risk surfaces.
- **FR-007**: Manual RTL QA MUST cover a small Android viewport with keyboard open.
- **FR-008**: Any remaining non-localized string MUST be classified as user content, provider content, debug/test-only content, or explicitly deferred.

### Key Entities

- **Localization Key**: An ARB entry exposed by generated `AppLocalizations`.
- **Localized Surface**: A screen or widget whose app-owned copy is sourced from l10n.
- **Hardcoded String Audit**: A tracked list of remaining literal strings and their classification.
- **RTL QA Checklist**: Manual verification checklist for text direction, overflow, keyboard, and scrolling.

## Success Criteria

- **SC-001**: Targeted hardcoded-string audit shows no unclassified P1 app-owned English strings in scoped surfaces.
- **SC-002**: `flutter gen-l10n` completes successfully.
- **SC-003**: `flutter analyze --no-pub` completes successfully.
- **SC-004**: Localized widget tests pass for at least five scoped surfaces.
- **SC-005**: Manual RTL checklist is updated with pass/fail/deferred status for small-screen Android QA.

## Assumptions

- Plan 047 remains historical context; this plan is the release-focused completion pass for remaining localization gaps.
- This plan does not change finance calculations, AI parsing behavior, ads, purchases, or Firebase data schemas except for localized UI strings.
- Device-only QA can be marked blocked with a concrete reason if no Android device/emulator is available during implementation.

