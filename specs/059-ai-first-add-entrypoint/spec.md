# Feature Specification: AI-Assisted Add Expense Form

**Feature Branch**: `059-ai-first-add-entrypoint`
**Created**: 2026-05-19
**Status**: Draft
**Input**: User clarifies that the plus button should keep the existing Add Expense screen internally, but place an AI widget above the manual form and automatically apply the AI result into the form fields.

## User Scenarios & Testing

### User Story 1 - Plus Button Opens Existing Add Screen With AI On Top (Priority: P1)

As a user, I want the central plus button to open the normal Add Expense screen with an AI input widget at the top, so I can describe the expense naturally while still seeing and editing the same manual fields underneath.

**Independent Test**: Tap the central plus button on Home and verify the existing Add Expense screen opens, with an AI entry widget above the amount/category/payment/currency/date form.

### User Story 2 - AI Result Auto-Fills The Manual Form (Priority: P1)

As a user, I want the AI result to be applied directly into the visible manual form fields, so I can quickly review and save without retyping the parsed amount, category, currency, payment method, date, or description.

**Independent Test**: Type "spent 100 dollar on food last night" in the AI widget and verify the manual form fields are populated with amount `100`, currency `USD`, category Food, yesterday's date, and a default/parsed payment method.

### User Story 3 - Manual Save Remains The Final Commit (Priority: P1)

As a user, I want AI to fill the form but not silently save to my expenses, so I can correct anything wrong before committing the transaction.

**Independent Test**: Let AI fill the form, edit one field manually, press Save, and verify exactly one expense is saved with the final visible form values.

## Requirements

### Functional Requirements

- **FR-001**: The Home central plus button MUST keep opening the existing Add Expense screen route and provider stack.
- **FR-002**: The Add Expense screen MUST render an AI input widget above the manual form.
- **FR-003**: The AI widget MUST parse user input through the existing AI service/cubit path and convert a successful add-expense result into form-field updates.
- **FR-004**: AI output MUST auto-fill the visible manual fields, including amount, description, category when resolvable, payment method, currency, and date when known.
- **FR-005**: Missing or unknown AI fields MUST remain editable/blank/defaulted in the manual form and must not block manual entry.
- **FR-006**: Saving MUST still require the existing Add Expense Save button; AI must not write an expense directly or auto-save without the user's final action.
- **FR-007**: If AI settings are missing, quota is exhausted, or gateway fails, the manual form MUST remain fully usable on the same screen.
- **FR-008**: After saving, Home MUST refresh expenses and ad/engagement completion tracking as it does today.
- **FR-009**: The existing top sparkle AI shortcut SHOULD remain available for broader assistant commands unless implementation reveals duplication that should be simplified.
- **FR-010**: The guided tour target for manual entry MUST explain the AI-assisted form-fill behavior.
- **FR-011**: All new labels and helper text MUST be localized in English and Arabic.

### Product Decision

Recommended direction: keep the center plus button's destination as the existing Add Expense screen, but make the first visible control an AI widget that fills the form. This gives AI priority without replacing the reliable manual workflow.

### Key Entities

- **AI Form Fill Widget**: A compact AI input surface embedded at the top of Add Expense.
- **Form Fill Result**: Parsed AI output mapped into Add Expense controllers and selected values.
- **Manual Add Form**: The existing Add Expense fields and Save button that remain the final commit path.

## Success Criteria

- **SC-001**: Tapping plus opens the existing Add Expense form with the AI widget visible above the amount field.
- **SC-002**: A natural-language AI parse fills at least amount, currency, category, date, payment method, and description when those values are known.
- **SC-003**: Users can edit AI-filled fields before pressing Save.
- **SC-004**: No expense is saved until the user presses the existing Save button.
- **SC-005**: Home refreshes after the existing Add Expense save path succeeds.

## Assumptions

- Existing AI parsing services/cubits can be reused, but the embedded Add Expense widget should apply parsed results into the form instead of opening a separate preview sheet.
- The manual Add Expense screen remains the authoritative save surface.
- "Automatically add the result" means automatically populate the form fields, not silently create a Firestore expense.

## Out of Scope

- Removing manual entry.
- Auto-saving AI expenses without pressing Save.
- Redesigning the whole Home navigation.
- Changing AI quota policy.
