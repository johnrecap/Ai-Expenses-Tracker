# Implementation Plan: Production Release Hardening

**Branch**: `034-production-release-hardening` | **Date**: 2026-05-18 | **Spec**: `specs/034-production-release-hardening/spec.md`  
**Input**: Hardening items found by the production readiness audit: debug release signing, production defines, AdMob IDs, store checklist, and artifact verification.

## Summary

Replace debug release signing with a local-only release signing setup, document production build commands, preserve Firebase package identity, keep secrets outside source control, and add a store-readiness checklist before any public release.

## Technical Context

**Language/Version**: Dart 3.x, Flutter, Android Gradle  
**Primary Dependencies**: Existing Flutter/Gradle project, Firebase Android config, google_mobile_ads manifest placeholders  
**Storage**: Local-only `key.properties` or equivalent ignored signing config; no runtime database changes  
**Testing**: `flutter analyze`, `flutter test`, Android release build, artifact/signing inspection  
**Target Platform**: Android production priority  
**Project Type**: Multi-platform Flutter app  
**Performance Goals**: No runtime performance impact; release artifact generated reliably  
**Constraints**: No secrets in source control; no AI provider key in client; package id must not change  
**Scale/Scope**: Android release signing, build documentation, local config template, release checklist

## Constitution Check

- Keep existing Flutter app architecture; this is build hardening only.
- Firebase package name must remain `com.saeeddevstudio.ai_expenses_tracker`.
- AI provider secrets must never be stored in Flutter or platform folders.
- Production ad IDs and purchase secrets must never be stored in Flutter source.
- Verification must include `flutter analyze`, `flutter test`, and release build.

## Project Structure

```text
android/app/build.gradle
android/key.properties.example
.gitignore
docs/release/
specs/034-production-release-hardening/
```

**Structure Decision**: Keep Gradle changes inside Android project files, put human release steps under `docs/release/`, and keep real local signing config ignored.

## Implementation Notes

- Use `key.properties.example` as a documented template, not a real secret file.
- Production build command should include `--dart-define=AI_GATEWAY_URL=<worker-url>`.
- Use `local.properties` only for non-secret local config already supported by the project; signing secrets should be separate and ignored.
- If production AdMob IDs are unavailable, keep test ids documented for internal builds and block calling them production.

## Risks

- Accidentally committing keystore data. Mitigation: `.gitignore` and secret scan task.
- Breaking local debug builds. Mitigation: release config should only require signing data for release builds.
- Shipping mock AI. Mitigation: documented build command and runtime visible provider status check.
