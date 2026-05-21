# Production AI Setup

## Modes

The Flutter app uses mock/local AI unless `AI_GATEWAY_URL` is provided at build or run time. Real provider-backed AI must go through the Cloudflare Worker gateway. The Flutter client may receive only endpoint, provider name, model name, timeout, and mock fallback flags. It must never contain Gemini, OpenAI, or other provider API keys.

## Flutter Commands

PowerShell:

```powershell
& "C:\flutter\bin\flutter.bat" run --dart-define=AI_GATEWAY_URL=https://<worker>.workers.dev/aiParse --dart-define=AI_PROVIDER=gemini --dart-define=AI_MODEL=gemini-2.5-flash
& "C:\flutter\bin\flutter.bat" build apk --release --dart-define=AI_GATEWAY_URL=https://<worker>.workers.dev/aiParse --dart-define=AI_PROVIDER=gemini --dart-define=AI_MODEL=gemini-2.5-flash
& "C:\flutter\bin\flutter.bat" build appbundle --release --dart-define=AI_GATEWAY_URL=https://<worker>.workers.dev/aiParse --dart-define=AI_PROVIDER=gemini --dart-define=AI_MODEL=gemini-2.5-flash
```

CMD:

```cmd
C:\flutter\bin\flutter.bat run --dart-define=AI_GATEWAY_URL=https://<worker>.workers.dev/aiParse --dart-define=AI_PROVIDER=gemini --dart-define=AI_MODEL=gemini-2.5-flash
C:\flutter\bin\flutter.bat build apk --release --dart-define=AI_GATEWAY_URL=https://<worker>.workers.dev/aiParse --dart-define=AI_PROVIDER=gemini --dart-define=AI_MODEL=gemini-2.5-flash
C:\flutter\bin\flutter.bat build appbundle --release --dart-define=AI_GATEWAY_URL=https://<worker>.workers.dev/aiParse --dart-define=AI_PROVIDER=gemini --dart-define=AI_MODEL=gemini-2.5-flash
```

Optional client defines:

```text
AI_GATEWAY_URL=https://<worker>.workers.dev/aiParse
AI_PROVIDER=gemini
AI_MODEL=gemini-2.5-flash
AI_TIMEOUT_SECONDS=10
AI_USE_MOCK_FALLBACK=false
```

Omitting `AI_GATEWAY_URL` is mock mode. Treat any release artifact built without that define as not production-AI ready.

## Worker Secret

The Gemini provider key belongs only in Cloudflare Worker secrets:

```powershell
npx wrangler secret put GEMINI_API_KEY
npx wrangler deploy --minify
```

Do not add provider keys to Flutter source, Dart defines, `wrangler.toml`, docs, shell history snippets, screenshots, or committed test fixtures.

## Worker Smoke Commands

These examples require a Firebase Auth ID token for a signed-in test user. Replace `<id-token>` and `<worker-url>` locally.

PowerShell:

```powershell
$body = @{
  input = "صرفت 100 جنيه امبارح على المواصلات"
  now = "2026-05-18T00:00:00.000Z"
  locale = "ar-EG"
  defaultCurrency = "EGP"
  defaultPaymentMethod = "Cash"
  clientRequestId = "manual-smoke-001"
  categories = @(@{ categoryId = "transport"; name = "Transport"; isArchived = $false })
} | ConvertTo-Json -Depth 6

curl.exe -sS -X POST "https://<worker-url>/aiParse" -H "Authorization: Bearer <id-token>" -H "Content-Type: application/json; charset=utf-8" --data $body
```

CMD:

```cmd
curl.exe -sS -X POST "https://<worker-url>/aiParse" -H "Authorization: Bearer <id-token>" -H "Content-Type: application/json; charset=utf-8" --data "{\"input\":\"صرفت 100 جنيه امبارح على المواصلات\",\"now\":\"2026-05-18T00:00:00.000Z\",\"locale\":\"ar-EG\",\"defaultCurrency\":\"EGP\",\"defaultPaymentMethod\":\"Cash\",\"clientRequestId\":\"manual-smoke-001\",\"categories\":[{\"categoryId\":\"transport\",\"name\":\"Transport\",\"isArchived\":false}]}"
```

Expected success: JSON with `ok: true`, `provider`, `model`, `requestId`, `structuredJson`, and `quota`.

Common failures:

- `401` or `403`: missing, expired, or invalid Firebase ID token. Sign in again and retry with a fresh ID token.
- `quota_exceeded`: daily Worker quota is exhausted. The response should include quota reset metadata.
- `provider_timeout` or `provider_unavailable`: Gemini or the Worker/provider path is temporarily unavailable. Manual expense entry should still work.
- `gateway_misconfigured`: check Worker bindings and `GEMINI_API_KEY` secret.

## Device QA Checklist

- Build/run with `--dart-define=AI_GATEWAY_URL=<worker-url>/aiParse`.
- Sign in with Firebase Auth on the Android device.
- Open AI Assistant and confirm the internal debug status says gateway mode, not mock fallback.
- Parse `صرفت 100 جنيه امبارح على المواصلات`.
- Verify the preview selects an active Transport category or clearly suggests category creation.
- Confirm the preview and verify the expense is saved through the normal expense flow.
- Trigger or simulate quota/provider failure if a safe fixture is available.
- Confirm manual Add Expense and local reports still work after AI failure.

Blocker for Worker 038: real-device Worker QA was not run because this task explicitly forbids build/test/run commands in this pass.

## Secret Scan Checklist

Before public release, scan committed files for provider secrets:

```powershell
rg "GEMINI_API_KEY|AIza|OPENAI_API_KEY|GOOGLE_API_KEY|OPENROUTER_API_KEY|provider key|api key" lib docs workers specs test
```

Review any hits manually. Mentions of secret names in docs/tests are acceptable only when they do not include real secret values. Firebase client API keys are not Gemini provider keys, but they should still be restricted in Google Cloud by package name, SHA certificate, and allowed APIs.

If a provider key leaks:

1. Revoke or rotate the key in the provider console immediately.
2. Run `npx wrangler secret put GEMINI_API_KEY` with the new key.
3. Redeploy the Worker.
4. Remove leaked values from files, chat transcripts, terminal logs, and screenshots where possible.
5. Re-run the scan and verify the Worker still returns provider-backed AI responses.
