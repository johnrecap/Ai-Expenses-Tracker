# Implementation Plan: Modern Category Visuals

**Branch**: `[020-modern-category-visuals]` | **Date**: 2026-05-17 | **Spec**: `specs/020-modern-category-visuals/spec.md`

## Summary

Replace ad-hoc PNG category icon usage with a central icon registry and modern picker while preserving stored string keys. The user-facing result is a cleaner, consistent category system across all expense surfaces.

## Technical Context

**Language/Version**: Dart 3.x, Flutter Material/Cupertino, existing Font Awesome dependency.  
**Primary Dependencies**: Flutter widgets, `font_awesome_flutter`, `flutter_colorpicker`, `expense_repository`.  
**Storage**: Existing category `icon` string field; no schema-breaking change.  
**Testing**: Widget tests for picker/rendering, serialization tests remain unchanged.  
**Target Platform**: Flutter mobile and desktop/web layouts.  
**Project Type**: Flutter app UI refinement.  
**Performance Goals**: Icon rendering must not cause asset lookup exceptions or visible lag in long lists.  
**Constraints**: Keep category model compatible with existing Firestore data.  
**Scale/Scope**: All category icon display and selection surfaces.

## Constitution Check

- **Change Scope**: Pass. UI-only visual modernization plus central resolver.
- **Repository Pattern**: Pass. Category persistence remains unchanged.
- **Backward Compatibility**: Pass. Stored string keys remain valid.

## Project Structure

```text
lib/categories/
├── category_icon_registry.dart       # new central icon definitions
├── category_color_presets.dart       # new curated swatches
└── category_icon_view.dart           # new reusable renderer

lib/screens/categories/widgets/
└── category_form_dialog.dart

lib/screens/home/views/main_screen.dart
lib/screens/add_expense/views/add_expense.dart
lib/screens/expenses/views/expenses_screen.dart
lib/screens/ai_assistant/widgets/ai_action_preview_card.dart

test/category/
├── category_icon_registry_test.dart
└── category_form_dialog_icon_test.dart
```

**Structure Decision**: Put reusable icon/color logic under a shared category UI folder, not inside a screen, because the same icon resolution is needed across Home, Add Expense, Expenses, Reports, AI preview, and Categories.

## Research

### Decision: Keep stored icon values as string keys
**Rationale**: Existing Firestore categories already store icon names. Changing to raw code points would risk platform-specific incompatibilities.  
**Alternative**: Store `IconData.codePoint`, rejected because it couples data to a Flutter font family.

### Decision: Use existing icon libraries first
**Rationale**: The app already uses Material/Cupertino/FontAwesome. A new icon package should not be added unless the existing set cannot satisfy the design.

### Decision: Central fallback renderer
**Rationale**: Many screens currently construct `Image.asset('assets/$icon.png')`. One bad key can crash or visually break several surfaces.

## Data Model

### CategoryIconDefinition
- `key`: saved string, example `food.dining`.
- `label`: display name in picker.
- `group`: picker grouping.
- `legacyAliases`: old keys such as `food`, `travel`, `tech`.
- `icon`: renderable Flutter icon definition.

### CategoryColorPreset
- `key`: stable swatch key.
- `label`: display name.
- `color`: ARGB int.
- `foreground`: preferred icon/text color.

## Verification

```text
flutter analyze
flutter test test/category/category_icon_registry_test.dart test/category/category_form_dialog_icon_test.dart
flutter test
```

Manual QA must inspect Home, Add Expense, Categories, Expenses, AI preview, and Reports on a phone-width viewport.
