# Implementation Report: Production Ads Readiness

## Changed Files

- `pubspec.yaml`: added `google_mobile_ads: ^5.3.1`.
- `pubspec.lock`: updated by the parent review after `flutter pub get`.
- `lib/monetization/services/google_mobile_ads_service.dart`: added guarded
  AdMob config, consent service, banner, interstitial, and rewarded wrappers
  behind the existing abstractions.
- `lib/monetization/services/google_mobile_ads_service_stub.dart`: added a
  non-mobile conditional-export stub so unsupported platforms fail closed.
- `lib/monetization/services/services.dart`: conditionally exports the AdMob
  implementation on IO platforms and the stub elsewhere.
- `lib/monetization/services/ad_service.dart`: expanded `BannerAdHandle` to
  carry an optional rendered child and added fake-service call counters.
- `lib/monetization/services/feature_gate_service.dart`: rewarded ad credits now
  require consent before ad loading.
- `lib/monetization/cubit/monetization_cubit.dart`: rewarded ads are loaded only
  after the explicit rewarded-credit request and before show.
- `lib/monetization/widgets/adaptive_banner_ad_slot.dart`: renders the
  abstraction-provided banner child when the real service supplies one.
- `lib/screens/auth/views/auth_gate.dart`: authenticated app startup injects
  `GoogleMobileAdsService` and `GoogleMobileAdsConsentService`.
- `android/app/build.gradle`: added an AdMob app-id manifest placeholder sourced
  from `android/local.properties`, defaulting to Google's sample app ID. Parent
  review also restored Flutter's `applicationName` manifest placeholder so
  release builds merge correctly.
- `android/app/src/main/AndroidManifest.xml`: added required AdMob app ID
  metadata.
- `ios/Runner/Info.plist`: added Google's sample `GADApplicationIdentifier` for
  explicit iOS setup status.
- `test/monetization/monetization_cubit_test.dart`: added assertions for Premium
  zero ad calls and no-consent rewarded blocking.
- `specs/027-production-ads-readiness/admob-release-checklist.md`: added the
  external release setup checklist.
- `specs/027-production-ads-readiness/tasks.md`: marked only completed tasks.

## IDs And Config Decisions

- Debug/test mode uses Google's official sample AdMob app and unit IDs.
- Production ad unit IDs are read from Dart defines and are disabled unless
  `ADMOB_ENABLE_PRODUCTION_ADS=true`.
- Android app ID is read from `android/local.properties` key
  `admob.androidAppId`; if missing, Google's sample app ID is used so debug
  startup remains valid.
- iOS is prepared with the official sample app ID and documented for replacement
  before release.
- No real production ad unit IDs, app IDs, provider secrets, or Premium unlocks
  were committed.

## Worker Commands Not Run

Per instruction, these were not run:

- `flutter pub get`
- `flutter test`
- `flutter analyze`
- `flutter build`
- `flutter gen-l10n`
- `npm test`
- `npm build`
- Any other build or verification command

## Parent Verification

The parent review ran verification after integrating Plans 026, 027, and 028:

- `flutter pub get` passed and resolved `google_mobile_ads 5.3.1`.
- `flutter analyze` passed with no issues.
- `flutter test --reporter expanded --concurrency=1` passed with 186 tests.
- Initial release APK build failed because `manifestPlaceholders` overwrote Flutter's `applicationName` placeholder.
- The parent review fixed `android/app/build.gradle` by adding `applicationName: "android.app.Application"` to `manifestPlaceholders`.
- `flutter build apk --release --no-tree-shake-icons` then passed and produced `build/app/outputs/flutter-apk/app-release.apk`.

## Coordination Notes

- `MonetizationCubit` was changed only where needed for rewarded-ad load order
  and consent gating.
- AI quota UI was not edited.
- Home, Expenses, and Reports screen placement QA remains for the parent worker;
  this pass keeps the production SDK behind the service abstraction and leaves
  device verification unchecked.
- Screen-level ad placements T009-T014 and Android device QA T018 are still open
  because this pass focused on SDK readiness, consent gating, and build safety.
