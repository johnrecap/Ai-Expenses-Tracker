# Tasks: Guided Tour Visual Upgrade

**Input**: Design documents from `specs/089-guided-tour-visual-upgrade/`  
**Prerequisites**: `plan.md`, `spec.md`

## Phase 1: Audit And Visual Direction

- [ ] T001 Capture current guided tour screenshots in Arabic and English. Why: need baseline before redesign. Expected: screenshot set for AI step, budget, reports, settings, bottom nav. Risk: subjective polish with no comparison. Modification: baseline notes were added to `qa-notes.md`; real-device screenshots remain manual QA.
- [x] T002 Audit existing tour files in `lib/guided_tour/` and target registrations. Why: visual changes must not break persistence/flow. Expected: target/card geometry map. Risk: connector points to wrong widgets. Modification: audit notes added to `plan.md` and `qa-notes.md`.
- [x] T003 Evaluate whether to stay custom or use a package. Why: user asked for visual effect; package risk must be known. Expected: decision with license/performance notes for `save_points_showcaseview`, `liquid_glass_kit`, `oc_liquid_glass`. Risk: adding unstable dependency. Modification: custom painter chosen; no dependency added.

## Phase 2: Foundational Visual Model

- [x] T004 [P] Add `TourConnectorGeometry` under `lib/guided_tour/`. Why: connector calculations need a testable model. Expected: source card edge, target point, path direction, RTL-aware output. Risk: painter math hidden in widget. Modification: pure Dart geometry tests.
- [x] T005 [P] Add `TourSurfaceStyle` tokens under `lib/guided_tour/`. Why: card/overlay style should be consistent. Expected: overlay color, card radius, accent, connector color, fallback values. Risk: scattered magic numbers. Modification: theme-aware defaults.
- [x] T006 Add tests for connector geometry in `test/guided_tour/tour_connector_geometry_test.dart`. Why: connector bugs are hard to catch visually. Expected: top/bottom/left/right/RTL cases pass. Risk: misplaced pointer on device. Modification: test small-screen cases.

## Phase 3: User Story 1 - Tour Points To Target (P1)

**Independent Test**: Each step shows spotlight and connector to the active target.

- [x] T007 Implement connector painter in `lib/guided_tour/`. Why: explanation must visually connect to target. Expected: curved/arrow/liquid pointer from card to target. Risk: overlay feels disconnected. Modification: keep hit-testing disabled for painter.
- [x] T008 Integrate connector into `TourOverlay`. Why: current card needs visual pointer. Expected: connector updates per step. Risk: old overlay remains. Modification: use existing target rectangle and measured card rectangle.
- [x] T009 Improve target not-found/loading fallback. Why: tour should not break when a widget is delayed. Expected: retry/skip-safe fallback. Risk: blank overlay. Modification: existing missing-target safe flow preserved; overlay still shows readable card when target is unavailable.

## Phase 4: User Story 2 - Premium But Readable Tour Card (P1)

**Independent Test**: Arabic/English text readable on small viewport.

- [x] T010 Redesign tour card in `lib/guided_tour/tour_overlay.dart`. Why: user wants it to attract attention. Expected: polished card with subtle accent/water/liquid mark. Risk: decorative effect hurts readability. Modification: preserve high contrast text.
- [x] T011 Add bounded animation. Why: static pointer may be missed; too much motion is bad. Expected: subtle pulse/sweep with disable/reduce path. Risk: battery/frame drops. Modification: existing pulse controller now drives spotlight and connector, with reduced-motion support.
- [x] T012 Localize/shorten tour copy if needed in `lib/l10n/`. Why: Arabic card must fit. Expected: readable concise copy. Risk: overflow. Modification: no copy change was required; existing localized copy is preserved.
- [x] T013 Add widget tests for buttons visibility in `test/guided_tour/tour_overlay_layout_test.dart`. Why: buttons must not be covered. Expected: Next/Back/Skip visible. Risk: user trapped in tour. Modification: compact RTL visibility coverage added to existing `tour_overlay_test.dart`.

## Phase 5: User Story 3 - Replay And Target Movement (P2)

**Independent Test**: Replay from Settings works after scrolling/language switch.

- [x] T014 Improve target geometry recalculation on step advance/layout change. Why: screenshots show target/card positions can shift. Expected: connector recalculates every step. Risk: stale target position. Modification: card geometry is measured post-frame and host refreshes active targets after layout/metric changes.
- [x] T015 Add scroll-to-target hook where missing. Why: below-fold targets must be visible. Expected: target and card both visible. Risk: connector points off-screen. Modification: existing `Scrollable.ensureVisible` path retained and covered by target-preparation test.
- [x] T016 Add replay tests in `test/guided_tour/guided_tour_replay_test.dart`. Why: Settings replay is a user-facing feature. Expected: replay starts, advances, completes/skips. Risk: visual upgrade breaks state. Modification: replay/advance/complete coverage exists in guided tour cubit and settings widget tests; no duplicate file added.

## Phase 6: Manual QA And Performance

- [ ] T017 Run manual Android QA in Arabic and English. Why: visual polish needs real screen checks. Expected: no overlap, connector visible, buttons usable. Risk: tests pass but UI looks bad. Modification: capture screenshots.
- [x] T018 Run analyzer and targeted tour tests. Why: overlay code is layout-sensitive. Expected: no analyzer/test failures. Risk: release build regression.
- [x] T019 Document accepted package decision in `specs/089-guided-tour-visual-upgrade/plan.md` if a dependency is added. Why: dependency rationale must be preserved. Expected: license/performance/rollback note. Risk: unexplained package bloat. Modification: documented no-dependency decision.

## Dependencies

- T004-T006 block connector UI.
- T007-T013 are MVP.
- T014-T016 should follow after primary visual upgrade.

## MVP Scope

Complete T001-T013 first: clear target connector and premium readable card.
