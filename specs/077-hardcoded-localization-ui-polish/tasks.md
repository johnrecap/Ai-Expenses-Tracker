# Tasks: Hardcoded Localization UI Polish

**Input**: `specs/077-hardcoded-localization-ui-polish/spec.md`, `plan.md`  
**Goal**: Remove remaining hardcoded UI strings from targeted surfaces and verify Arabic/English rendering.

## Phase 1: Audit And Test Baseline

- [X] T001 Audit hardcoded strings in `lib/engagement/widgets/weekly_digest_screen.dart`, `lib/screens/budget/widgets/budget_progress_card.dart`, `lib/ai/services/ai_advice_service.dart`, `lib/screens/app_lock/views/create_pin_screen.dart`, and `lib/screens/app_lock/views/unlock_screen.dart`. **Why**: Prevent missing visible copy. **Fixes**: Identifies every static string before edits. **Expected**: A clear list of keys to localize.
- [X] T002 [P] Add failing English/Arabic widget tests for Weekly Digest in `test/engagement/weekly_digest_screen_test.dart`. **Why**: The digest is user-facing and currently English-heavy. **Fixes**: Missing localization coverage. **Expected**: Tests fail until digest copy uses ARB.
- [X] T003 [P] Add failing English/Arabic widget tests for Budget progress in `test/budget/budget_progress_card_test.dart`. **Why**: Budget warnings affect user trust. **Fixes**: Hardcoded budget labels and ignored-rate text. **Expected**: Tests prove no static English appears in Arabic mode.
- [X] T004 [P] Add targeted advice copy tests in `test/ai/ai_advice_service_test.dart`. **Why**: AI advice currently returns English sentences. **Fixes**: Local AI advice not respecting selected language. **Expected**: Advice can be rendered or produced with localized copy.

## Phase 2: Localization Keys

- [X] T005 Add English ARB keys to `lib/l10n/app_en.arb` for digest title, empty state, metric labels, insight heading, health labels, budget labels, budget warnings, app lock labels, and AI advice templates. **Why**: Generated localization requires all strings to live in ARB. **Fixes**: Hardcoded static UI copy. **Expected**: English text remains polished and centralized.
- [X] T006 Add matching Arabic ARB keys to `lib/l10n/app_ar.arb` with short mobile-safe phrasing. **Why**: Direct translation can overflow. **Fixes**: Mixed-language Arabic UI. **Expected**: Arabic copy is clear and compact.
- [X] T007 Run `flutter gen-l10n` to regenerate `lib/l10n/app_localizations*.dart`. **Why**: ARB changes do not reach code until generated. **Fixes**: Missing generated getters. **Expected**: New localization getters compile.

## Phase 3: Surface Replacement

- [X] T008 [US1] Replace Weekly Digest literals in `lib/engagement/widgets/weekly_digest_screen.dart` with localization getters. **Why**: Arabic users currently see English on this screen. **Fixes**: Digest title, empty state, metric labels, insight heading, and ignored-currency message. **Expected**: Digest follows selected language.
- [X] T009 [US1] Replace Budget progress literals in `lib/screens/budget/widgets/budget_progress_card.dart` with localization getters. **Why**: Budget is a core trust surface. **Fixes**: Monthly Budget, Set/Edit, Spent/Remaining, no-budget, threshold warnings, and ignored-currency warning. **Expected**: Budget card is localized and wording matches conversion behavior.
- [X] T010 [US1] Localize local AI advice messages in `lib/ai/services/ai_advice_service.dart` using a narrow copy provider or localized UI mapping. **Why**: AI should not answer English inside an Arabic app. **Fixes**: English advice/evidence strings. **Expected**: Advice output respects app language without changing calculations.
- [X] T011 [US1] Replace App Lock PIN screen literals in `lib/screens/app_lock/views/create_pin_screen.dart` and `lib/screens/app_lock/views/unlock_screen.dart`. **Why**: Security screens are high-trust flows. **Fixes**: PIN labels, unlock button, biometrics label, and titles. **Expected**: App lock feels native in Arabic and English.

## Phase 4: Layout And Verification

- [X] T012 [US3] Review targeted widgets for Arabic overflow and adjust wrapping, max lines, or layout constraints in the touched files. **Why**: Localized copy can break compact cards. **Fixes**: Clipping/overlap risk. **Expected**: No render overflow in tests or manual preview.
- [X] T013 Run targeted tests: `flutter test --no-pub test/engagement test/budget test/ai/ai_advice_service_test.dart test/app_lock --reporter expanded --concurrency=1 --timeout 45s`. **Why**: Confirms localized behavior. **Fixes**: Regression risk after copy changes. **Expected**: All targeted tests pass.
- [X] T014 Run `flutter analyze --no-pub`. **Why**: Catch missing getters/imports after l10n generation. **Fixes**: Compile/static issues. **Expected**: Analyzer reports no issues.

## Dependencies

T001 before all replacement work. T005-T007 before T008-T011. T012 after replacement. T013-T014 last.

## MVP Scope

Complete Weekly Digest and Budget progress first, because they are visible finance trust surfaces.

## Implementation Notes

- Changed files: `lib/engagement/widgets/weekly_digest_screen.dart`, `lib/screens/budget/widgets/budget_progress_card.dart`, `lib/ai/services/ai_advice_service.dart`, `lib/ai/cubit/ai_assistant_cubit.dart`, `lib/screens/app_lock/views/create_pin_screen.dart`, `lib/screens/app_lock/views/unlock_screen.dart`, `lib/l10n/app_en.arb`, `lib/l10n/app_ar.arb`, `test/engagement/weekly_digest_screen_test.dart`, `test/budget/budget_progress_card_test.dart`, `test/ai/ai_advice_service_test.dart`, `test/app_lock/app_lock_localization_test.dart`.
- Parent integration pass ran `flutter gen-l10n`, targeted localization tests, and `flutter analyze --no-pub`; all passed.
- Remaining risk: broad real-device RTL/PDF visual QA remains outside automated verification.
