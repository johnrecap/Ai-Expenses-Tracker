# Feature Specification: Localization Export And UX Polish

**Feature Branch**: `036-localization-export-ux-polish`  
**Created**: 2026-05-18  
**Status**: Draft  
**Input**: Fix production polish gaps: hardcoded English strings, Arabic/RTL coverage, PDF export Arabic font, and small broken/no-op UI interactions.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Use The App Fully In Arabic Or English (Priority: P1)

As a user, I want all core screens, buttons, empty states, errors, tooltips, and monetization/AI messages to appear in my selected language.

**Why this priority**: The app targets Arabic users and currently still has many hardcoded English strings.

**Independent Test**: Launch the app in Arabic and English and verify Home, Add Expense, Categories, Expenses, Reports, Settings, AI Assistant, Free/Premium, Subscription Center, and Category Budgets show localized text.

**Acceptance Scenarios**:

1. **Given** Arabic locale is active, **When** the user opens each core screen, **Then** visible app-owned text appears in Arabic except user-generated category/expense content.
2. **Given** English locale is active, **When** the user opens each core screen, **Then** visible app-owned text appears in English.
3. **Given** RTL is active, **When** toolbars, dialogs, and bottom sheets open, **Then** layout is readable and controls do not overlap.

---

### User Story 2 - Export Arabic Data Correctly (Priority: P1)

As a user with Arabic descriptions/categories, I need PDF export to display Arabic text correctly instead of missing characters or boxes.

**Why this priority**: Current tests warn that Helvetica has no Unicode support; exported PDFs may be broken for Arabic users.

**Independent Test**: Export a PDF containing Arabic category names and descriptions, open it, and confirm Arabic glyphs render correctly.

**Acceptance Scenarios**:

1. **Given** expenses contain Arabic text, **When** PDF export is generated, **Then** Arabic appears readable in the exported file.
2. **Given** the PDF font asset is missing or fails to load, **When** export runs, **Then** the user sees a friendly error instead of a corrupted file or crash.

---

### User Story 3 - Remove Misleading Or Dead UI Actions (Priority: P2)

As a user, I need tappable fields and buttons to either perform a clear action or not look interactive.

**Why this priority**: Small broken interactions reduce trust and make the app feel unfinished.

**Independent Test**: Tap the Add Expense category field, Settings items, Home shortcuts, logout, export actions, and AI controls; every visible action responds clearly.

**Acceptance Scenarios**:

1. **Given** Add Expense is open, **When** the user taps the category field, **Then** category selection opens or focus moves to the category picker.
2. **Given** logout is triggered, **When** the user taps it accidentally, **Then** the app asks for confirmation before signing out.
3. **Given** a feature is not production-ready, **When** the user taps its CTA, **Then** the app states the limitation honestly and offers a safe next step.

### Edge Cases

- User-generated text must not be translated.
- Very long Arabic category names must wrap or truncate without overflow.
- PDF export must support mixed Arabic/English/numbers.
- RTL should not reverse numeric currency values incorrectly.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: All app-owned visible strings in core screens MUST use localization resources.
- **FR-002**: Arabic and English ARB files MUST contain matching keys for all new localized strings.
- **FR-003**: PDF export MUST use a Unicode-capable font that supports Arabic.
- **FR-004**: Export errors MUST be user-friendly and must not crash the app.
- **FR-005**: Add Expense category field MUST perform a useful selection action or be visually non-interactive.
- **FR-006**: Destructive/session-ending actions such as logout MUST require confirmation.
- **FR-007**: Widget tests MUST cover representative Arabic and English localized screens.
- **FR-008**: Manual RTL QA MUST cover small-phone layout for AI Assistant and Add Expense bottom/keyboard states.

### Key Entities

- **LocalizedStringKey**: A stable l10n key with English and Arabic values.
- **ExportFontAsset**: Bundled font file used by PDF export for Unicode text.
- **UXPolishFix**: Small interaction fix with expected behavior and verification steps.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Core screens show zero hardcoded app-owned English strings when Arabic locale is active.
- **SC-002**: PDF export with Arabic text renders correctly in at least one manual viewer test.
- **SC-003**: No tappable no-op controls remain in audited core screens.
- **SC-004**: Localized widget tests pass for at least Home/Add Expense/Settings/AI/Free-Premium representative surfaces.

## Assumptions

- Localization remains English and Arabic only for now.
- User content such as category names and expense descriptions remains exactly as entered.
- A free/open font asset can be bundled in the app for PDF export.
