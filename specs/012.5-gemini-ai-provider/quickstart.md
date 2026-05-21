# Quickstart: Gemini AI Provider Integration

## Goal

Validate that a real Gemini 2.5 Flash provider can power the existing AI Assistant without exposing API keys in Flutter and without bypassing preview/confirmation.

## Prerequisites

1. Firebase Authentication is already configured for the app.
2. The developer has a Gemini API key for development testing.
3. The API key is stored only in backend secret management or local backend environment configuration.
4. Flutter source code contains only the gateway endpoint and no provider key.

## Manual Validation Flow

### 1. Configure Development Gateway

- Set provider to `gemini`.
- Set model to `gemini-2.5-flash`.
- Set a low daily user limit such as `5` to validate quota behavior quickly.
- Set timeout to a value such as `10` seconds.

### 2. Run The App

Run:

```powershell
& 'C:\flutter\bin\flutter.bat' pub get
& 'C:\flutter\bin\flutter.bat' analyze
& 'C:\flutter\bin\flutter.bat' test
```

Expected:

- Dependencies resolve.
- Analyzer reports no issues.
- Existing and new tests pass.

### 3. Validate Arabic Add Expense Prompt

Input:

```text
صرفت 250 جنيه على أكل امبارح بالكاش
```

Expected preview:

- Intent: `add_expense`
- Amount: `250`
- Category: `Food` or the existing local Food category
- Date: yesterday relative to the app date
- Payment method: `Cash`
- Currency: `EGP`
- Needs confirmation: true

Expected safety result:

- No expense exists until the user presses Confirm.
- Confirmed expense has `ExpenseSource.ai`.

### 4. Validate Low Confidence / Missing Data

Input:

```text
سجل اللي دفعته امبارح
```

Expected:

- App asks for clarification because amount/category/payment method are missing.
- No expense is created.

### 5. Validate Quota Exhaustion

Submit prompts until the configured user daily limit is reached.

Expected:

- Gateway returns `quota_exceeded`.
- App displays a recoverable error.
- Manual Add Expense remains available.

### 6. Validate No API Key In Flutter

Search:

```powershell
rg "AIza|GEMINI|GOOGLE_API_KEY|OPENAI_API_KEY|OPENROUTER_API_KEY" lib android ios web windows linux macos
```

Expected:

- No provider secret appears in Flutter source or platform folders.

### 7. Validate Provider Swap

Switch provider factory to mock mode in development configuration.

Expected:

- AI Assistant tests still pass.
- No UI, Cubit, or repository files need to change for the provider swap.
