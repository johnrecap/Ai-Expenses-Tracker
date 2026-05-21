# Implementation Plan: Daily Exchange Rate Cache

**Branch**: `060-daily-exchange-rate-cache` | **Date**: 2026-05-19 | **Spec**: `specs/060-daily-exchange-rate-cache/spec.md`  
**Input**: Feature specification from `specs/060-daily-exchange-rate-cache/spec.md`

## Summary

Replace per-build live exchange-rate lookup with a daily persisted cache. The app will refresh supported non-base currency rates once per local day, save successful rates and a refresh timestamp in `UserSettings`, and calculate Home totals from saved settings. If refresh fails, existing saved rates remain the source of truth; if a rate is absent, the existing missing-rate status is shown.

## Technical Context

**Language/Version**: Dart 3.x, Flutter  
**Primary Dependencies**: Flutter Bloc, `http`, existing `expense_repository` settings model/repository  
**Storage**: Firestore user settings document `users/{userId}/settings/profile`; native Firestore local persistence supplies offline cached settings  
**Testing**: `flutter_test`, targeted service/model/Home tests, Firestore rules tests if rules change  
**Target Platform**: Flutter mobile app, primarily Android release build  
**Project Type**: Mobile app with local package repository layer  
**Performance Goals**: No repeated exchange-rate network calls during same-day Home rebuilds; keep refresh bounded to supported non-base currencies  
**Constraints**: No hardcoded rates; no provider API keys in Flutter; offline behavior must preserve last saved rates; AI and expense save paths must remain unaffected  
**Scale/Scope**: Current user-supported currencies list, usually fewer than 10 currencies

## Constitution Check

- Spec Kit artifacts are created under `specs/060-daily-exchange-rate-cache/`: PASS.
- User settings access remains through `SettingsRepository`: PASS.
- Home totals remain calculated through `HomeSummaryCalculator`: PASS.
- No provider keys or secrets are added to Flutter: PASS.
- Firestore serialization changes remain in entity/model mapping code: PASS.
- Mixed-currency totals do not add incompatible currencies without conversion: PASS.

## Project Structure

### Documentation (this feature)

```text
specs/060-daily-exchange-rate-cache/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── checklists/
│   └── requirements.md
└── tasks.md
```

### Source Code

```text
lib/
├── screens/home/views/main_screen.dart
├── screens/home/services/home_summary_calculator.dart
├── screens/home/services/money_conversion_service.dart
└── services/exchange_rates/exchange_rate_service.dart

packages/expense_repository/lib/src/
├── models/user_settings.dart
├── entities/user_settings_entity.dart
├── settings_repo.dart
└── firebase_settings_repo.dart

test/
├── services/exchange_rate_service_test.dart
├── home/home_summary_calculator_test.dart
├── home/home_navigation_test.dart
├── budget/budget_calculator_test.dart
└── repository/user_settings_entity_test.dart

firestore.rules
functions/test/firestoreRules.rules.ts
```

**Structure Decision**: Keep exchange-rate provider and daily refresh orchestration in `lib/services/exchange_rates/`, keep persistence fields in the existing settings model/entity, and keep finance math in existing Home/Budget calculators.

## Complexity Tracking

No constitution violations requiring added complexity.
