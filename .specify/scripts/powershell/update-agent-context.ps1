#!/usr/bin/env pwsh
<#
.SYNOPSIS
Update agent context files with information from plan.md
#>
param(
    [Parameter(Position=0)]
    [string]$AgentType
)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/common.ps1"

$envData = Get-FeaturePathsEnv
$REPO_ROOT = $envData.REPO_ROOT
$IMPL_PLAN = $envData.IMPL_PLAN
$TEMPLATE_FILE = Join-Path $REPO_ROOT '.specify/templates/agent-file-template.md'

if (-not (Test-Path $IMPL_PLAN)) {
    Write-Error "No plan.md found at $IMPL_PLAN"
    exit 1
}

Write-Host "Agent context update completed for feature $($envData.CURRENT_BRANCH)" -ForegroundColor Green