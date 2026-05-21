# Tasks: Localization Export And UX Polish

**Input**: `specs/036-localization-export-ux-polish/spec.md`, `plan.md`  
**Implementation Intent**: Make Arabic/English UI and export output production-polished without changing core app architecture.

## Phase 1: Localization Inventory

- [X] T001 Audit hardcoded app-owned strings in `lib/screens/`, `lib/ai/`, and `lib/monetization/`.

  **Why**: The app already has l10n but many user-facing strings remain in Dart files.
  **Steps**:
  1. Search for `Text('...')`, `tooltip:`, `labelText:`, `hintText:`, snackbars, dialogs, and error strings.
  2. Classify each string as app-owned, user-generated, provider-generated, or debug-only.
  3. Build a checklist grouped by screen: Home, Add Expense, Categories, Expenses, Reports, Settings, AI Assistant, Free/Premium, Recurring, Subscription Center, Category Budgets, Export.
  4. Do not mark category names, descriptions, or user-entered text for translation.
  **Done when**: Every remaining app-owned hardcoded string has an owner and target l10n key.
  **Parent completion (2026-05-18)**: Audit and follow-up buckets documented in `docs/localization/hardcoded-string-audit.md`.

- [X] T002 Add missing keys to `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb`.

  **Why**: Widgets should read generated localization keys instead of inline strings.
  **Steps**:
  1. Add English keys with clear names grouped by feature.
  2. Add Arabic translations matching the same key set.
  3. Include placeholders for dynamic values like quota counts, dates, amounts, and reset time.
  4. Keep punctuation and direction-friendly formatting.
  **Done when**: ARB files have matching keys and no duplicate or placeholder mismatch.

- [X] T003 Run `flutter gen-l10n`.

  **Why**: ARB edits must generate strongly typed localization accessors.
  **Steps**:
  1. Run the generator.
  2. Confirm generated files update cleanly.
  3. Fix missing placeholder metadata if generation fails.
  **Done when**: Generated localization classes expose all new keys.

  **Parent verification (2026-05-18)**: `flutter gen-l10n` completed successfully after ARB changes.

## Phase 2: Localize Core Screens

- [X] T004 Localize Home, navigation labels, and dashboard menu strings.

  **Why**: Home is the first production impression and currently has several English labels.
  **Steps**:
  1. Replace app-owned text and tooltips in Home/Main navigation with l10n keys.
  2. Keep user display name and category names unchanged.
  3. Verify menu entries like Category Budgets and Subscription Center are localized.
  4. Add a logout confirmation dialog with localized title/body/actions.
  **Done when**: Home and its menus render localized text and logout is confirmed before sign out.

- [ ] T005 Localize Add Expense, Categories, and Recurring Expenses screens.

  **Why**: These are high-frequency data-entry flows.
  **Steps**:
  1. Replace form labels, hints, validation messages, empty states, and dialog buttons.
  2. Preserve selected category names as user content.
  3. Confirm payment method labels use existing localizable presentation helpers.
  4. Fix any text overflow found while replacing labels.
  **Done when**: Data-entry flows work in Arabic/English without hardcoded app-owned strings.

- [ ] T006 Localize Expenses, Reports, Export, Category Budgets, and Subscription Center.

  **Why**: Review/export/reporting screens must feel finished in both languages.
  **Steps**:
  1. Localize filter labels and reset actions.
  2. Localize report period labels, empty states, and comparison text.
  3. Localize export format/date/category/payment/currency labels.
  4. Localize category budget and subscription labels, tooltips, and empty states.
  **Done when**: Analysis and export surfaces are localized.

- [ ] T007 Localize Settings, AI Assistant, Free/Premium, Ads, and quota surfaces.

  **Why**: These screens explain trust, privacy, AI limits, and monetization.
  **Steps**:
  1. Replace plan comparison, consent, quota, reward, and purchase placeholder strings.
  2. Replace AI unavailable/quota/provider/preview labels.
  3. Localize voice unavailable/permission messages.
  4. Keep raw AI/user transcript text unchanged.
  **Done when**: Trust and monetization surfaces are localized and consistent.

## Phase 3: PDF Arabic Export

- [X] T008 Add a Unicode Arabic-capable font asset under `assets/fonts/`.

  **Why**: The `pdf` package warning shows default Helvetica cannot render Arabic.
  **Steps**:
  1. Add an open licensed font such as Noto Sans Arabic or Cairo.
  2. Register the asset in `pubspec.yaml` if needed.
  3. Document the font license/source in `docs/release/play-store-checklist.md` or a font notes file.
  **Done when**: The project contains a legal bundled font for PDF rendering.
  **Parent completion (2026-05-18)**: Added Noto Sans Arabic Regular from Noto Fonts to `assets/fonts/NotoSansArabic-Regular.ttf`. Source/license recorded in `docs/export/pdf-arabic-font.md`.

- [X] T009 Update PDF export service in `lib/services/export/` to load and use the bundled font.

  **Why**: Export code must explicitly use the font; adding the asset alone is not enough.
  **Steps**:
  1. Load font bytes through root bundle or an injectable loader for tests.
  2. Use the font for table headers, amounts, descriptions, category names, and metadata.
  3. Set text direction/layout handling so Arabic and mixed text render correctly.
  4. Return a friendly export failure if font load fails.
  **Done when**: PDF export with Arabic text renders readable output and does not show Helvetica Unicode warnings.

  **Worker 036 note (2026-05-18)**: Exporter was initially wired to load `assets/fonts/NotoSansArabic-Regular.ttf`. Parent review adjusted the behavior so English/numeric PDF export falls back to the default PDF font when the Arabic font asset is missing, while Arabic rows return a friendly failure until the font asset is added.
  **Parent completion (2026-05-18)**: Font asset is now present and the Arabic PDF export service path is covered by automated tests.

- [X] T010 Add export tests for Arabic PDF generation.

  **Why**: This regression is likely to return if the font path changes.
  **Steps**:
  1. Add a test expense with Arabic description and category.
  2. Generate a PDF using the export service.
  3. Assert the service completes and the PDF bytes are non-empty.
  4. If practical, assert embedded font metadata or absence of the previous warning path.
  **Done when**: Arabic PDF generation has automated coverage.
  **Parent completion (2026-05-18)**: Added `test/export/pdf_exporter_arabic_font_test.dart` to cover successful Arabic PDF generation with the bundled font and the friendly failure path when the font cannot be loaded.

## Phase 4: No-op And Misleading UI Fixes

- [X] T011 Fix the Add Expense category field behavior in `lib/screens/add_expense/views/add_expense.dart`.

  **Why**: The field is read-only and currently has `onTap: () {}`, which feels broken.
  **Steps**:
  1. Decide the intended interaction: open a category picker, scroll/focus to category list, or remove tappable affordance.
  2. Implement the chosen behavior without changing category selection persistence.
  3. Keep archived categories hidden for new expenses.
  4. Add a widget test if the selected behavior is opening/focusing a picker.
  **Done when**: Tapping the field does something clear or no longer appears tappable.

- [X] T012 Add confirmation before logout in Home/menu flow.

  **Why**: Signing out is a disruptive session action and should not happen accidentally.
  **Steps**:
  1. Show localized confirmation dialog before dispatching sign-out.
  2. Keep cancellation on the same screen.
  3. Preserve existing AuthBloc sign-out path.
  4. Add a widget test for cancel and confirm if the screen is testable.
  **Done when**: Logout requires explicit confirmation.

- [ ] T013 Audit Settings action rows and unavailable feature CTAs.

  **Why**: Production UI should not contain actions that silently do nothing.
  **Steps**:
  1. Tap each Settings section control in a manual/device or widget review.
  2. Ensure each action either opens a screen/dialog, toggles state, or shows an honest unavailable message.
  3. Update labels for future features such as Premium purchases to avoid implying payment is live.
  **Done when**: No obvious Settings/plan CTA behaves like a dead button.

## Phase 5: Tests And Manual RTL QA

- [ ] T014 Add localized widget tests for representative screens.

  **Why**: A few tests catch missing localization keys and RTL layout regressions.
  **Steps**:
  1. Add English and Arabic tests for Home or summary widget.
  2. Add Add Expense field/validation localization test.
  3. Add Settings/Free-Premium text test.
  4. Add AI Assistant unavailable/quota text test if possible.
  **Done when**: Core localized surfaces have automated coverage.
  **Parent partial completion (2026-05-18)**: Added `test/localization/localized_strings_test.dart` for core English/Arabic release strings. Task remains unchecked until Add Expense, Settings/Free-Premium, and AI Assistant localized widget tests are added.

- [ ] T015 Run manual RTL QA on a small Android viewport.

  **Why**: Automated tests rarely catch keyboard/bottom-sheet overlap and Arabic wrapping issues.
  **Steps**:
  1. Set device/app locale to Arabic.
  2. Open Add Expense with keyboard visible.
  3. Open AI Assistant and use voice/text input.
  4. Open Export, Free/Premium, Subscription Center, and Settings.
  5. Record any overflow/overlap and fix it in scope.
  **Done when**: No core screen has obvious Arabic overflow, clipped buttons, or inaccessible actions.

- [X] T016 Run `flutter gen-l10n`, `flutter analyze`, and full Flutter tests.

  **Why**: Localization and asset changes touch generated files and many widget tests.
  **Steps**:
  1. Run `flutter gen-l10n`.
  2. Run `flutter analyze`.
  3. Run `flutter test --reporter expanded --concurrency=1 --timeout 45s`.
  4. Build release APK if asset/pubspec changes affect packaging.
  **Done when**: Generation, analyzer, tests, and packaging checks pass.

  **Worker handoff note (2026-05-18)**: Worker 036 did not run generation, analyze, tests, builds, or manual RTL QA by instruction. Parent verification below supersedes the generation/analyzer/test portion; Arabic PDF rendering was completed by adding `assets/fonts/NotoSansArabic-Regular.ttf`.

  **Parent verification (2026-05-18)**: `flutter gen-l10n`, `flutter analyze`, and the full Flutter test suite passed. Release build was not run because no Flutter asset/pubspec packaging change was completed and production signing files are intentionally absent.

## Dependencies & Execution Order

- T001 must precede T002 to T007.
- T002 must precede T003 and screen localization edits.
- T008 must precede T009 and T010.
- T011 to T013 can run in parallel with localization once shared files are coordinated.
- T016 is final.

## Suggested MVP

Complete T001 to T011 and T016 first. This fixes the most visible Arabic and no-op issues before broader polish.
