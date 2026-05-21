# Production device QA checklist

Use a clean Android device or emulator with a release/internal build. Record
results in `docs/qa/qa-run-template.md`.

| Area | Setup / action | Expected result | Pass | Fail | Blocker notes |
| --- | --- | --- | --- | --- | --- |
| Environment | Confirm Firebase project, SHA fingerprints, Worker URL, test user, and test ad IDs | App launches without startup crash |  |  |  |
| Register | Create a new email/password account | User lands on Home with empty state |  |  |  |
| Login | Sign out, then sign in again | Existing account opens Home |  |  |  |
| Google login | Sign in with test Google account | Auth succeeds and data remains user-scoped |  |  |  |
| Add expense | Add amount, category, payment method, and optional note | Expense appears on Home without duplicate writes |  |  |  |
| Categories | Create, edit, and archive a category | Archived category no longer appears for new expense selection |  |  |  |
| Budget | Create monthly budget and warning threshold | Home budget progress updates |  |  |  |
| Category budget | Create a category budget | Category budget screen shows progress |  |  |  |
| Recurring | Add a recurring expense due today | Due item can be applied once |  |  |  |
| Export | Export CSV/PDF | Share sheet opens and exported file has expected rows |  |  |  |
| Reports | Open reports and charts | Totals match current test expenses |  |  |  |
| Settings | Change currency and payment method | New defaults persist after app restart |  |  |  |
| AI parse | Open AI assistant and preview an expense | No write occurs until user confirms |  |  |  |
| Receipt | Capture/select receipt image | Preview excludes automatic expense creation until confirmation |  |  |  |
| Advice | Request financial advice | Advice appears or an honest unavailable state is shown |  |  |  |
| Offline sync | Add expense offline, then reconnect | Sync badge resolves without data loss |  |  |  |
| Notifications | Enable daily reminder and weekly digest | Permissions are requested and settings persist |  |  |  |
| Ads | Trigger ad-eligible surface with test IDs | Test ad loads or fails gracefully |  |  |  |
| Premium | Open premium page | Plan state and CTA render without blocking free tracking |  |  |  |
| App lock | Enable PIN/biometric, background, then resume | Unlock screen protects app and PIN is never logged |  |  |  |
| Feedback | Open Settings > Support > Send feedback | Share sheet opens without expense data attached |  |  |  |
| Logout | Select logout from Home menu | Confirmation appears before sign-out |  |  |  |
| Account deletion - email/password | Create a disposable email/password account with at least one expense, category, budget, recurring rule, saving goal, settings edit, and AI action if available. Wait long enough or force a stale session, then delete from Account/Profile. | Destructive warning appears, password reauth is requested when Firebase requires recent login, user-owned Firestore data is removed before Auth deletion is reported, and the user returns to signed-out state. |  |  |  |
| Account deletion - Google | Create a disposable Google account session with the same user-owned data set, then delete from Account/Profile after a stale session. | Destructive warning appears, Google reauth is requested when Firebase requires recent login, cancellation leaves the account intact, successful reauth retries deletion, and the user returns to signed-out state. |  |  |  |
| Account deletion - failure recovery | Temporarily block network or Firestore writes during deletion, then retry after restoring connectivity. | Data deletion failure does not falsely delete/report Firebase Auth deletion; Auth deletion failure shows recovery copy and allows reauth/retry. |  |  |  |

## Evidence capture

- Capture screenshots for each failure and blocker.
- Save `adb logcat` around crashes or hangs, then redact user identifiers before
  sharing outside the project.
- Do not paste raw expense descriptions, receipt text/images, auth tokens, PINs,
  biometric details, or provider keys into QA notes.
