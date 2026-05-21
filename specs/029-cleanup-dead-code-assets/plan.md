# Implementation Plan: Cleanup Dead Code And Assets

**Branch**: `029-cleanup-dead-code-assets` | **Date**: 2026-05-17 | **Spec**: `specs/029-cleanup-dead-code-assets/spec.md`  
**Input**: Remove or document unused files, assets, dependencies, and legacy backend artifacts.

## Summary

Audit suspected unused artifacts, remove only those proven unused, and document retained legacy backend code. This plan is intentionally conservative: verify references first, delete only safe artifacts, and run dependency/build verification after changes.

## Technical Context

**Language/Version**: Dart 3.x, Flutter  
**Primary Dependencies**: Existing Flutter dependencies, optional Node dependencies under `functions/` and `workers/ai-gateway`  
**Storage**: No production data changes  
**Testing**: `rg` reference checks, `flutter pub get`, `flutter analyze`, relevant tests  
**Target Platform**: Multi-platform Flutter project  
**Project Type**: Flutter app plus optional backend folders  
**Performance Goals**: Reduce maintenance noise without behavior regression  
**Constraints**: No blind deletion; no removal of user data paths; no category PNG dependency reintroduction  
**Scale/Scope**: Assets, demo data, unused widgets, unused dependencies, legacy backend docs

## Constitution Check

- Preserve existing code style and scope.
- Category UI must not build `assets/{category.icon}.png` directly.
- Current AI path is Cloudflare Worker; Firebase Functions are optional future backend code.
- Verification commands must run after cleanup.

## Project Structure

```text
assets/
lib/data/
lib/screens/stats/
pubspec.yaml
functions/
workers/ai-gateway/
specs/
```

**Structure Decision**: Remove proven-unused app artifacts; document backend retention decisions in specs/README or relevant docs instead of deleting potentially useful future backend code without approval.

## Known Candidates To Verify

- `assets/food.png`, `assets/shopping.png`, `assets/travel.png`, `assets/entertainment.png`, `assets/home.png`, `assets/pet.png`, `assets/tech.png`
- `lib/data/data.dart`
- `lib/screens/stats/chart.dart`
- `redacted` dependency in `pubspec.yaml`
- `functions/` optional legacy backend status

## Risks

- Some assets may be referenced outside Dart files. Mitigation: search the full repo.
- Removing a package may break generated code or transitive imports. Mitigation: run `flutter pub get` and analyze.
- Deleting `functions/` may lose future paid-backend work. Mitigation: document and keep unless explicitly approved.
