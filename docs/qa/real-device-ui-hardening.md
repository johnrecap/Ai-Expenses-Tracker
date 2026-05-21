# Real Device UI Hardening QA

Spec Kit plan: `specs/080-real-device-ui-qa-hardening/`

Use a small Android viewport first, such as 360 x 640 logical pixels or a real
device close to a Pixel 4a/Galaxy A-series size. Capture English and Arabic
screenshots for each section when the parent verification pass runs.

## Settings Bottom Scroll

- Locale: English, then Arabic.
- Steps: open Settings, scroll to the final Support section, stop at the
  natural bottom.
- Expected: the final real section sits near the bottom of the viewport; there
  is no large blank scroll area after Support/Privacy content.
- Evidence: pending parent real-device QA.
- Result: not run in this worker.

## Add Expense With Keyboard

- Locale: English, then Arabic.
- Steps: open Add Expense, select Text capture, focus the AI input, type a long
  Arabic sentence, submit or dismiss; focus Amount, Description, Currency, and
  Payment fields with the keyboard open.
- Expected: AI input, amount, category, settings retry warning, receipt failure
  state, and Save remain reachable by scrolling without closing the keyboard.
- Evidence: pending parent real-device QA.
- Result: not run in this worker.

## Language Refresh

- Steps: from Settings, switch English to Arabic and Arabic to English; without
  restarting, navigate to Expenses or Reports.
- Expected: visible Settings labels update immediately and newly opened routes
  use the selected language.
- Evidence: pending parent real-device QA.
- Result: not run in this worker.

## Finance Card Fit

- Data: long display name, long English category, long Arabic category, large
  EGP amount, mixed USD/EGP expenses, long Arabic description.
- Surfaces: Home spending card, Home transaction rows, Budget card, Reports
  summary/caveat cards, Expenses transaction rows.
- Expected: labels and amounts truncate or wrap cleanly; no amount overlaps
  category, date, menu, or navigation controls.
- Evidence: pending parent real-device QA.
- Result: not run in this worker.

## Parent Verification Commands

This worker intentionally did not run these commands. Parent verification should
run the targeted layout/localization tests, analyzer, and any requested build
artifact after resolving conflicts with parallel plans 077/078/079.
