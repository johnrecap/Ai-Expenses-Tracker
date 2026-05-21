# Readiness Matrix: Incomplete Feature Surface Readiness

| Feature surface | Current route/widget | State | Risk | Action in this slice |
| --- | --- | --- | --- | --- |
| Premium purchase CTA | `lib/screens/monetization/widgets/premium_cta_panel.dart` | Disabled | Paid operation without trusted backend verification | CTA remains visible for explanation, but buttons are disabled and localized copy says backend verification is not configured. |
| Premium restore | `lib/screens/monetization/widgets/premium_cta_panel.dart` | Disabled | Entitlement restore without server-side verification | Restore button is disabled until trusted backend entitlement restore exists. |
| Premium discovery in Settings | `lib/screens/settings/widgets/monetization_settings_section.dart` | Available as informational surface | Misleading plan state | Settings opens the Free/Premium explanation but describes paid subscriptions as unavailable. |
| Backup export | `lib/screens/settings/widgets/privacy_settings_section.dart` | Coming soon | User could trust an incomplete data portability flow | Privacy settings shows an unavailable row; no export execution is wired. |
| Restore preview | `lib/screens/settings/widgets/privacy_settings_section.dart` | Coming soon | Restore can overwrite or duplicate finance records | Privacy settings explains preview-first requirement; no file picker or mutation path is wired. |
| Restore execution | `lib/screens/settings/widgets/privacy_settings_section.dart` | Disabled | Destructive repository writes without conflict policy/tests | Execution is explicitly blocked and has no callable UI path. |
| Wallet management | `lib/screens/settings/widgets/privacy_settings_section.dart` | Coming soon | Wallet domain exists without coherent user flow | Wallet surface is informational only until list/create/edit/archive and expense assignment are complete. |
| Transfer management | `lib/screens/settings/widgets/privacy_settings_section.dart` | Coming soon | Transfers could be confused with spending or lack currency policy | Transfer surface is informational only; no transfer write UI is exposed. |

## Notes

- No restore writes were implemented in this slice.
- Wallet and transfer full UI was intentionally deferred because the safe minimum is to gate the incomplete surface.
- Existing backup serializer and restore preview services remain available for future tested implementation work, but they are not exposed as destructive user actions.
