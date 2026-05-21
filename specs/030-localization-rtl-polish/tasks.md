# Tasks: Localization And RTL Polish

**Input**: `specs/030-localization-rtl-polish/spec.md`, `plan.md`  
**Implementation Intent**: Add Arabic/English localization foundation and fix visible text/RTL issues.

## Phase 1: Setup Localization Foundation

- [X] T001 Add Flutter localization configuration.

  **Why**: Hardcoded strings need a standard localization system.
  **Steps**:
  1. Confirm `flutter_localizations` availability in `pubspec.yaml`.
  2. Add or verify `generate: true` if using Flutter gen-l10n.
  3. Add `l10n.yaml` with source/output settings.
  4. Run `flutter gen-l10n`.
  **Done when**: App localization classes generate successfully.

- [X] T002 Create English and Arabic ARB files.

  **Why**: Core strings need language resources before widget migration.
  **Steps**:
  1. Add `lib/l10n/app_en.arb`.
  2. Add `lib/l10n/app_ar.arb`.
  3. Include app title and common actions: save, cancel, delete, edit, confirm, retry, settings, expenses.
  4. Include AI error/quota common messages.
  **Done when**: Both ARB files validate and generate.

- [X] T003 Wire localization delegates into the app root.

  **Why**: Widgets cannot read localized strings until the root app exposes delegates and supported locales.
  **Steps**:
  1. Find the root `MaterialApp`.
  2. Add generated delegates.
  3. Add supported locales for English and Arabic.
  4. Preserve existing theme/navigation behavior.
  **Done when**: App starts in English and Arabic locale fixtures.

## Phase 2: Fix Broken Text Immediately

- [X] T004 Fix the mojibake separator in `lib/screens/expenses/views/expenses_screen.dart`.

  **Why**: The visible `آ·` separator is a direct user-facing defect.
  **Steps**:
  1. Locate the bad separator around line 262 or current equivalent.
  2. Replace with valid punctuation, spacing, or a localized layout separator.
  3. Confirm mixed Arabic/English text remains readable.
  4. Add a small widget or rendering test if practical.
  **Done when**: Expenses details render without mojibake.

- [X] T005 Search for other mojibake or corrupted characters.

  **Why**: One broken separator suggests other encoding issues may exist.
  **Steps**:
  1. Search common mojibake patterns in `lib`, `packages`, and specs where relevant.
  2. Review suspicious strings manually.
  3. Fix user-facing corrupted text only.
  4. Avoid changing user data or intentional examples.
  **Done when**: No obvious corrupted UI strings remain.

## Phase 3: Localize Core Screens

- [ ] T006 [P] Localize Home screen strings and tooltips.

  **Why**: Home is the first authenticated screen.
  **Steps**:
  1. Move visible static labels to ARB files.
  2. Add tooltips for top action icons.
  3. Preserve user names, amounts, category names, and transaction descriptions as data.
  4. Test Arabic text length.
  **Done when**: Home has localized static copy and no clipped primary labels.

- [ ] T007 [P] Localize Add Expense and Categories strings.

  **Why**: These are primary daily workflows.
  **Steps**:
  1. Move labels, validation messages, buttons, category dialog text, and color/icon picker copy to ARB.
  2. Keep user-entered category names unchanged.
  3. Check RTL layout for form fields and dropdowns.
  4. Verify icons remain clear in RTL.
  **Done when**: Add Expense and Categories work in Arabic and English.

- [ ] T008 [P] Localize Expenses and Reports/Stats strings.

  **Why**: Users review spending there.
  **Steps**:
  1. Move filter labels, empty states, date labels, chart headings, and comparison text to ARB.
  2. Use `intl` locale for dates and numbers.
  3. Check chart labels are readable in Arabic.
  4. Confirm filters still work.
  **Done when**: Reviewing expenses/reports is localized.

- [ ] T009 [P] Localize Settings, AI Assistant, and Free/Premium strings.

  **Why**: Settings and AI messages include important explanations and limits.
  **Steps**:
  1. Move settings section titles and row labels to ARB.
  2. Move AI quota/provider/unclear-input messages to ARB.
  3. Move Free/Premium benefit labels and CTA copy to ARB.
  4. Keep examples natural in Arabic where shown.
  **Done when**: Support/monetization/AI surfaces are bilingual.

## Phase 4: RTL Layout QA

- [ ] T010 Add widget tests for English and Arabic locales on core widgets.

  **Why**: Localization regressions should be caught automatically.
  **Steps**:
  1. Pump representative Home/Settings/AI widgets in English.
  2. Pump the same widgets in Arabic.
  3. Assert critical labels appear.
  4. Assert no raw localization key is visible.
  **Done when**: Locale smoke tests cover core surfaces.

- [ ] T011 Run manual RTL checks on a small phone viewport.

  **Why**: Arabic text can overflow even when tests pass.
  **Steps**:
  1. Run app with Arabic device/app locale.
  2. Check Home, Add Expense, Expenses, Reports, Categories, Settings, AI, Free/Premium.
  3. Look for clipped buttons, overlapping cards, reversed icon meaning, and unreadable chart labels.
  4. Fix layout issues with wrapping, constraints, or icon buttons.
  **Done when**: Core screens are usable in Arabic on small Android screen.

## Phase 5: Verification

- [X] T012 Run localization and Flutter verification.

  **Why**: Generated localization affects the build.
  **Steps**:
  1. Run `flutter gen-l10n`.
  2. Run `flutter analyze`.
  3. Run localization/widget tests.
  4. Run full tests if baseline supports it.
  **Done when**: Generated localization and app analysis pass.

- [X] T013 Document localization conventions.

  **Why**: Future workers need to know where strings go.
  **Steps**:
  1. Update relevant docs or README with ARB location.
  2. State static UI strings must use localization.
  3. State user-generated data must not be translated.
  4. Mention `flutter gen-l10n` in verification steps.
  **Done when**: Future string work follows the same pattern.
