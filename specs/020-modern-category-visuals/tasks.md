# Tasks: Modern Category Visuals

**Input**: `specs/020-modern-category-visuals/spec.md`, `plan.md`  
**Implementation Intent**: Replace old category PNG icon usage with a modern, central, backward-compatible icon system.

## Phase 1: Audit And Registry Foundation

- [x] T001 Audit all category icon rendering sites.

  **Files to inspect**: `lib/screens/home/views/main_screen.dart`, `lib/screens/add_expense/views/add_expense.dart`, `lib/screens/categories/views/categories_screen.dart`, `lib/screens/expenses/views/expenses_screen.dart`, `lib/screens/ai_assistant/widgets/ai_action_preview_card.dart`, reports/export/recurring screens if they show categories.
  **Why**: Every rendering site must use the same resolver or old broken assets will remain.
  **Steps**:
  1. Search for `assets/$` and `category.icon`.
  2. List each screen and current fallback behavior.
  3. Identify widgets that should be replaced by a shared `CategoryIconView`.
  **Done when**: A worker knows every file to patch before changing UI.

- [x] T002 Create icon registry tests in `test/category/category_icon_registry_test.dart`.

  **Why**: Backward compatibility must be protected before replacing asset rendering.
  **Steps**:
  1. Test legacy keys `food`, `shopping`, `health`, `travel`, `tech`, `home`, `entertainment`, `pet`.
  2. Test unknown key returns fallback.
  3. Test every registered key has a label, group, and icon.
  4. Test registry has at least 40 active choices.
  **Done when**: Tests fail because registry does not exist yet.

- [x] T003 Create `lib/categories/category_icon_registry.dart`.

  **Why**: A single source of truth prevents mismatched icon behavior.
  **Steps**:
  1. Define `CategoryIconDefinition`.
  2. Define groups: Food, Transport, Bills, Shopping, Home, Lifestyle, Health, Work, Education, Subscriptions, Travel, Other.
  3. Add modern icons for dining, groceries, coffee, taxi, bus, fuel, rent, electricity, internet, wallet, card, medicine, gym, school, gifts, subscriptions, savings.
  4. Add legacy aliases for old saved keys.
  5. Add `resolveCategoryIcon(String?)`.
  **Done when**: Registry tests pass.

- [x] T004 Create `lib/categories/category_icon_view.dart`.

  **Why**: Rendering color, shape, fallback, and contrast should be consistent everywhere.
  **Steps**:
  1. Accept `iconKey`, `backgroundColor`, `size`, and optional semantic label.
  2. Resolve icon through `CategoryIconRegistry`.
  3. Use a circular or compact rounded background consistent with existing app style.
  4. Use white/contrast foreground by default.
  5. Never call `Image.asset` directly.
  **Done when**: Any screen can render a category icon with one widget.

## Phase 2: Picker And Colors

- [x] T005 Create `lib/categories/category_color_presets.dart`.

  **Why**: Curated colors make categories look intentional instead of random.
  **Steps**:
  1. Define at least 16 color presets with finance-friendly variety.
  2. Avoid one-note palettes dominated by one hue.
  3. Include foreground color recommendation.
  4. Add tests for duplicate values and empty labels.
  **Done when**: Presets are reusable in category form and AI category suggestions.

- [x] T006 Refactor `CategoryFormDialog` in `lib/screens/categories/widgets/category_form_dialog.dart`.

  **Why**: The current picker has only a few old PNG icons and a dated layout.
  **Steps**:
  1. Replace `_categoryIcons` PNG list with `CategoryIconRegistry`.
  2. Group icons under section labels.
  3. Add a compact search field if the grid becomes long.
  4. Render each choice using `CategoryIconView`.
  5. Keep saved value as the selected icon key string.
  6. Preserve edit mode: old keys resolve to modern equivalent.
  **Done when**: Creating/editing categories no longer depends on old image files.

- [x] T007 Replace the raw color text field in `CategoryFormDialog`.

  **Why**: Users should not see raw integer color values.
  **Steps**:
  1. Show selected color as a swatch with label.
  2. Add preset swatch grid.
  3. Keep existing `flutter_colorpicker` for custom color under "Custom".
  4. Ensure validation still requires a selected color.
  **Done when**: Category color selection is visual and polished.

## Phase 3: Replace Rendering Across App

- [x] T008 Replace Home transaction icon rendering in `lib/screens/home/views/main_screen.dart`.

  **Why**: Home is the most visible screen and currently uses `Image.asset`.
  **Steps**:
  1. Import `CategoryIconView`.
  2. Replace stack+asset rendering with the shared widget.
  3. Keep category color fallback behavior.
  4. Verify unknown icon keys do not throw.
  **Done when**: Home transactions render modern icons.

- [x] T009 Replace Add Expense category dropdown icons in `lib/screens/add_expense/views/add_expense.dart`.

  **Why**: Users choose categories here; old icons weaken the creation flow.
  **Steps**:
  1. Replace asset image prefix/trailing icons with `CategoryIconView`.
  2. Keep category selection state unchanged.
  3. Ensure dropdown row height remains stable.
  **Done when**: Add Expense works with modern icons and no layout shift.

- [x] T010 Replace category list icons in `lib/screens/categories/views/categories_screen.dart`.

  **Why**: The category management screen must display the same icon the picker saves.
  **Steps**:
  1. Use `CategoryIconView`.
  2. Preserve edit/archive actions.
  3. Keep archived category rendering consistent if included.
  **Done when**: Categories screen has no direct PNG asset dependency.

- [x] T011 Replace remaining category icon usage in expenses, reports, AI preview, recurring, and export filters.

  **Why**: Partial migration would leave inconsistent UI.
  **Steps**:
  1. Patch each file found in T001.
  2. Use `CategoryIconView` or resolver only.
  3. Keep screen-specific text/spacing unchanged unless icon size requires a small adjustment.
  **Done when**: Search for `assets/${category.icon}` and similar direct category asset paths returns no active rendering site.

## Phase 4: Tests, QA, And Cleanup

- [x] T012 Add widget tests for icon picker in `test/category/category_form_dialog_icon_test.dart`.

  **Why**: The picker is interactive and easy to regress.
  **Steps**:
  1. Pump `CategoryFormDialog`.
  2. Open icon picker.
  3. Select a modern icon.
  4. Select a preset color.
  5. Save and assert returned `Category.icon` equals selected key.
  **Done when**: Widget test passes.

- [X] T013 Run targeted verification.

  **Commands**:
  ```text
  flutter test test/category/category_icon_registry_test.dart test/category/category_form_dialog_icon_test.dart
  flutter analyze
  ```
  **Done when**: Tests and analysis pass.
  **Status note (Plan 040 cleanup)**: Superseded by later parent verification;
  `flutter analyze` and full Flutter tests passed after category visual work.

- [ ] T014 Manual visual QA.

  **Status note (Plan 040 cleanup)**: Still open because this requires manual
  visual inspection on device/simulator; implementation and automated coverage
  are complete.

  **Steps**:
  1. Create categories in at least five groups.
  2. Edit a legacy category.
  3. Open Home, Add Expense, Categories, Expenses, AI Assistant preview, Reports.
  4. Confirm icons are crisp, aligned, and not AI-themed.
  5. Confirm no text overflow on 360 px width.
  **Done when**: Visual pass is documented with screenshots or notes.

- [x] T015 Keep or remove old PNG assets after compatibility review.

  **Why**: Removing too early can break un-migrated references.
  **Steps**:
  1. Run `rg "assets/.*\\.png|Image.asset" lib test`.
  2. If no category use remains, decide whether old category PNGs are still needed for other UI.
  3. Remove only unused assets in a separate cleanup commit/task.
  **Done when**: No unused icon asset cleanup happens accidentally.
