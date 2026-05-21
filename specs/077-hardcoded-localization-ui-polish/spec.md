# Feature Specification: Hardcoded Localization UI Polish

**Feature Branch**: `077-hardcoded-localization-ui-polish`  
**Created**: 2026-05-20  
**Status**: Draft  
**Input**: Review findings showed remaining English hardcoded UI and messages in Weekly Digest, Budget, AI advice, App Lock, and other secondary surfaces.

## User Scenarios & Testing

### User Story 1 - Arabic user sees consistent app language (Priority: P1)

As an Arabic user, I want all visible app screens and feedback messages to follow the selected Arabic language immediately, so the app feels complete and trustworthy.

**Why this priority**: Mixed Arabic/English UI is one of the fastest ways to make a finance app feel unfinished.

**Independent Test**: Set app language to Arabic and navigate through Home, Budget, Weekly Digest, App Lock, AI advice surfaces, and common error states. No static English copy should appear except product names, currency codes, provider names, or user data.

**Acceptance Scenarios**:

1. **Given** Arabic is selected, **When** Weekly Digest opens, **Then** title, empty state, labels, insight headings, health text wrappers, and ignored-rate messages are Arabic.
2. **Given** Arabic is selected, **When** Monthly Budget renders no-budget, normal, near-limit, exceeded, or ignored-rate states, **Then** all static labels and warnings are Arabic.
3. **Given** Arabic is selected, **When** AI advice is generated locally, **Then** the user-facing advice and evidence labels are Arabic or presented through localized UI copy.

---

### User Story 2 - English user keeps polished English copy (Priority: P2)

As an English user, I want the same screens to keep clear English copy after localization changes, so fixes do not degrade the default language.

**Why this priority**: Localization work can accidentally shorten, duplicate, or distort existing English text.

**Independent Test**: Run representative English widget tests and manual navigation for the same surfaces.

**Acceptance Scenarios**:

1. **Given** English is selected, **When** Weekly Digest opens, **Then** labels and warnings are clear and match current product terminology.
2. **Given** English is selected, **When** Budget warnings show, **Then** they are precise about converted totals versus missing rates.

---

### User Story 3 - UI handles long Arabic text without overflow (Priority: P2)

As a mobile user on a small screen, I want Arabic labels and warnings to fit without clipping or overlapping, especially inside cards and buttons.

**Why this priority**: Arabic text often becomes longer than English, and finance cards lose trust when text overlaps numbers.

**Independent Test**: Run Arabic widget tests for compact width and manual visual QA on a small Android viewport.

**Acceptance Scenarios**:

1. **Given** Arabic is selected on a small viewport, **When** budget, digest, and AI advice text appears, **Then** no render overflow is thrown.
2. **Given** long category names or status text, **When** rendered in cards, **Then** text wraps or truncates professionally without hiding financial amounts.

## Requirements

- **FR-001**: The app MUST remove user-visible hardcoded English strings from Weekly Digest, Budget progress, AI advice, App Lock PIN screens, and any reviewed secondary finance surfaces.
- **FR-002**: Every new user-facing string MUST be added to both English and Arabic ARB files.
- **FR-003**: Generated localization files MUST be refreshed after ARB changes.
- **FR-004**: Currency codes, provider names, app name, user-entered merchant/category names, and raw exported data MAY remain untranslated.
- **FR-005**: Finance warnings MUST distinguish converted currencies from unconverted/missing-rate currencies.
- **FR-006**: Arabic strings MUST avoid overly long literal translations when a shorter finance-friendly label is clearer.
- **FR-007**: Localized widget tests MUST cover at least Weekly Digest, Budget progress, and one AI advice display path.
- **FR-008**: No localization change may alter calculation behavior.

## Key Entities

- **LocalizedSurface**: A screen or widget with user-visible static copy.
- **FinanceWarningCopy**: Text explaining missing rates, converted totals, budget thresholds, or advice caveats.
- **LocaleVariant**: English and Arabic text variants for the same product meaning.

## Success Criteria

- **SC-001**: Arabic QA across targeted surfaces finds zero unintended English static strings.
- **SC-002**: Targeted widget tests pass in English and Arabic for Weekly Digest and Budget progress.
- **SC-003**: `flutter gen-l10n` completes with no missing ARB keys.
- **SC-004**: `flutter analyze --no-pub` reports no issues after localization changes.

## Assumptions

- Product names, currency codes, and user-entered content are intentionally not translated.
- This plan fixes copy and layout polish only; it does not change business logic.

