# Feature Specification: Modern Category Visuals

**Feature Branch**: `[020-modern-category-visuals]`  
**Created**: 2026-05-17  
**Status**: Draft  
**Input**: User says current category icons are very old and wants modern icons that do not look AI-generated.

## User Scenarios & Testing

### User Story 1 - Modern Default Category Icon Set (Priority: P1)

As a user, I want category icons to look modern, consistent, and finance-app appropriate across Home, Expenses, Add Expense, Reports, and Categories.

**Why this priority**: Old PNG icons reduce perceived quality and make the app look unfinished.

**Independent Test**: Open every screen that displays categories and verify each category uses a crisp, modern icon with no missing asset errors.

**Acceptance Scenarios**:

1. **Given** a category with legacy icon `food`, **When** it appears on Home, **Then** it renders with a modern food icon and keeps the saved category color.
2. **Given** a category with unknown icon key, **When** it appears anywhere, **Then** the app shows a safe default money/category icon without crashing.
3. **Given** dark or light surfaces, **When** category icons appear, **Then** contrast remains readable.

---

### User Story 2 - Better Icon Picker (Priority: P1)

As a user, when I create or edit a category, I want to choose from grouped modern icons instead of a short old image grid.

**Why this priority**: Category creation currently has too few choices and depends on old assets.

**Independent Test**: Create a category, search/browse icon groups, select an icon, select a color, save, and verify the same icon appears across the app.

**Acceptance Scenarios**:

1. **Given** the category form is open, **When** the user taps icon picker, **Then** grouped icons appear for Food, Transport, Bills, Shopping, Lifestyle, Health, Work, Education, Subscriptions, and Other.
2. **Given** the user selects an icon, **When** they save, **Then** the selected icon key persists in the category.
3. **Given** the user edits an old category, **When** the picker opens, **Then** the old icon key is mapped to the new equivalent.

---

### User Story 3 - Category Color Presets (Priority: P2)

As a user, I want polished color swatches and a custom color picker so categories look consistent without needing manual color tuning.

**Why this priority**: The existing color picker works but the visual result can look random and less polished.

**Independent Test**: Select preset colors, custom colors, and verify contrast against white icon foreground.

## Requirements

### Functional Requirements

- **FR-001**: The app MUST use a central icon registry that maps stored category icon keys to renderable icons.
- **FR-002**: The icon registry MUST preserve backward compatibility for legacy icon keys currently stored in Firestore.
- **FR-003**: The app MUST stop relying on PNG assets for newly selected category icons unless a fallback is explicitly needed.
- **FR-004**: Category icon picker MUST provide at least 40 finance/lifestyle relevant icons grouped by category type.
- **FR-005**: Unknown or empty icon keys MUST render a stable fallback icon.
- **FR-006**: Category color selection MUST include curated swatches plus existing custom color picker.
- **FR-007**: Category list, Home transactions, Add Expense dropdown, Expenses list, Reports, Recurring, Export filters, and AI preview MUST render icons through the same registry.
- **FR-008**: Icons MUST not use AI-themed symbols unless the category itself is AI-related.

### Key Entities

- **CategoryIconDefinition**: Stable icon key, label, group, icon data, and legacy aliases.
- **CategoryColorPreset**: Name, color value, and recommended foreground color.

## Success Criteria

### Measurable Outcomes

- **SC-001**: 100% of category rendering sites use the same icon resolver.
- **SC-002**: No existing saved legacy category displays a broken asset or missing icon.
- **SC-003**: New category creation offers at least 40 icons and 16 curated colors.
- **SC-004**: Icon picker remains usable on a 360 px wide Android screen without text overflow.

## Assumptions

- Stored category `icon` remains a string key for Firestore compatibility.
- Material/Cupertino/FontAwesome icons already available in the app can be reused before adding new icon packages.
- Existing PNG assets can remain for backward compatibility during transition.
