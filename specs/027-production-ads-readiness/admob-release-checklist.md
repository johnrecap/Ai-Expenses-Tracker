# AdMob Release Checklist

Use this checklist before enabling production ads. Keep test IDs active until
the AdMob app and ad units are approved.

## External AdMob Setup

- Create one AdMob app per platform.
- Android package name: `com.saeeddevstudio.ai_expenses_tracker`.
- iOS bundle id: use the final App Store bundle id from Xcode.
- Create separate ad units for:
  - Banner: Home, Expenses, Reports placements may share one banner unit at
    launch.
  - Interstitial: export success and rare post-save completion moments.
  - Rewarded: one extra AI use after reward callback.
- Configure privacy messages in AdMob/User Messaging Platform for regions that
  require consent.
- Publish and verify `app-ads.txt` for the final developer website.
- Add the Play Console advertising ID declaration when ads are enabled.

## Build-Time Configuration

Android app ID is read from `android/local.properties`:

```properties
admob.androidAppId=ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY
```

If omitted, Android uses Google's sample app ID so debug builds can start. Real
release serving still stays disabled unless production ad unit IDs are supplied
with Dart defines.

iOS currently contains Google's sample app ID in `ios/Runner/Info.plist`.
Replace `GADApplicationIdentifier` with the iOS AdMob app ID before release.

Production ad requests are disabled by default. Enable them only when all
production unit IDs are available:

```text
--dart-define=ADMOB_ENABLE_PRODUCTION_ADS=true
--dart-define=ADMOB_ANDROID_BANNER_UNIT_ID=ca-app-pub-XXXXXXXXXXXXXXXX/BBBBBBBBBB
--dart-define=ADMOB_ANDROID_INTERSTITIAL_UNIT_ID=ca-app-pub-XXXXXXXXXXXXXXXX/IIIIIIIIII
--dart-define=ADMOB_ANDROID_REWARDED_UNIT_ID=ca-app-pub-XXXXXXXXXXXXXXXX/RRRRRRRRRR
--dart-define=ADMOB_IOS_BANNER_UNIT_ID=ca-app-pub-XXXXXXXXXXXXXXXX/BBBBBBBBBB
--dart-define=ADMOB_IOS_INTERSTITIAL_UNIT_ID=ca-app-pub-XXXXXXXXXXXXXXXX/IIIIIIIIII
--dart-define=ADMOB_IOS_REWARDED_UNIT_ID=ca-app-pub-XXXXXXXXXXXXXXXX/RRRRRRRRRR
```

Do not commit real ad unit IDs or account secrets to source control.

## Debug/Test IDs

Debug builds use Google's official sample ad unit IDs:

- Android app ID: `ca-app-pub-3940256099942544~3347511713`
- iOS app ID: `ca-app-pub-3940256099942544~1458002511`
- Android banner: `ca-app-pub-3940256099942544/6300978111`
- iOS banner: `ca-app-pub-3940256099942544/2934735716`
- Android interstitial: `ca-app-pub-3940256099942544/1033173712`
- iOS interstitial: `ca-app-pub-3940256099942544/4411468910`
- Android rewarded: `ca-app-pub-3940256099942544/5224354917`
- iOS rewarded: `ca-app-pub-3940256099942544/1712485313`

## QA Before Release

- Confirm Free users with consent can request ads only in approved placements.
- Confirm Premium users do not initialize, load, or show ads.
- Confirm consent unavailable or denied leaves all ad requests blocked.
- Confirm Add Expense, AI preview/confirmation, Auth, App Lock, purchase, and
  error recovery flows have no ads.
- Confirm interstitials obey the 10-minute/session/save frequency caps.
- Confirm rewarded AI credit is granted only from the reward callback.
- Expect real ads to take time to serve after app/ad-unit approval.
