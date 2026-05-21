# Implementation Plan: Docs And Specs Alignment

**Branch**: `046-docs-specs-alignment` | **Date**: 2026-05-18 | **Spec**: `specs/046-docs-specs-alignment/spec.md`  
**Input**: Stale docs/specs discovered during review.

## Summary

Refresh entry-point documentation, label outdated analysis as historical, reconcile guided tour status across specs/deferred docs, and keep future backlog items accurately categorized.

## Technical Context

**Language/Version**: Markdown, YAML  
**Primary Dependencies**: Existing Spec Kit structure and Flutter package metadata  
**Storage**: Documentation files only  
**Testing**: Text search checks plus `flutter analyze --no-pub` if `pubspec.yaml` changes  
**Target Platform**: Repository documentation and developer workflow  
**Project Type**: Flutter app with local Spec Kit docs  
**Performance Goals**: N/A for runtime; docs should be concise and navigable  
**Constraints**: Do not delete historical context; do not claim verification without evidence  
**Scale/Scope**: README, pubspec description, selected docs/specs/deferred files

## Constitution Check

- All implementation plans remain under `specs/`.
- Deferred backlog must be read and preserved.
- Verification claims require evidence.
- No user-facing code strings are changed in this docs-only plan.

**Gate Status**: PASS.

## Project Structure

```text
README.md
pubspec.yaml
docs/project_analysis_and_ai_roadmap.md
docs/implementation_plans/deferred-and-advanced-work.md
specs/043-guided-product-tour/spec.md
specs/043-guided-product-tour/tasks.md
specs/README.md
specs/046-docs-specs-alignment/
```

**Structure Decision**: Keep current-state workflow in README/specs/deferred. Keep old analysis as historical instead of deleting it.

## Implementation Notes

- Start by listing stale statements with file/line references.
- Replace README overview with current capabilities: authenticated user-owned data, settings/onboarding/tour, AI gateway, export, monetization foundation, verification commands.
- Keep README setup commands practical and avoid claiming production deploy readiness.
- Change `pubspec.yaml` description only; avoid dependency churn.
- In deferred backlog, mark the guided tour/Home test-failure entry as superseded or blocked by current verification baseline evidence after confirming current docs.
- Do not bulk-check old tasks unless the current implementation evidence is clear.

## Verification

```text
rg -n "A new Flutter project|default counter|No Auth|static stats|Draft" README.md pubspec.yaml docs specs/043-guided-product-tour
flutter analyze --no-pub
```

`flutter analyze --no-pub` is included because `pubspec.yaml` changes can affect project metadata parsing.

## Deferred Items To Keep In Mind

Keep production setup blockers, Firebase smoke tests, monetization/purchase verification, localization manual QA, observability, and Play Store readiness items in the deferred file unless there is fresh completion evidence.

## Complexity Tracking

No constitution violations.
