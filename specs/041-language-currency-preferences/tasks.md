# Tasks: Language And Currency Preferences

**Input**: Design documents from `specs/041-language-currency-preferences/`  
**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `quickstart.md`

**Tests**: Include tests because this plan changes persisted settings, app-root locale behavior, and AI request context.

**Organization**: Tasks are grouped by user story so each slice can be implemented and verified independently.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Establish the exact current touchpoints before changing settings, localization, and AI defaults.

- [X] T001 Inspect current settings persistence in `packages/expense_repository/lib/src/models/user_settings.dart`, `packages/expense_repository/lib/src/entities/user_settings_entity.dart`, and `packages/expense_repository/lib/src/firebase_settings_repo.dart` to confirm migration requirements and avoid overwriting existing user preferences.
- [X] T002 Inspect app localization bootstrapping in `lib/app_view.dart` and `lib/l10n/` to identify where a user-selected locale can be applied without breaking unauthenticated startup.
- [X] T003 Inspect AI and voice locale call sites in `lib/ai/services/ai_gateway_client.dart`, `lib/ai/services/ai_service.dart`, `lib/ai/voice/ai_voice_input_controller.dart`, and `lib/screens/ai_assistant/views/ai_assistant_sheet.dart` because hardcoded locale values must be replaced from one source.
- [X] T004 [P] Add missing localized labels for language settings and settings-load errors in `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb` so new UI does not introduce hardcoded strings.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Add the preference model and repository behavior that all stories depend on.

- [X] T005 Add a `LanguagePreference` model/enum in `packages/expense_repository/lib/src/models/language_preference.dart` with parse, storage value, display intent, and safe fallback behavior because every layer needs the same allowed values.
- [X] T006 Export `LanguagePreference` from `packages/expense_repository/lib/expense_repository.dart` and model barrel files so app code can use it without deep package imports.
- [X] T007 Update `UserSettings` in `packages/expense_repository/lib/src/models/user_settings.dart` with `languagePreference`, copyWith support, defaults set to `system`, and entity mapping so existing settings behavior stays centralized.
- [X] T008 Update `UserSettingsEntity` in `packages/expense_repository/lib/src/entities/user_settings_entity.dart` to read/write `languagePreference` while defaulting missing or unknown values to `system` because old Firestore documents must keep working.
- [X] T009 Update `FirebaseSettingsRepository.ensureDefaultSettings` in `packages/expense_repository/lib/src/firebase_settings_repo.dart` to create new profiles with explicit language preference while preserving old profiles.
- [X] T010 [P] Add repository/entity tests in `test/repository/user_settings_entity_test.dart` for legacy documents, unknown language values, currency preservation, and supported currency normalization because migration errors can corrupt user settings.

**Checkpoint**: Settings documents can safely represent independent language and currency preferences.

---

## Phase 3: User Story 1 - Choose Language Independently (Priority: P1) MVP

**Goal**: Let users choose language independently from currency, and make app/AI/voice locale follow that choice.

**Independent Test**: Set language to Arabic while currency is USD; verify app locale and AI locale are Arabic while currency remains USD.

### Tests for User Story 1

- [X] T011 [P] [US1] Add SettingsCubit tests in `test/settings/settings_cubit_test.dart` proving language save updates only `languagePreference` and leaves `baseCurrency`, supported currencies, payment method, and notifications unchanged.
- [X] T012 [P] [US1] Add app locale widget tests in `test/localization/app_language_preference_test.dart` proving `system`, `ar`, and `en` resolve correctly and do not change currency.
- [X] T013 [P] [US1] Add AI gateway client tests in `test/ai/ai_gateway_client_test.dart` proving parse, receipt, and advice request bodies use `AiContext.locale` instead of hardcoded `ar-EG`.

### Implementation for User Story 1

- [X] T014 [US1] Add language save method to `lib/screens/settings/blocs/settings_bloc/settings_cubit.dart` so Settings can persist language preference through the existing repository boundary.
- [X] T015 [US1] Add a `LanguageSettingsSection` widget under `lib/screens/settings/widgets/` with radio/segmented choices for System, Arabic, and English because language needs a clear dedicated control.
- [X] T016 [US1] Integrate `LanguageSettingsSection` into `lib/screens/settings/views/settings_screen.dart` near profile/currency settings so users understand language and money preferences are separate.
- [X] T017 [US1] Wire `MaterialApp.locale` in `lib/app_view.dart` or a small app preferences wrapper so the selected language applies to visible UI while unauthenticated startup still works.
- [X] T018 [US1] Extend `AiContext` in `lib/ai/services/ai_service.dart` with `locale`, update all constructors/tests, and set it from the resolved app language in `AiAssistantSheet`.
- [X] T019 [US1] Replace hardcoded `ar-EG` in `lib/ai/services/ai_gateway_client.dart` with `context.locale` for `aiParse`, `aiReceipt`, and `aiAdvice` because provider behavior should match the app language.
- [X] T020 [US1] Update `AiVoiceInputController` usage in `lib/screens/ai_assistant/views/ai_assistant_sheet.dart` to prefer the resolved locale when supported and gracefully fall back when not supported.

**Checkpoint**: Language changes work independently and AI/voice receive the selected locale.

---

## Phase 4: User Story 2 - Choose Currency Independently (Priority: P1)

**Goal**: Keep base currency as a user preference that supplies defaults only when no explicit currency exists.

**Independent Test**: Set Arabic+USD and verify manual default USD, then parse Arabic text mentioning جنيه and verify EGP is preserved.

### Tests for User Story 2

- [X] T021 [P] [US2] Add SettingsCubit tests in `test/settings/settings_cubit_test.dart` proving base currency save does not change language preference.
- [X] T022 [P] [US2] Add AI parser/cubit tests in `test/ai/ai_response_parser_gemini_test.dart` and `test/ai/ai_assistant_cubit_test.dart` proving explicit EGP/USD parsed currencies beat base currency.
- [X] T023 [P] [US2] Add Add Expense default tests in `test/add_expense/` proving manual forms default to `UserSettings.baseCurrency` and not app language.

### Implementation for User Story 2

- [X] T024 [US2] Audit `lib/screens/add_expense/` to ensure default currency comes only from `UserSettings.baseCurrency` and never from `Localizations.localeOf`.
- [X] T025 [US2] Audit `lib/screens/ai_assistant/views/ai_assistant_sheet.dart` so `_defaultCurrency` comes from settings and explicit AI payload currency remains untouched in preview.
- [X] T026 [US2] Strengthen currency normalization in `lib/screens/settings/blocs/settings_bloc/settings_cubit.dart` so base currency always remains in supported currencies and empty supported lists are rejected with localized errors.
- [X] T027 [US2] Update Settings currency copy in `lib/screens/settings/widgets/currency_settings_section.dart` to clearly say language and currency are independent and conversion is not applied.

**Checkpoint**: Currency behavior is independent from language and explicit currency intent is preserved.

---

## Phase 5: User Story 3 - Avoid Silent Fallbacks (Priority: P2)

**Goal**: Prevent wrong saves when required settings are unavailable.

**Independent Test**: Simulate settings failure and verify user sees retry/setup instead of silently saving with EGP/Cash.

### Tests for User Story 3

- [X] T028 [P] [US3] Add settings failure widget tests in `test/settings/settings_screen_widget_test.dart` proving load failure shows retry and does not present stale successful controls as saved state.
- [X] T029 [P] [US3] Add AI Assistant failure-context tests in `test/ai/ai_assistant_sheet_test.dart` proving the assistant blocks parse/save that would rely on missing default currency/payment settings.
- [X] T030 [P] [US3] Add Add Expense settings failure tests in `test/add_expense/` proving save requires explicit currency/payment when settings are unavailable.

### Implementation for User Story 3

- [X] T031 [US3] Add a reusable settings-load guard widget or helper under `lib/screens/settings/` or `lib/widgets/` so screens can show retry/setup messages consistently.
- [X] T032 [US3] Update `AiAssistantSheet._loadContext` in `lib/screens/ai_assistant/views/ai_assistant_sheet.dart` to store settings load failure state instead of silently falling back to EGP/Cash.
- [X] T033 [US3] Update AI parse/confirm UI in `lib/screens/ai_assistant/views/ai_assistant_sheet.dart` so users must retry settings or provide explicit values before saving AI previews that depend on missing defaults.
- [X] T034 [US3] Update Add Expense flow in `lib/screens/add_expense/` so settings failure is visible and final save validates currency/payment source before creating an expense.

**Checkpoint**: Missing settings no longer create silent wrong defaults.

---

## Phase 6: Polish & Cross-Cutting Concerns

- [X] T035 [P] Run `flutter gen-l10n` after ARB changes because generated localization files must match new language/currency strings.
- [X] T036 Run `flutter analyze` and fix issues in touched settings, localization, AI, and add-expense files.
- [X] T037 Run targeted tests from `quickstart.md`, then full `flutter test --reporter expanded --concurrency=1 --timeout 45s` if app-root locale wiring changed. Targeted Plan 041 tests passed. Full suite was run as a verification check and exposed out-of-scope guided tour/Home widget failures from later plans; those failures are tracked in the deferred work file and are not part of Plan 041 implementation.
- [X] T038 Update `.specify/memory/constitution.md` with the new language preference convention, locale propagation rule, and verification baseline after implementation.
- [X] T039 Update `docs/implementation_plans/deferred-and-advanced-work.md` if any conversion, additional locale, or manual QA work remains blocked.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup**: No dependencies.
- **Foundational**: Depends on setup inspections and blocks all user stories.
- **US1 and US2**: Can proceed after foundational; they touch related files and need coordination.
- **US3**: Depends on foundational and benefits from US1/US2 context but can be started after settings model is stable.
- **Polish**: Depends on selected user stories.

### Parallel Opportunities

- T004, T010, T011, T012, T013, T021, T022, T023, T028, T029, and T030 can run in parallel when files do not overlap.
- US1 app-root locale work and US2 Add Expense currency work can be split between agents, but both must coordinate on `AiContext`.

## Implementation Strategy

1. Complete the settings model migration first.
2. Deliver US1 language selection and locale propagation as MVP.
3. Deliver US2 currency independence and explicit-currency preservation.
4. Deliver US3 no-silent-fallback safety.
5. Run localization generation, analyzer, and tests before any build.
