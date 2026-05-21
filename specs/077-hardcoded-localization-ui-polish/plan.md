# Implementation Plan: Hardcoded Localization UI Polish

**Branch**: `077-hardcoded-localization-ui-polish` | **Date**: 2026-05-20 | **Spec**: `specs/077-hardcoded-localization-ui-polish/spec.md`  
**Input**: Remaining hardcoded English and Arabic/RTL polish gaps from the latest review.

## Summary

Replace remaining static English strings in secondary but visible surfaces with generated localization, then add representative widget coverage. The focus is trust and polish: Weekly Digest, Budget progress, local AI advice, App Lock, and any nearby reviewed text must respect the selected app language without changing calculations.

## Technical Context

**Language/Version**: Dart 3.x, Flutter  
**Primary Dependencies**: Existing Flutter localization generated from `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb`  
**Storage**: None  
**Testing**: Widget tests for English/Arabic surfaces, `flutter gen-l10n`, `flutter analyze --no-pub`  
**Target Platform**: Flutter Android-first mobile app  
**Project Type**: Mobile app  
**Performance Goals**: No measurable runtime overhead beyond normal localization lookup  
**Constraints**: Do not alter finance calculations, AI provider behavior, auth, Firestore, or export data formats  
**Scale/Scope**: User-visible static copy in reviewed UI surfaces

## Constitution Check

- Spec Kit artifacts live under `specs/077-hardcoded-localization-ui-polish/`: PASS.
- User-facing strings must use ARB/localization rather than hardcoded literals: PASS.
- Finance math must not change in a localization-only plan: PASS.
- Verification must include generated l10n and analyzer: PASS.
- Deferred broader manual Arabic/PDF QA remains tracked separately: PASS.

## Project Structure

### Source Code

```text
lib/engagement/widgets/weekly_digest_screen.dart
lib/screens/budget/widgets/budget_progress_card.dart
lib/ai/services/ai_advice_service.dart
lib/screens/app_lock/views/create_pin_screen.dart
lib/screens/app_lock/views/unlock_screen.dart
lib/l10n/app_en.arb
lib/l10n/app_ar.arb
lib/l10n/app_localizations*.dart
```

### Tests

```text
test/engagement/weekly_digest_screen_test.dart
test/budget/budget_progress_card_test.dart
test/ai/ai_advice_service_test.dart
test/app_lock/app_lock_localization_test.dart
```

## Design Decisions

### Decision 1: Localize static UI, not user data

Only static labels, warnings, buttons, headings, and generated advice copy are localized. Category names, merchant names, descriptions, and currency codes remain exactly as stored.

### Decision 2: Keep local AI advice deterministic

The local advice service can either return localized copy directly by accepting a localization/copy provider, or return structured advice types consumed by localized UI. Prefer the smallest change matching existing patterns, but avoid adding provider calls.

### Decision 3: Treat finance caveats as product copy

Messages like "expenses in other currencies ignored" should become precise localized caveats, because they directly affect user trust in totals.

## Implementation Strategy

1. Inventory hardcoded static strings in targeted surfaces.
2. Add ARB keys in English and Arabic with short, finance-friendly phrasing.
3. Replace hardcoded literals with `context.l10n` or localized formatting helpers.
4. For service-generated advice, introduce a narrow localization boundary without changing calculation inputs.
5. Add widget/unit tests for English and Arabic.
6. Run `flutter gen-l10n`, targeted tests, and `flutter analyze --no-pub`.

## Risks

- Arabic text can overflow in cards if translated literally.
- Service-level advice may not currently have `BuildContext`; a small copy abstraction may be required.
- Some tests may currently assert old English strings and need updating to l10n-driven expectations.

## Deferred Items Considered

The persistent backlog still includes full small-screen Arabic device QA and Arabic PDF visual inspection. This plan fixes targeted hardcoded UI; it does not replace the broader real-device RTL release pass.

