param(
  [string]$FlutterRoot = "C:\flutter"
)

$ErrorActionPreference = "Stop"
$failures = New-Object System.Collections.Generic.List[string]

function Test-ExclusiveWritableFile {
  param([Parameter(Mandatory = $true)][string]$Path)

  try {
    $directory = Split-Path -Parent $Path
    if (-not (Test-Path $directory)) {
      $failures.Add("Missing directory: $directory")
      return
    }

    $stream = [System.IO.File]::Open(
      $Path,
      [System.IO.FileMode]::OpenOrCreate,
      [System.IO.FileAccess]::ReadWrite,
      [System.IO.FileShare]::None
    )
    $stream.Close()
    Write-Host "OK writable: $Path"
  } catch {
    $failures.Add("Not writable or locked: $Path :: $($_.Exception.Message)")
  }
}

function Test-WritableDirectory {
  param([Parameter(Mandatory = $true)][string]$Path)

  try {
    if (-not (Test-Path $Path)) {
      New-Item -ItemType Directory -Force $Path | Out-Null
    }
    $probe = Join-Path $Path ".codex-write-probe"
    Set-Content -LiteralPath $probe -Value "probe" -NoNewline
    Remove-Item -LiteralPath $probe -Force
    Write-Host "OK writable: $Path"
  } catch {
    $failures.Add("Directory not writable: $Path :: $($_.Exception.Message)")
  }
}

$dartExe = Join-Path $FlutterRoot "bin\cache\dart-sdk\bin\dart.exe"
$flutterCache = Join-Path $FlutterRoot "bin\cache"
$dartToolHome = Join-Path $env:APPDATA ".dart-tool"

Write-Host "Toolchain diagnostic"
Write-Host "Flutter root: $FlutterRoot"

if (-not (Test-Path $dartExe)) {
  $failures.Add("Missing Dart executable: $dartExe")
} else {
  & $dartExe --version
}

Test-ExclusiveWritableFile (Join-Path $flutterCache "flutter.bat.lock")
Test-ExclusiveWritableFile (Join-Path $flutterCache "lockfile")
Test-WritableDirectory $dartToolHome

Write-Host ""
if ($failures.Count -eq 0) {
  Write-Host "Toolchain preflight passed."
  exit 0
}

Write-Host "Toolchain preflight failed:"
foreach ($failure in $failures) {
  Write-Host "- $failure"
}

Write-Host ""
Write-Host "Remediation:"
Write-Host "- Run Flutter commands through an approved/escalated shell, or explicitly approve a machine ACL repair."
Write-Host "- Use tools/verification/safe_dart_format.ps1 for Dart formatting to suppress analytics writes."
Write-Host "- Do not run flutter.bat/dart.bat repeatedly in a restricted shell; they can wait on cache locks silently."
exit 1
