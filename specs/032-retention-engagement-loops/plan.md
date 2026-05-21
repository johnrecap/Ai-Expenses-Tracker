# Implementation Plan: Retention And Engagement Loops

**Branch**: `032-retention-engagement-loops` | **Date**: 2026-05-17 | **Spec**: `specs/032-retention-engagement-loops/spec.md`  
**Input**: Add non-AI engagement loops that make users return: daily check-in, streaks, weekly digest, and spending health score.

## Summary

Build local, explainable engagement features on top of existing expenses, settings, reports, and notifications. These features must not consume Gemini/API quota and must stay optional.

## Technical Context

**Language/Version**: Dart 3.x, Flutter  
**Primary Dependencies**: Existing notification services, Bloc/Cubit, report calculators, settings repository  
**Storage**: User settings/profile; optional user-scoped engagement summary if persistence is needed  
**Testing**: Calculator/service unit tests, Settings widget tests, notification scheduler tests  
**Target Platform**: Android/mobile first  
**Project Type**: Flutter app  
**Performance Goals**: Digest and score compute quickly from existing in-memory/report data  
**Constraints**: No AI provider calls; user can disable reminders; no notification permission hard block  
**Scale/Scope**: Settings controls, Home widgets, digest screen/panel, local notification schedule

## Constitution Check

- Notification preferences live inside `UserSettings.notificationSettings`.
- Reports must be calculated by `ReportCalculator`.
- AI quotas must not be used for local engagement insights.
- User settings access must go through `SettingsRepository`.

## Project Structure

```text
lib/services/notifications/
lib/screens/settings/
lib/screens/home/
lib/reports or existing report services
lib/engagement/
test/engagement/
```

**Structure Decision**: Add a focused `lib/engagement` or equivalent feature folder for streak, digest, and score calculators; keep notification scheduling in existing notification service layer.

## Implementation Notes

- MVP should be daily check-in settings plus streak display.
- Weekly digest can be a panel/screen before adding scheduled notification.
- Health score should expose reasons, not just a number.
- Avoid gamification that hides finance clarity; keep it practical.

## Risks

- Too many reminders can annoy users. Mitigation: disabled by default or easy toggle with clear time control.
- Score can feel judgmental. Mitigation: factual labels and user-controlled visibility.
- Local calculations may be slow on large data. Mitigation: reuse report calculations and date-scoped reads.
