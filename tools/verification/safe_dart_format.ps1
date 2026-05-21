$ErrorActionPreference = "Stop"
$dartExe = "C:\flutter\bin\cache\dart-sdk\bin\dart.exe"
$FormatArgs = $args

if (-not (Test-Path $dartExe)) {
  Write-Error "Dart executable not found at $dartExe"
  exit 1
}

if ($FormatArgs.Count -gt 0 -and $FormatArgs[0] -eq "--") {
  $FormatArgs = $FormatArgs[1..($FormatArgs.Count - 1)]
}

& $dartExe --suppress-analytics format @FormatArgs
exit $LASTEXITCODE
