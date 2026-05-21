# Feature Specification: Production Release Hardening

**Feature Branch**: `034-production-release-hardening`  
**Created**: 2026-05-18  
**Status**: Draft  
**Input**: Convert the current working Android build from an internal-test APK into a production-ready release configuration.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Install A Real Release Build (Priority: P1)

As the app owner, I need a release build that is signed with a real upload/release key, has the correct package name, and can be installed or uploaded without relying on debug signing.

**Why this priority**: Debug signing is the biggest production blocker. The app can build today, but the release build is not store-ready.

**Independent Test**: Build the release APK/AAB with production signing enabled and verify the package id remains `com.saeeddevstudio.ai_expenses_tracker`.

**Acceptance Scenarios**:

1. **Given** release signing properties exist locally, **When** the app is built for release, **Then** the build uses the configured release signing key instead of debug signing.
2. **Given** signing properties are missing on a developer machine, **When** a debug/internal build is requested, **Then** the project still gives a clear setup error or falls back only for non-production builds.
3. **Given** the generated artifact is inspected, **When** package metadata is checked, **Then** package id, version code, version name, and Firebase package identity match the intended app.

---

### User Story 2 - Build With Production Configuration (Priority: P1)

As the app owner, I need one documented command for production-like builds that injects the Cloudflare AI gateway URL, real AdMob app id, and future store settings without exposing secrets in source control.

**Why this priority**: The AI currently falls back to mock mode unless `AI_GATEWAY_URL` is provided at build time. Production builds must not accidentally ship disabled AI.

**Independent Test**: Run the documented build command and verify the resulting app uses the gateway configuration without storing AI provider keys in Flutter source or platform folders.

**Acceptance Scenarios**:

1. **Given** a real Worker URL is available, **When** the release command is run, **Then** the app receives `AI_GATEWAY_URL` through `--dart-define`.
2. **Given** a production AdMob app id is configured locally, **When** Android manifest placeholders are resolved, **Then** test app id is not used for production.
3. **Given** the repo is scanned for provider secrets, **When** secret search runs, **Then** no Gemini/OpenAI/provider key is present in committed Flutter, Android, iOS, Firebase, or Worker config files.

---

### User Story 3 - Store Readiness Metadata (Priority: P2)

As the app owner, I need a repeatable checklist for Play Store readiness: versioning, privacy disclosures, permissions, screenshots, and release notes.

**Why this priority**: A technically valid APK is not enough for store review.

**Independent Test**: A reviewer can follow `quickstart.md` and confirm every release requirement before uploading.

**Acceptance Scenarios**:

1. **Given** the app requests speech, notifications, auth, ads, camera/receipt, and local lock features, **When** the store checklist is reviewed, **Then** each permission has a clear product reason and privacy disclosure.
2. **Given** a new version is prepared, **When** version values are updated, **Then** version code increases and version name follows the release notes.

### Edge Cases

- Missing keystore files must not cause developers to accidentally publish debug-signed artifacts.
- Local-only build files such as `key.properties` must stay ignored.
- The app must still allow internal testing builds without requiring production ad ids.
- Rebuilding from another machine must have documented setup steps and not depend on hidden local knowledge.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Release builds MUST use a real configurable signing config, not `signingConfigs.debug`.
- **FR-002**: Signing files, passwords, and keystore paths MUST remain outside source control.
- **FR-003**: The production build command MUST inject `AI_GATEWAY_URL` and keep provider API keys out of the Flutter client.
- **FR-004**: Android AdMob app id MUST be configurable and MUST default to test ids only for non-production/internal builds.
- **FR-005**: Android app id and Firebase package name MUST remain `com.saeeddevstudio.ai_expenses_tracker`.
- **FR-006**: Build documentation MUST explain APK/AAB commands, required local properties, and verification checks.
- **FR-007**: Release readiness documentation MUST include permissions, privacy disclosures, versioning, and store upload checklist.
- **FR-008**: CI/local verification MUST include `flutter analyze`, `flutter test`, and release build smoke verification.

### Key Entities

- **ReleaseSigningConfig**: Local-only keystore path, alias, and passwords needed to sign production artifacts.
- **ProductionBuildConfig**: Build-time values such as AI gateway URL, AdMob app id, version code, version name, and flavor/build mode.
- **ReleaseChecklist**: Human-readable store readiness list covering privacy, permissions, testing, and artifact validation.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A production-like Android release artifact can be built in under 10 minutes using documented commands.
- **SC-002**: Secret scans find zero provider keys or signing secrets in committed project files.
- **SC-003**: Release artifact inspection confirms non-debug signing before store upload.
- **SC-004**: A new developer can reproduce an internal release build by following the quickstart without asking for undocumented steps.

## Assumptions

- Android is the first production target; iOS production signing can be planned later.
- Cloudflare Worker remains the production AI gateway for the free Firebase/Spark path.
- Real AdMob app ids will be provided by the owner outside source control.
- Play Store upload may prefer AAB, but APK remains useful for direct device testing.
