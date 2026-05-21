<#
.SYNOPSIS
    Setup all agent skills for Codex and Antigravity in any project.
.DESCRIPTION
    Run this script from any project root to:
    1. Install skill packs via npx skills add
    2. Create all 7 bridge skills for both agents
    3. Add .osgrep and .memsearch to .gitignore
    4. Setup .specify (Spec-Driven Development) with scripts and templates
    5. Create mandatory development workflow for both agents
    6. Create skill matcher config
    7. Enforce MANDATORY skill usage â€” agents MUST use skills for ALL tasks
.USAGE
    cd E:\your-project
    powershell -ExecutionPolicy Bypass -File path\to\setup-agent-skills.ps1
#>

$ErrorActionPreference = "Continue"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Agent Skills Setup - Codex & Antigravity" -ForegroundColor Cyan
Write-Host "  (Full Setup with Mandatory Enforcement)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# â”€â”€ Step 1: Create directories â”€â”€
Write-Host "[1/9] Creating skill directories..." -ForegroundColor Yellow

$dirs = @(
    ".agents\skills",
    ".agents\workflows",
    ".agent\skills",
    ".agent\workflows",
    "docs\agent-playbooks"
)
foreach ($d in $dirs) {
    if (-not (Test-Path $d)) {
        New-Item -ItemType Directory -Path $d -Force | Out-Null
        Write-Host "  + Created $d" -ForegroundColor Green
    } else {
        Write-Host "  = $d already exists" -ForegroundColor DarkGray
    }
}

# â”€â”€ Step 2: Install skill packs â”€â”€
Write-Host ""
Write-Host "[2/9] Installing skill packs via npx skills add..." -ForegroundColor Yellow
Write-Host "  (This may take a few minutes)" -ForegroundColor DarkGray

$packs = @(
    @{ repo = "phuryn/pm-skills";      args = "--skill '*' -a codex -a antigravity -y" },
    @{ repo = "Dimillian/Skills";      args = "--skill '*' -a codex -a antigravity -y" },
    @{ repo = "obra/superpowers";      args = "-a codex -a antigravity -y" },
    @{ repo = "googleworkspace/cli";   args = "-a codex -a antigravity -y" },
    @{ repo = "openai/skills";         args = "--skill '*' -a codex -a antigravity -y" }
)

foreach ($pack in $packs) {
    Write-Host "  Installing $($pack.repo)..." -ForegroundColor White
    $cmd = "npx -y skills add $($pack.repo) $($pack.args)"
    try {
        Invoke-Expression $cmd 2>&1 | Out-Null
        Write-Host "    OK" -ForegroundColor Green
    } catch {
        Write-Host "    FAILED - $($_.Exception.Message)" -ForegroundColor Red
    }
}

# â”€â”€ Step 3: Create bridge skills â”€â”€
Write-Host ""
Write-Host "[3/9] Creating 7 bridge skills..." -ForegroundColor Yellow

$bridgeSkills = @{}

# --- semantic-code-search ---
$bridgeSkills["semantic-code-search"] = @"
---
name: semantic-code-search
description: >
  Use when the user needs to understand how code works, where a behavior is implemented,
  or how different parts of the codebase connect. Covers code exploration, architecture
  understanding, implementation discovery, and tracing how data flows through the system.
  Prefer this over grep when the user describes what code DOES rather than what it CONTAINS.
---
# Semantic Code Search via osgrep

## Prerequisites
- ``osgrep`` must be installed globally: ``npm i -g osgrep``
- The codebase must be indexed first

## When to Use
- User wants to understand how a feature or behavior is implemented
- User is exploring unfamiliar code and needs to find where something happens
- User describes a capability or behavior and wants to locate the code responsible
- User asks about code architecture, data flow, or how components interact
- User is debugging and needs to find all code related to a specific concern
- User needs to understand dependencies or relationships between modules

## When NOT to Use
- User gives an exact string, variable name, or error message to search for - use grep
- User asks to read a specific file they already know the path of - use file tools
- User asks a general question that does not require looking at code - answer directly

## Steps
1. Check if the index exists: ``osgrep list``
2. If not indexed, run: ``osgrep index``
3. Search: ``osgrep search "<user query>"``
4. Present results with file paths and relevant snippets
5. Offer to open or explain the matching code
"@

# --- persistent-memory ---
$bridgeSkills["persistent-memory"] = @"
---
name: persistent-memory
description: >
  Use when the user needs continuity across sessions - saving decisions, recalling past context,
  or building a shared knowledge base about the project. Covers architectural decisions,
  design rationale, meeting notes, agreed-upon conventions, and any information the user
  wants to persist beyond the current conversation.
---
# Persistent Memory via memsearch

## Prerequisites
- ``memsearch`` must be installed: ``pip install memsearch``
- Config must be initialized: ``memsearch config init``

## When to Use
- User makes a decision they will need to reference later
- User discusses architecture, conventions, or patterns they want documented
- User needs to recall something discussed in a previous session
- User is building up project knowledge incrementally over time

## Steps
1. To save: ``memsearch index --input "<markdown content>"``
2. To recall: ``memsearch search "<query>"``
3. To see stats: ``memsearch stats``
"@

# --- stable-local-urls ---
$bridgeSkills["stable-local-urls"] = @"
---
name: stable-local-urls
description: >
  Use when the user needs predictable local development URLs instead of port numbers.
  Covers multi-service development, sharing local URLs between tools or agents,
  and any situation where port numbers are inconvenient, forgettable, or need to be
  referenced consistently across configurations.
---
# Stable Local URLs via portless

## Prerequisites
- ``portless`` must be installed: ``npm i -g portless``

## Steps
1. Start the dev server: ``npm run dev``
2. Map it: ``portless add my-app 3000``
3. Access at: ``https://my-app.localhost``
4. List mappings: ``portless list``
5. Remove: ``portless remove my-app``
"@

# --- mobile-agent-qa ---
$bridgeSkills["mobile-agent-qa"] = @"
---
name: mobile-agent-qa
description: >
  Use when the user needs to interact with, test, or automate anything on a physical
  Android device. Covers QA testing, UI verification, flow automation, accessibility
  checks, and any task that requires controlling a real mobile device through
  natural language instead of manual tapping.
---
# Mobile QA Automation via droidrun

## Prerequisites
- ``droidrun`` must be installed: ``pip install droidrun``
- ADB must be set up and the device must be connected

## Steps
1. Verify device: ``adb devices``
2. Run task: ``droidrun "<natural language instruction>"``
3. Report results and any screenshots captured
"@

# --- parallel-agent-control ---
$bridgeSkills["parallel-agent-control"] = @"
---
name: parallel-agent-control
description: >
  Use when the user has multiple independent tasks that would benefit from simultaneous
  execution by separate agent instances. Covers workload splitting, parallel development
  tracks, and any situation where waiting for sequential completion is inefficient.
  macOS only; requires Codex or Claude Code CLI.
---
# Parallel Agent Sessions via FleetCode

## Prerequisites
- FleetCode must be installed
- macOS only

## Steps
1. Open FleetCode app
2. Create sessions for each parallel task
3. Monitor progress via the FleetCode control pane
4. Report results from each session
"@

# --- codex-ci-review ---
$bridgeSkills["codex-ci-review"] = @"
---
name: codex-ci-review
description: >
  Use when the user wants to automate code quality checks in their CI/CD pipeline
  using AI-powered review. Covers PR review automation, code quality gates,
  automated suggestions on pull requests, and any GitHub Actions integration
  that uses Codex for code analysis.
---
# Automated CI Review via codex-action

## Prerequisites
- Repository must be on GitHub
- OPENAI_API_KEY must be set as a GitHub secret

## Steps
1. Create .github/workflows/codex-review.yml with the codex-action
2. Add OPENAI_API_KEY to GitHub repository secrets
3. Test with a new PR
"@

# --- workspace-ops ---
$bridgeSkills["workspace-ops"] = @"
---
name: workspace-ops
description: >
  Use when the user needs to interact with any Google Workspace service programmatically.
  Covers file management (Drive), communication (Gmail, Chat), scheduling (Calendar),
  data operations (Sheets), document creation (Docs), and administration tasks.
  Acts as the bridge between coding agent workflows and Google Workspace.
---
# Google Workspace Operations via gws CLI

## Prerequisites
- gws must be installed: see https://github.com/googleworkspace/cli
- Authentication must be configured (OAuth or service account)

## Steps
1. Authenticate: ``gws auth login``
2. Drive: ``gws drive files list``
3. Gmail: ``gws gmail messages send``
4. Calendar: ``gws calendar events list``
5. Sheets: ``gws sheets spreadsheets values get``
"@

# Write bridge skills to both agent paths
foreach ($name in $bridgeSkills.Keys) {
    foreach ($agentDir in @(".agents\skills", ".agent\skills")) {
        $skillDir = Join-Path $agentDir $name
        if (-not (Test-Path $skillDir)) {
            New-Item -ItemType Directory -Path $skillDir -Force | Out-Null
        }
        $skillFile = Join-Path $skillDir "SKILL.md"
        $bridgeSkills[$name] | Set-Content -Path $skillFile -Encoding UTF8 -NoNewline
    }
    Write-Host "  + $name (both agents)" -ForegroundColor Green
}

# â”€â”€ Step 4: Update .gitignore â”€â”€
Write-Host ""
Write-Host "[4/9] Updating .gitignore..." -ForegroundColor Yellow

$gitignorePath = ".gitignore"
$entries = @(".osgrep", ".memsearch")

if (Test-Path $gitignorePath) {
    $content = Get-Content $gitignorePath -Raw
    foreach ($entry in $entries) {
        if ($content -notmatch [regex]::Escape($entry)) {
            Add-Content -Path $gitignorePath -Value "`n$entry"
            Write-Host "  + Added $entry to .gitignore" -ForegroundColor Green
        } else {
            Write-Host "  = $entry already in .gitignore" -ForegroundColor DarkGray
        }
    }
} else {
    $entries -join "`n" | Set-Content -Path $gitignorePath -Encoding UTF8
    Write-Host "  + Created .gitignore with agent entries" -ForegroundColor Green
}

# â”€â”€ Step 5: Setup .specify (Spec-Driven Development) â”€â”€
Write-Host ""
Write-Host "[5/9] Setting up .specify (Spec-Driven Development)..." -ForegroundColor Yellow

$specifyDirs = @(
    ".specify",
    ".specify\memory",
    ".specify\scripts",
    ".specify\scripts\powershell",
    ".specify\templates"
)
foreach ($d in $specifyDirs) {
    if (-not (Test-Path $d)) {
        New-Item -ItemType Directory -Path $d -Force | Out-Null
        Write-Host "  + Created $d" -ForegroundColor Green
    }
}

# Create constitution template if not exists
$constitutionPath = ".specify\memory\constitution.md"
if (-not (Test-Path $constitutionPath)) {
    $constitutionContent = @"
# [PROJECT_NAME] Constitution

> **âڑ ï¸ڈ AUTO-FILL REQUIRED**: If you see [FILL_IN] placeholders below, you MUST analyze the project
> and fill them in BEFORE doing any other work. Use the ``auto-constitution`` skill.

## Rule 0: SKILL-FIRST â€” ABSOLUTE, NON-NEGOTIABLE

**BEFORE touching ANY code, modifying ANY file, or making ANY change, you MUST:**

1. Read this constitution
2. Read ``.agents/workflows/development.md``
3. Read ``.agents/skill-matcher.json``
4. Match the user's request to skills
5. Read the SKILL.md for EACH matched skill
6. Announce which skills you are using and why

**VIOLATION = FAILURE. No exceptions. No quick fixes. No "it's just a small change."**

## Rule 1: Mandatory Spec-Driven Development

ALL changes â€” regardless of size â€” MUST follow the speckit workflow:
- ``speckit-specify`` â†’ Create spec.md
- ``speckit-plan`` â†’ Create plan.md
- ``speckit-tasks`` â†’ Create tasks.md
- ``speckit-implement`` â†’ Execute tasks

**Even a 1-line fix requires at minimum: reading the spec, documenting what changed, and verifying.**

## Rule 2: Architecture

- **Language**: [FILL_IN]
- **Framework**: [FILL_IN]
- **State Management**: [FILL_IN]
- **Routing/Navigation**: [FILL_IN]
- **UI Framework/Widgets**: [FILL_IN]
- **Fonts**: [FILL_IN]
- **Storage/Database**: [FILL_IN]
- **Build System**: [FILL_IN]
- **Target Platforms**: [FILL_IN]

## Rule 3: Localization

All user-facing text MUST use the project's localization system. Never hardcode strings.

## Rule 4: Verification (NEVER SKIP)

Run project-specific build/lint/test commands before claiming done.

## Rule 5: User Instructions

- User instructions override all other rules
- Ask for clarification if uncertain, never assume

## Rule 6: Constitution Auto-Update (MANDATORY)

**After completing ANY feature, fix, or modification, you MUST update this file:**

1. If any [FILL_IN] placeholders remain â†’ fill them by analyzing the project
2. If new technologies/packages were added â†’ update Rule 2: Architecture
3. If new patterns/conventions were established â†’ add them here
4. If new features were implemented â†’ update the Known Features section
5. Update the "Last Updated" date at the bottom

**This keeps the constitution as a living document that always reflects the current project state.**

## Known Features

[FILL_IN: List the main features/modules of the project. Update after each new feature.]

## Project Conventions

[FILL_IN: Document coding conventions, naming patterns, file organization rules discovered during work.]

**Version**: 1.0.0 | **Ratified**: $(Get-Date -Format 'yyyy-MM-dd') | **Last Updated**: $(Get-Date -Format 'yyyy-MM-dd')
"@
    $constitutionContent | Set-Content -Path $constitutionPath -Encoding UTF8 -NoNewline
    Write-Host "  + Created constitution.md template" -ForegroundColor Green
} else {
    Write-Host "  = constitution.md already exists" -ForegroundColor DarkGray
}

# Create init-options.json if not exists
$initOptionsPath = ".specify\init-options.json"
if (-not (Test-Path $initOptionsPath)) {
    $initOptions = @"
{
  "specsDir": "specs",
  "constitutionPath": ".specify/memory/constitution.md",
  "autoSkillMatch": true
}
"@
    $initOptions | Set-Content -Path $initOptionsPath -Encoding UTF8 -NoNewline
    Write-Host "  + Created init-options.json" -ForegroundColor Green
}

# â”€â”€ Step 5b: Create .specify PowerShell scripts â”€â”€
Write-Host ""
Write-Host "[5b/9] Creating .specify PowerShell scripts..." -ForegroundColor Yellow

# --- common.ps1 ---
$commonPs1Path = ".specify\scripts\powershell\common.ps1"
if (-not (Test-Path $commonPs1Path)) {
    $commonPs1 = @'
#!/usr/bin/env pwsh
# Common PowerShell functions analogous to common.sh

function Get-RepoRoot {
    try {
        $result = git rev-parse --show-toplevel 2>$null
        if ($LASTEXITCODE -eq 0) {
            return $result
        }
    } catch {
        # Git command failed
    }
    
    # Fall back to script location for non-git repos
    return (Resolve-Path (Join-Path $PSScriptRoot "../../..")).Path
}

function Get-CurrentBranch {
    # First check if SPECIFY_FEATURE environment variable is set
    if ($env:SPECIFY_FEATURE) {
        return $env:SPECIFY_FEATURE
    }
    
    # Then check git if available
    try {
        $result = git rev-parse --abbrev-ref HEAD 2>$null
        if ($LASTEXITCODE -eq 0) {
            return $result
        }
    } catch {
        # Git command failed
    }
    
    # For non-git repos, try to find the latest feature directory
    $repoRoot = Get-RepoRoot
    $specsDir = Join-Path $repoRoot "specs"
    
    if (Test-Path $specsDir) {
        $latestFeature = ""
        $highest = 0
        
        Get-ChildItem -Path $specsDir -Directory | ForEach-Object {
            if ($_.Name -match '^(\d{3})-') {
                $num = [int]$matches[1]
                if ($num -gt $highest) {
                    $highest = $num
                    $latestFeature = $_.Name
                }
            }
        }
        
        if ($latestFeature) {
            return $latestFeature
        }
    }
    
    # Final fallback
    return "main"
}

function Test-HasGit {
    try {
        git rev-parse --show-toplevel 2>$null | Out-Null
        return ($LASTEXITCODE -eq 0)
    } catch {
        return $false
    }
}

function Test-FeatureBranch {
    param(
        [string]$Branch,
        [bool]$HasGit = $true
    )
    
    if (-not $HasGit) {
        Write-Warning "[specify] Warning: Git repository not detected; skipped branch validation"
        return $true
    }
    
    if ($Branch -notmatch '^[0-9]{3}-') {
        Write-Output "ERROR: Not on a feature branch. Current branch: $Branch"
        Write-Output "Feature branches should be named like: 001-feature-name"
        return $false
    }
    return $true
}

function Get-FeatureDir {
    param([string]$RepoRoot, [string]$Branch)
    Join-Path $RepoRoot "specs/$Branch"
}

function Get-FeaturePathsEnv {
    $repoRoot = Get-RepoRoot
    $currentBranch = Get-CurrentBranch
    $hasGit = Test-HasGit
    $featureDir = Get-FeatureDir -RepoRoot $repoRoot -Branch $currentBranch
    
    [PSCustomObject]@{
        REPO_ROOT     = $repoRoot
        CURRENT_BRANCH = $currentBranch
        HAS_GIT       = $hasGit
        FEATURE_DIR   = $featureDir
        FEATURE_SPEC  = Join-Path $featureDir 'spec.md'
        IMPL_PLAN     = Join-Path $featureDir 'plan.md'
        TASKS         = Join-Path $featureDir 'tasks.md'
        RESEARCH      = Join-Path $featureDir 'research.md'
        DATA_MODEL    = Join-Path $featureDir 'data-model.md'
        QUICKSTART    = Join-Path $featureDir 'quickstart.md'
        CONTRACTS_DIR = Join-Path $featureDir 'contracts'
    }
}

function Test-FileExists {
    param([string]$Path, [string]$Description)
    if (Test-Path -Path $Path -PathType Leaf) {
        Write-Output "  âœ“ $Description"
        return $true
    } else {
        Write-Output "  âœ— $Description"
        return $false
    }
}

function Test-DirHasFiles {
    param([string]$Path, [string]$Description)
    if ((Test-Path -Path $Path -PathType Container) -and (Get-ChildItem -Path $Path -ErrorAction SilentlyContinue | Where-Object { -not $_.PSIsContainer } | Select-Object -First 1)) {
        Write-Output "  âœ“ $Description"
        return $true
    } else {
        Write-Output "  âœ— $Description"
        return $false
    }
}

function Resolve-Template {
    param(
        [Parameter(Mandatory=$true)][string]$TemplateName,
        [Parameter(Mandatory=$true)][string]$RepoRoot
    )

    $base = Join-Path $RepoRoot '.specify/templates'

    $override = Join-Path $base "overrides/$TemplateName.md"
    if (Test-Path $override) { return $override }

    $presetsDir = Join-Path $RepoRoot '.specify/presets'
    if (Test-Path $presetsDir) {
        $registryFile = Join-Path $presetsDir '.registry'
        $sortedPresets = @()
        if (Test-Path $registryFile) {
            try {
                $registryData = Get-Content $registryFile -Raw | ConvertFrom-Json
                $presets = $registryData.presets
                if ($presets) {
                    $sortedPresets = $presets.PSObject.Properties |
                        Sort-Object { if ($null -ne $_.Value.priority) { $_.Value.priority } else { 10 } } |
                        ForEach-Object { $_.Name }
                }
            } catch {
                $sortedPresets = @()
            }
        }

        if ($sortedPresets.Count -gt 0) {
            foreach ($presetId in $sortedPresets) {
                $candidate = Join-Path $presetsDir "$presetId/templates/$TemplateName.md"
                if (Test-Path $candidate) { return $candidate }
            }
        } else {
            foreach ($preset in Get-ChildItem -Path $presetsDir -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -notlike '.*' }) {
                $candidate = Join-Path $preset.FullName "templates/$TemplateName.md"
                if (Test-Path $candidate) { return $candidate }
            }
        }
    }

    $extDir = Join-Path $RepoRoot '.specify/extensions'
    if (Test-Path $extDir) {
        foreach ($ext in Get-ChildItem -Path $extDir -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -notlike '.*' } | Sort-Object Name) {
            $candidate = Join-Path $ext.FullName "templates/$TemplateName.md"
            if (Test-Path $candidate) { return $candidate }
        }
    }

    $core = Join-Path $base "$TemplateName.md"
    if (Test-Path $core) { return $core }

    return $null
}
'@
    $commonPs1 | Set-Content -Path $commonPs1Path -Encoding UTF8 -NoNewline
    Write-Host "  + Created common.ps1" -ForegroundColor Green
} else {
    Write-Host "  = common.ps1 already exists" -ForegroundColor DarkGray
}

# --- check-prerequisites.ps1 ---
$checkPrereqPath = ".specify\scripts\powershell\check-prerequisites.ps1"
if (-not (Test-Path $checkPrereqPath)) {
    $checkPrereqContent = @'
#!/usr/bin/env pwsh
[CmdletBinding()]
param(
    [switch]$Json,
    [switch]$RequireTasks,
    [switch]$IncludeTasks,
    [switch]$PathsOnly,
    [switch]$Help
)

$ErrorActionPreference = 'Stop'

if ($Help) {
    Write-Output "Usage: check-prerequisites.ps1 [-Json] [-RequireTasks] [-IncludeTasks] [-PathsOnly] [-Help]"
    exit 0
}

. "$PSScriptRoot/common.ps1"

$paths = Get-FeaturePathsEnv

if (-not (Test-FeatureBranch -Branch $paths.CURRENT_BRANCH -HasGit:$paths.HAS_GIT)) { 
    exit 1 
}

if ($PathsOnly) {
    if ($Json) {
        [PSCustomObject]@{
            REPO_ROOT    = $paths.REPO_ROOT
            BRANCH       = $paths.CURRENT_BRANCH
            FEATURE_DIR  = $paths.FEATURE_DIR
            FEATURE_SPEC = $paths.FEATURE_SPEC
            IMPL_PLAN    = $paths.IMPL_PLAN
            TASKS        = $paths.TASKS
        } | ConvertTo-Json -Compress
    } else {
        Write-Output "REPO_ROOT: $($paths.REPO_ROOT)"
        Write-Output "BRANCH: $($paths.CURRENT_BRANCH)"
        Write-Output "FEATURE_DIR: $($paths.FEATURE_DIR)"
    }
    exit 0
}

if (-not (Test-Path $paths.FEATURE_DIR -PathType Container)) {
    Write-Output "ERROR: Feature directory not found: $($paths.FEATURE_DIR)"
    exit 1
}

if (-not (Test-Path $paths.IMPL_PLAN -PathType Leaf)) {
    Write-Output "ERROR: plan.md not found in $($paths.FEATURE_DIR)"
    exit 1
}

if ($RequireTasks -and -not (Test-Path $paths.TASKS -PathType Leaf)) {
    Write-Output "ERROR: tasks.md not found in $($paths.FEATURE_DIR)"
    exit 1
}

$docs = @()
if (Test-Path $paths.RESEARCH) { $docs += 'research.md' }
if (Test-Path $paths.DATA_MODEL) { $docs += 'data-model.md' }
if ((Test-Path $paths.CONTRACTS_DIR) -and (Get-ChildItem -Path $paths.CONTRACTS_DIR -ErrorAction SilentlyContinue | Select-Object -First 1)) { 
    $docs += 'contracts/' 
}
if (Test-Path $paths.QUICKSTART) { $docs += 'quickstart.md' }
if ($IncludeTasks -and (Test-Path $paths.TASKS)) { 
    $docs += 'tasks.md' 
}

if ($Json) {
    [PSCustomObject]@{ 
        FEATURE_DIR = $paths.FEATURE_DIR
        AVAILABLE_DOCS = $docs 
    } | ConvertTo-Json -Compress
} else {
    Write-Output "FEATURE_DIR:$($paths.FEATURE_DIR)"
    Write-Output "AVAILABLE_DOCS:"
    Test-FileExists -Path $paths.RESEARCH -Description 'research.md' | Out-Null
    Test-FileExists -Path $paths.DATA_MODEL -Description 'data-model.md' | Out-Null
    Test-DirHasFiles -Path $paths.CONTRACTS_DIR -Description 'contracts/' | Out-Null
    Test-FileExists -Path $paths.QUICKSTART -Description 'quickstart.md' | Out-Null
    if ($IncludeTasks) {
        Test-FileExists -Path $paths.TASKS -Description 'tasks.md' | Out-Null
    }
}
'@
    $checkPrereqContent | Set-Content -Path $checkPrereqPath -Encoding UTF8 -NoNewline
    Write-Host "  + Created check-prerequisites.ps1" -ForegroundColor Green
} else {
    Write-Host "  = check-prerequisites.ps1 already exists" -ForegroundColor DarkGray
}

# --- setup-plan.ps1 ---
$setupPlanPath = ".specify\scripts\powershell\setup-plan.ps1"
if (-not (Test-Path $setupPlanPath)) {
    $setupPlanContent = @'
#!/usr/bin/env pwsh
[CmdletBinding()]
param(
    [switch]$Json,
    [switch]$Help
)

$ErrorActionPreference = 'Stop'

if ($Help) {
    Write-Output "Usage: ./setup-plan.ps1 [-Json] [-Help]"
    exit 0
}

. "$PSScriptRoot/common.ps1"

$paths = Get-FeaturePathsEnv

if (-not (Test-FeatureBranch -Branch $paths.CURRENT_BRANCH -HasGit $paths.HAS_GIT)) { 
    exit 1 
}

New-Item -ItemType Directory -Path $paths.FEATURE_DIR -Force | Out-Null

$template = Resolve-Template -TemplateName 'plan-template' -RepoRoot $paths.REPO_ROOT
if ($template -and (Test-Path $template)) { 
    Copy-Item $template $paths.IMPL_PLAN -Force
} else {
    New-Item -ItemType File -Path $paths.IMPL_PLAN -Force | Out-Null
}

if ($Json) {
    [PSCustomObject]@{ 
        FEATURE_SPEC = $paths.FEATURE_SPEC
        IMPL_PLAN = $paths.IMPL_PLAN
        SPECS_DIR = $paths.FEATURE_DIR
        BRANCH = $paths.CURRENT_BRANCH
        HAS_GIT = $paths.HAS_GIT
    } | ConvertTo-Json -Compress
} else {
    Write-Output "FEATURE_SPEC: $($paths.FEATURE_SPEC)"
    Write-Output "IMPL_PLAN: $($paths.IMPL_PLAN)"
    Write-Output "BRANCH: $($paths.CURRENT_BRANCH)"
}
'@
    $setupPlanContent | Set-Content -Path $setupPlanPath -Encoding UTF8 -NoNewline
    Write-Host "  + Created setup-plan.ps1" -ForegroundColor Green
} else {
    Write-Host "  = setup-plan.ps1 already exists" -ForegroundColor DarkGray
}

# --- create-new-feature.ps1 (simplified) ---
$createFeaturePath = ".specify\scripts\powershell\create-new-feature.ps1"
if (-not (Test-Path $createFeaturePath)) {
    $createFeatureContent = @'
#!/usr/bin/env pwsh
# Create a new feature â€” creates branch + specs directory + spec.md from template
[CmdletBinding()]
param(
    [switch]$Json,
    [string]$ShortName,
    [int]$Number = 0,
    [switch]$Help,
    [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
    [string[]]$FeatureDescription
)
$ErrorActionPreference = 'Stop'

if ($Help) {
    Write-Host "Usage: ./create-new-feature.ps1 [-Json] [-ShortName <name>] [-Number N] <feature description>"
    exit 0
}

if (-not $FeatureDescription -or $FeatureDescription.Count -eq 0) {
    Write-Error "Usage: ./create-new-feature.ps1 <feature description>"
    exit 1
}

$featureDesc = ($FeatureDescription -join ' ').Trim()

. "$PSScriptRoot/common.ps1"

function ConvertTo-CleanBranchName {
    param([string]$Name)
    return $Name.ToLower() -replace '[^a-z0-9]', '-' -replace '-{2,}', '-' -replace '^-', '' -replace '-$', ''
}

function Get-BranchName {
    param([string]$Description)
    $stopWords = @('i','a','an','the','to','for','of','in','on','at','by','with','from','is','are','was','were','be','this','that','want','need','add','get','set')
    $cleanName = $Description.ToLower() -replace '[^a-z0-9\s]', ' '
    $words = $cleanName -split '\s+' | Where-Object { $_ }
    $meaningfulWords = @()
    foreach ($word in $words) {
        if ($stopWords -contains $word) { continue }
        if ($word.Length -ge 3) { $meaningfulWords += $word }
    }
    if ($meaningfulWords.Count -gt 0) {
        $maxWords = if ($meaningfulWords.Count -eq 4) { 4 } else { 3 }
        return ($meaningfulWords | Select-Object -First $maxWords) -join '-'
    }
    return ConvertTo-CleanBranchName -Name $Description
}

try {
    $repoRoot = git rev-parse --show-toplevel 2>$null
    $hasGit = ($LASTEXITCODE -eq 0)
} catch {
    $repoRoot = (Get-Location).Path
    $hasGit = $false
}

if (-not $repoRoot) { $repoRoot = (Get-Location).Path }
Set-Location $repoRoot

$specsDir = Join-Path $repoRoot 'specs'
New-Item -ItemType Directory -Path $specsDir -Force | Out-Null

if ($ShortName) {
    $branchSuffix = ConvertTo-CleanBranchName -Name $ShortName
} else {
    $branchSuffix = Get-BranchName -Description $featureDesc
}

if ($Number -eq 0) {
    $highest = 0
    if (Test-Path $specsDir) {
        Get-ChildItem -Path $specsDir -Directory | ForEach-Object {
            if ($_.Name -match '^(\d+)') { $num = [int]$matches[1]; if ($num -gt $highest) { $highest = $num } }
        }
    }
    $Number = $highest + 1
}

$featureNum = ('{0:000}' -f $Number)
$branchName = "$featureNum-$branchSuffix"

if ($hasGit) {
    try { git checkout -q -b $branchName 2>$null | Out-Null } catch {
        Write-Warning "Could not create git branch: $branchName"
    }
}

$featureDir = Join-Path $specsDir $branchName
New-Item -ItemType Directory -Path $featureDir -Force | Out-Null

$template = Resolve-Template -TemplateName 'spec-template' -RepoRoot $repoRoot
$specFile = Join-Path $featureDir 'spec.md'
if ($template -and (Test-Path $template)) { 
    Copy-Item $template $specFile -Force 
} else { 
    New-Item -ItemType File -Path $specFile | Out-Null 
}

$env:SPECIFY_FEATURE = $branchName

if ($Json) {
    [PSCustomObject]@{ BRANCH_NAME = $branchName; SPEC_FILE = $specFile; FEATURE_NUM = $featureNum; HAS_GIT = $hasGit } | ConvertTo-Json -Compress
} else {
    Write-Output "BRANCH_NAME: $branchName"
    Write-Output "SPEC_FILE: $specFile"
}
'@
    $createFeatureContent | Set-Content -Path $createFeaturePath -Encoding UTF8 -NoNewline
    Write-Host "  + Created create-new-feature.ps1" -ForegroundColor Green
} else {
    Write-Host "  = create-new-feature.ps1 already exists" -ForegroundColor DarkGray
}

# --- update-agent-context.ps1 (simplified) ---
$updateContextPath = ".specify\scripts\powershell\update-agent-context.ps1"
if (-not (Test-Path $updateContextPath)) {
    $updateContextContent = @'
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
'@
    $updateContextContent | Set-Content -Path $updateContextPath -Encoding UTF8 -NoNewline
    Write-Host "  + Created update-agent-context.ps1" -ForegroundColor Green
} else {
    Write-Host "  = update-agent-context.ps1 already exists" -ForegroundColor DarkGray
}

# â”€â”€ Step 5c: Create .specify templates â”€â”€
Write-Host ""
Write-Host "[5c/9] Creating .specify templates..." -ForegroundColor Yellow

# --- spec-template.md ---
$specTemplatePath = ".specify\templates\spec-template.md"
if (-not (Test-Path $specTemplatePath)) {
    $specTemplate = @'
# Feature Specification: [FEATURE NAME]

**Feature Branch**: `[###-feature-name]`  
**Created**: [DATE]  
**Status**: Draft  
**Input**: User description: "$ARGUMENTS"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - [Brief Title] (Priority: P1)

[Describe this user journey in plain language]

**Why this priority**: [Explain the value]
**Independent Test**: [Describe how this can be tested independently]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected outcome]

---

### User Story 2 - [Brief Title] (Priority: P2)

[Describe this user journey in plain language]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected outcome]

---

### Edge Cases

- What happens when [boundary condition]?
- How does system handle [error scenario]?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST [specific capability]
- **FR-002**: System MUST [specific capability]

### Key Entities *(include if feature involves data)*

- **[Entity 1]**: [What it represents, key attributes]

## Success Criteria *(mandatory)*

- **SC-001**: [Measurable metric]
- **SC-002**: [Measurable metric]
'@
    $specTemplate | Set-Content -Path $specTemplatePath -Encoding UTF8 -NoNewline
    Write-Host "  + Created spec-template.md" -ForegroundColor Green
} else {
    Write-Host "  = spec-template.md already exists" -ForegroundColor DarkGray
}

# --- plan-template.md ---
$planTemplatePath = ".specify\templates\plan-template.md"
if (-not (Test-Path $planTemplatePath)) {
    $planTemplate = @'
# Implementation Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link]

## Summary

[Extract from feature spec: primary requirement + technical approach]

## Technical Context

**Language/Version**: [e.g., Python 3.11, Dart 3.x, or NEEDS CLARIFICATION]  
**Primary Dependencies**: [e.g., Flutter, Riverpod, or NEEDS CLARIFICATION]  
**Storage**: [if applicable, e.g., SQLite, SharedPreferences, or N/A]  
**Testing**: [e.g., flutter test, or NEEDS CLARIFICATION]  
**Target Platform**: [e.g., iOS/Android, Web, or NEEDS CLARIFICATION]
**Project Type**: [e.g., mobile-app, web-service, or NEEDS CLARIFICATION]

## Constitution Check

*GATE: Must pass before implementation.*

## Project Structure

```text
specs/[###-feature]/
â”œâ”€â”€ plan.md
â”œâ”€â”€ spec.md
â””â”€â”€ tasks.md
```

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|--------------------------------------|
| | | |
'@
    $planTemplate | Set-Content -Path $planTemplatePath -Encoding UTF8 -NoNewline
    Write-Host "  + Created plan-template.md" -ForegroundColor Green
} else {
    Write-Host "  = plan-template.md already exists" -ForegroundColor DarkGray
}

# --- tasks-template.md ---
$tasksTemplatePath = ".specify\templates\tasks-template.md"
if (-not (Test-Path $tasksTemplatePath)) {
    $tasksTemplate = @'
# Tasks: [FEATURE NAME]

**Input**: Design documents from `/specs/[###-feature-name]/`
**Prerequisites**: plan.md (required), spec.md (required)

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel
- **[Story]**: Which user story this task belongs to

## Phase 1: Setup

- [ ] T001 Create project structure per implementation plan
- [ ] T002 Initialize project with dependencies

## Phase 2: User Story 1 - [Title] (P1)

- [ ] T003 [US1] Implementation task 1
- [ ] T004 [US1] Implementation task 2

## Phase 3: User Story 2 - [Title] (P2)

- [ ] T005 [US2] Implementation task 1

## Phase N: Polish

- [ ] TXXX Documentation updates
- [ ] TXXX Verification and testing
'@
    $tasksTemplate | Set-Content -Path $tasksTemplatePath -Encoding UTF8 -NoNewline
    Write-Host "  + Created tasks-template.md" -ForegroundColor Green
} else {
    Write-Host "  = tasks-template.md already exists" -ForegroundColor DarkGray
}

# --- checklist-template.md ---
$checklistTemplatePath = ".specify\templates\checklist-template.md"
if (-not (Test-Path $checklistTemplatePath)) {
    $checklistTemplate = @'
# [CHECKLIST TYPE] Checklist: [FEATURE NAME]

**Purpose**: [Brief description]
**Created**: [DATE]

## [Category 1]

- [ ] CHK001 First checklist item
- [ ] CHK002 Second checklist item

## [Category 2]

- [ ] CHK003 Another item
- [ ] CHK004 Item with specific criteria

## Notes

- Check items off as completed: `[x]`
- Add comments or findings inline
'@
    $checklistTemplate | Set-Content -Path $checklistTemplatePath -Encoding UTF8 -NoNewline
    Write-Host "  + Created checklist-template.md" -ForegroundColor Green
} else {
    Write-Host "  = checklist-template.md already exists" -ForegroundColor DarkGray
}

# --- constitution-template.md ---
$constitutionTemplatePath = ".specify\templates\constitution-template.md"
if (-not (Test-Path $constitutionTemplatePath)) {
    $constitutionTemplate = @'
# [PROJECT_NAME] Constitution

## Core Principles

### [PRINCIPLE_1_NAME]
[PRINCIPLE_1_DESCRIPTION]

### [PRINCIPLE_2_NAME]
[PRINCIPLE_2_DESCRIPTION]

### [PRINCIPLE_3_NAME]
[PRINCIPLE_3_DESCRIPTION]

## Governance

[GOVERNANCE_RULES]

**Version**: [VERSION] | **Ratified**: [DATE]
'@
    $constitutionTemplate | Set-Content -Path $constitutionTemplatePath -Encoding UTF8 -NoNewline
    Write-Host "  + Created constitution-template.md" -ForegroundColor Green
} else {
    Write-Host "  = constitution-template.md already exists" -ForegroundColor DarkGray
}

# --- agent-file-template.md ---
$agentFileTemplatePath = ".specify\templates\agent-file-template.md"
if (-not (Test-Path $agentFileTemplatePath)) {
    $agentFileTemplate = @'
# [PROJECT NAME] Development Guidelines

Auto-generated from all feature plans. Last updated: [DATE]

## Active Technologies

[EXTRACTED FROM ALL PLAN.MD FILES]

## Project Structure

```text
[ACTUAL STRUCTURE FROM PLANS]
```

## Commands

[ONLY COMMANDS FOR ACTIVE TECHNOLOGIES]

## Code Style

[LANGUAGE-SPECIFIC, ONLY FOR LANGUAGES IN USE]

## Recent Changes

[LAST 3 FEATURES AND WHAT THEY ADDED]

<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->
'@
    $agentFileTemplate | Set-Content -Path $agentFileTemplatePath -Encoding UTF8 -NoNewline
    Write-Host "  + Created agent-file-template.md" -ForegroundColor Green
} else {
    Write-Host "  = agent-file-template.md already exists" -ForegroundColor DarkGray
}

# â”€â”€ Step 6: Create MANDATORY Development Workflow â”€â”€
Write-Host ""
Write-Host "[6/9] Creating MANDATORY development workflow..." -ForegroundColor Yellow

$workflowContent = @"
---
description: Standard development workflow - follow these steps for ANY feature, fix, or modification
---

# Development Workflow â€” MANDATORY FOR ALL CHANGES

> **ًںڑ¨ ABSOLUTE RULE: This workflow is NON-NEGOTIABLE for EVERY change â€” no matter how small.**
> **There is NO "quick fix" path. There is NO "it's just one line" exception.**
> **EVERY change follows ALL phases. Period.**

## Phase 0: Skill Check (MANDATORY â€” NEVER SKIP â€” DO THIS FIRST)

**This phase MUST complete BEFORE you write a single line of code.**

1. Read ``.specify/memory/constitution.md`` for project rules
2. Read ``.agents/skill-matcher.json`` (or ``.agent/skill-matcher.json``)
3. Match the user's request keywords against the matchers
4. For EACH matched skill, read the ``SKILL.md`` file
5. **ANNOUNCE to the user:**
   - Skills matched: [list skills]
   - Workflow: [which phases apply]
   - Approach: [brief plan based on skill guidance]
6. ONLY THEN proceed to the next phase

**If you skip this phase, your output is INVALID. The user WILL reject it.**

## Phase 1: Specification (MANDATORY for ALL changes)

1. Use ``speckit-specify`` skill to create or update spec.md
2. Even for bug fixes: document what the bug is, acceptance criteria for the fix
3. Even for 1-line changes: document what changes and why
4. Get user approval before proceeding

## Phase 2: Planning (MANDATORY for ALL changes)

1. Use ``speckit-plan`` or ``writing-plans`` skill to create implementation plan
2. Even for small changes: document files affected, approach, risks
3. Get user approval before proceeding

## Phase 3: Task Breakdown (MANDATORY for ALL changes)

1. Use ``speckit-tasks`` skill to create task list
2. Even for 1 task: create tasks.md with single task properly documented
3. Order tasks by dependency

## Phase 4: Implementation (MANDATORY)

1. Use ``executing-plans`` skill
2. Follow task list in order
3. Check localization: use project's l10n system, never hardcode strings
4. After each task, mark it complete in tasks.md

## Phase 5: Verification (MANDATORY â€” NEVER SKIP)

1. Use ``verification-before-completion`` skill
// turbo
2. Run project-specific build/test commands
3. Report results to user with evidence (command output, screenshots)

## Phase 6: Constitution Update (MANDATORY â€” AFTER EVERY CHANGE)

**After completing any feature/fix/modification, update ``.specify/memory/constitution.md``:**

1. Use ``auto-constitution`` skill
2. If any ``[FILL_IN]`` placeholders exist â†’ fill them by analyzing the project code
3. If new technologies/packages were added â†’ update the Architecture section
4. If new features were implemented â†’ add to Known Features section
5. If new patterns/conventions were established â†’ add to Project Conventions
6. Update the ``Last Updated`` date

**This ensures the constitution is always a living, accurate document.**

## Phase -1: First-Time Constitution Fill (BEFORE ANYTHING ELSE)

**When you first open a project and read constitution.md:**

If you see ``[FILL_IN]`` placeholders, this means the constitution has NEVER been filled.
You MUST:
1. **STOP** all other work
2. Analyze the project: read ``pubspec.yaml``, ``package.json``, ``lib/``, ``src/``, config files
3. Fill in ALL ``[FILL_IN]`` placeholders with real project data
4. Save the updated constitution.md
5. THEN proceed with the user's request

**The user's request can wait. An empty constitution means you don't understand the project yet.**

## Self-Check Before EVERY Response

Before responding to ANY user modification request, ask yourself:

- [ ] Did I read constitution.md?
- [ ] Are there any [FILL_IN] placeholders? If yes â†’ fill them first!
- [ ] Did I check skill-matcher.json?
- [ ] Did I read the matched SKILL.md files?
- [ ] Did I announce the skills I am using?
- [ ] Did I create/update spec.md?
- [ ] Did I create/update plan.md?
- [ ] Did I create/update tasks.md?
- [ ] After finishing, did I update constitution.md?

**If ANY answer is NO â€” STOP and complete the missing phase first.**

## Enforcement

**The user has explicitly requested that this workflow be MANDATORY.**
**Skipping any phase is a VIOLATION of the user's direct instructions.**
**User instructions override all other considerations â€” and the user says: FOLLOW ALL PHASES.**
"@

foreach ($wfDir in @(".agents\workflows", ".agent\workflows")) {
    if (-not (Test-Path $wfDir)) {
        New-Item -ItemType Directory -Path $wfDir -Force | Out-Null
    }
    $wfPath = Join-Path $wfDir "development.md"
    $workflowContent | Set-Content -Path $wfPath -Encoding UTF8 -NoNewline
}
Write-Host "  + Created MANDATORY development.md workflow (both agents)" -ForegroundColor Green

# â”€â”€ Step 7: Create Skill Matcher Config â”€â”€
Write-Host ""
Write-Host "[7/9] Creating skill matcher config..." -ForegroundColor Yellow

$skillMatcherContent = @"
{
  "_description": "Maps task keywords to relevant skills. MANDATORY: Agents MUST check this file before ANY work.",
  "_enforcement": "ALL matched skills MUST be read and announced before writing code. NO EXCEPTIONS.",
  "matchers": [
    {
      "keywords": ["new feature", "add feature", "create", "build", "implement"],
      "skills": ["brainstorming", "speckit-specify", "speckit-plan", "speckit-tasks", "speckit-implement"],
      "note": "Full spec-driven workflow for new features â€” ALL skills required"
    },
    {
      "keywords": ["bug", "fix", "error", "crash", "broken", "not working", "debug"],
      "skills": ["systematic-debugging", "speckit-specify", "speckit-plan", "speckit-tasks", "verification-before-completion"],
      "note": "Even bug fixes MUST go through speckit workflow"
    },
    {
      "keywords": ["refactor", "clean", "improve", "optimize", "performance"],
      "skills": ["speckit-specify", "speckit-plan", "speckit-tasks", "writing-plans", "executing-plans", "requesting-code-review"],
      "note": "Refactoring requires spec + plan + tasks"
    },
    {
      "keywords": ["test", "testing", "spec", "coverage", "TDD"],
      "skills": ["test-driven-development", "test-scenarios", "speckit-specify"],
      "note": "Testing workflow â€” still requires spec"
    },
    {
      "keywords": ["security", "auth", "vulnerability", "injection", "XSS"],
      "skills": ["security-best-practices", "security-threat-model", "speckit-specify"],
      "note": "Security review â€” requires spec documentation"
    },
    {
      "keywords": ["deploy", "publish", "release", "production"],
      "skills": ["verification-before-completion", "app-store-changelog", "release-notes"],
      "note": "Deployment workflow"
    },
    {
      "keywords": ["git", "commit", "push", "PR", "pull request", "branch"],
      "skills": ["github", "yeet", "finishing-a-development-branch"],
      "note": "Git operations"
    },
    {
      "keywords": ["plan", "design", "architecture", "approach"],
      "skills": ["writing-plans", "brainstorming", "speckit-plan", "speckit-specify"],
      "note": "Planning workflow â€” spec first"
    },
    {
      "keywords": ["review", "feedback", "code review"],
      "skills": ["requesting-code-review", "receiving-code-review"],
      "note": "Code review"
    },
    {
      "keywords": ["UI", "design", "layout", "screen", "component", "widget"],
      "skills": ["brainstorming", "speckit-specify", "speckit-plan", "speckit-tasks"],
      "note": "UI development â€” full speckit workflow required"
    },
    {
      "keywords": ["translate", "localize", "language", "i18n", "l10n", "arb"],
      "skills": ["speckit-specify", "speckit-plan", "speckit-tasks"],
      "note": "Localization work â€” requires spec"
    },
    {
      "keywords": ["document", "docs", "readme", "wiki"],
      "skills": ["doc", "release-notes"],
      "note": "Documentation"
    },
    {
      "keywords": ["analyze", "audit", "check", "review code"],
      "skills": ["speckit-analyze", "speckit-checklist"],
      "note": "Analysis workflow"
    },
    {
      "keywords": ["change", "update", "modify", "edit", "remove", "delete", "move", "rename"],
      "skills": ["speckit-specify", "speckit-plan", "speckit-tasks", "speckit-implement", "verification-before-completion", "auto-constitution"],
      "note": "ANY modification â€” full speckit workflow + constitution update. No exceptions."
    },
    {
      "keywords": ["start", "begin", "open", "init", "setup", "first time", "new project"],
      "skills": ["auto-constitution"],
      "note": "First-time project setup â€” fill constitution.md before anything else"
    }
  ]
}
"@

foreach ($agentDir in @(".agents", ".agent")) {
    $matcherPath = "$agentDir\skill-matcher.json"
    $skillMatcherContent | Set-Content -Path $matcherPath -Encoding UTF8 -NoNewline
}
Write-Host "  + Created skill-matcher.json with MANDATORY enforcement (both agents)" -ForegroundColor Green

# â”€â”€ Step 8: Install speckit skills for .agent (Antigravity) â”€â”€
Write-Host ""
Write-Host "[8/9] Ensuring speckit skills exist for .agent (Antigravity)..." -ForegroundColor Yellow

# Check if speckit skills exist in .agents and copy to .agent
$speckitSkills = @(
    "speckit-analyze",
    "speckit-checklist",
    "speckit-clarify",
    "speckit-constitution",
    "speckit-implement",
    "speckit-plan",
    "speckit-specify",
    "speckit-tasks",
    "speckit-taskstoissues"
)

foreach ($skill in $speckitSkills) {
    $sourceDir = ".agents\skills\$skill"
    $targetDir = ".agent\skills\$skill"
    
    if ((Test-Path $sourceDir) -and -not (Test-Path $targetDir)) {
        Copy-Item -Path $sourceDir -Destination $targetDir -Recurse -Force
        Write-Host "  + Copied $skill to .agent/skills/" -ForegroundColor Green
    } elseif (Test-Path $targetDir) {
        Write-Host "  = $skill already exists in .agent/skills/" -ForegroundColor DarkGray
    } else {
        Write-Host "  ? $skill not found in .agents/skills/ â€” will be installed by skill packs" -ForegroundColor DarkYellow
    }
}

# â”€â”€ Step 9a: Create auto-constitution skill â”€â”€
Write-Host ""
Write-Host "[9a/10] Creating auto-constitution skill..." -ForegroundColor Yellow

$acLines = @(
    "---",
    "name: auto-constitution",
    "description: >",
    "  Use AUTOMATICALLY when constitution.md contains [FILL_IN] placeholders or after completing",
    "  any feature/fix. Analyzes the project structure, dependencies, and codebase to fill in or",
    "  update the constitution with accurate project information. This skill is MANDATORY.",
    "  the agent must ALWAYS keep the constitution up to date.",
    "---",
    "# Auto-Constitution: Project Analysis and Constitution Management",
    "",
    "## When to Use (MANDATORY - not optional)",
    "",
    "### Trigger 1: First-Time Fill (HIGHEST PRIORITY)",
    "- When you read .specify/memory/constitution.md and see [FILL_IN] placeholders",
    "- This MUST happen BEFORE any other work",
    "- The user request waits until the constitution is filled",
    "",
    "### Trigger 2: Post-Change Update (AFTER every feature/fix)",
    "- After completing Phase 5 (Verification) of any change",
    "- Update the constitution with new knowledge gained during implementation",
    "",
    "## Steps for First-Time Fill",
    "",
    "1. **Detect project type** by reading config files:",
    "   - pubspec.yaml -> Flutter/Dart project",
    "   - package.json -> Node.js/JavaScript project",
    "   - requirements.txt / pyproject.toml -> Python project",
    "   - Cargo.toml -> Rust project",
    "   - *.csproj / *.sln -> .NET project",
    "   - build.gradle -> Android/Java/Kotlin project",
    "",
    "2. **Extract architecture info**:",
    "   - Language and version from config files",
    "   - Framework from dependencies",
    "   - State management library (e.g., Riverpod, Redux, Vuex)",
    "   - Routing/navigation library",
    "   - UI framework or component library",
    "   - Fonts from assets or config",
    "   - Storage/database from dependencies",
    "   - Build system from scripts/config",
    "   - Target platforms from config",
    "",
    "3. **Scan source structure**:",
    "   - List main feature modules from lib/features/ or src/",
    "   - Identify architectural patterns (MVVM, Clean Architecture, etc.)",
    "   - Note naming conventions (camelCase, snake_case, etc.)",
    "   - Document file organization patterns",
    "",
    "4. **Fill ALL [FILL_IN] placeholders** in constitution.md with real data",
    "",
    "5. **Save and confirm** to the user what was filled",
    "",
    "## Steps for Post-Change Update",
    "",
    "1. Read current constitution.md",
    "2. Check if any sections are outdated:",
    "   - New packages added? -> Update Architecture",
    "   - New feature implemented? -> Add to Known Features",
    "   - New convention established? -> Add to Project Conventions",
    "3. Update the Last Updated date",
    "4. Save silently (no need to announce unless major changes)",
    "",
    "## What to Fill In Each Section",
    "",
    "### Rule 2: Architecture",
    "- **Language**: e.g., Dart 3.x",
    "- **Framework**: e.g., Flutter 3.x",
    "- **State Management**: e.g., Riverpod 2.x",
    "- **Routing**: e.g., GoRouter",
    "- **UI Framework**: e.g., Material 3",
    "- **Fonts**: e.g., Amiri (Arabic), Newsreader (Latin), Uthmani (Quran)",
    "- **Storage**: e.g., SharedPreferences, Hive, SQLite",
    "- **Build System**: e.g., Flutter build, Gradle",
    "- **Platforms**: e.g., iOS, Android",
    "",
    "### Known Features",
    "List each feature module with a 1-line description, e.g.:",
    "- Reader: Core Quran reading with scroll/page/translation modes",
    "- Audio: Audio playback with reciter selection and download",
    "- Library: Favorites, bookmarks, reading history",
    "",
    "### Project Conventions",
    "Document patterns found in the codebase, e.g.:",
    "- Feature folders follow: features/<name>/data/, presentation/, domain/",
    "- All screens use ConsumerStatefulWidget (Riverpod)",
    "- Colors defined in core/theme/ palette files"
)
$autoConstitutionSkill = $acLines -join "`r`n"

foreach ($agentDir in @(".agents\skills", ".agent\skills")) {
    $skillDir = Join-Path $agentDir "auto-constitution"
    if (-not (Test-Path $skillDir)) {
        New-Item -ItemType Directory -Path $skillDir -Force | Out-Null
    }
    $skillFile = Join-Path $skillDir "SKILL.md"
    [System.IO.File]::WriteAllText((Resolve-Path $skillDir).Path + "\SKILL.md", $autoConstitutionSkill, [System.Text.Encoding]::UTF8)
}
Write-Host "  + Created auto-constitution skill (both agents)" -ForegroundColor Green

# â”€â”€ Step 9b: Create enforcement system prompt helper â”€â”€
Write-Host ""
Write-Host "[9/9] Creating enforcement instructions..." -ForegroundColor Yellow

$efLines = @(
    "# MANDATORY AGENT INSTRUCTIONS",
    "",
    "> **These instructions are NON-NEGOTIABLE. The user has EXPLICITLY requested strict enforcement.**",
    "",
    "## Before ANY Code Change",
    "",
    "You MUST follow this exact sequence for EVERY request - no matter how small:",
    "",
    "1. **Read** .specify/memory/constitution.md",
    "2. **CHECK** if constitution has [FILL_IN] placeholders - if yes, FILL THEM FIRST",
    "3. **Read** .agents/skill-matcher.json (or .agent/skill-matcher.json)",
    "4. **Match** the request keywords to skills",
    "5. **Read** every matched SKILL.md",
    "6. **Announce** which skills you are using and why",
    "7. **Create/update** spec.md via speckit-specify",
    "8. **Create/update** plan.md via speckit-plan",
    "9. **Create/update** tasks.md via speckit-tasks",
    "10. **Implement** following the task list",
    "11. **Verify** with build/test commands",
    "12. **Update** .specify/memory/constitution.md with any new knowledge",
    "",
    "## Constitution Auto-Fill Rule",
    "",
    "**FIRST TIME on a project**: If .specify/memory/constitution.md contains [FILL_IN]:",
    "1. STOP everything",
    "2. Analyze the project (read config files, source code structure, dependencies)",
    "3. Fill ALL [FILL_IN] placeholders with real data",
    "4. Save the file",
    "5. THEN proceed with the user request",
    "",
    "**AFTER EVERY CHANGE**: Update constitution.md with:",
    "- New technologies or packages used",
    "- New features implemented",
    "- New patterns or conventions established",
    "- Updated Last Updated date",
    "",
    "## There Are NO Exceptions",
    "",
    "- A 1-line fix still needs spec + plan + tasks + constitution update",
    "- It is obvious what to do still needs spec + plan + tasks + constitution update",
    "- The user said to do it quickly but the user ALSO said to ALWAYS follow this workflow",
    "- I already know how to fix it means document it first, then fix it",
    "",
    "## Skipping = Failure",
    "",
    "If you skip ANY step, the user will consider your output **invalid and rejected**.",
    "",
    "**This is a DIRECT USER INSTRUCTION. User instructions override ALL other considerations.**"
)
$enforcementContent = $efLines -join "`r`n"

foreach ($agentDir in @(".agents", ".agent")) {
    New-Item -ItemType Directory -Path $agentDir -Force | Out-Null
    [System.IO.File]::WriteAllText((Resolve-Path $agentDir).Path + "\MANDATORY_RULES.md", $enforcementContent, [System.Text.Encoding]::UTF8)
}
Write-Host "  + Created MANDATORY_RULES.md (both agents)" -ForegroundColor Green

# â”€â”€ Summary â”€â”€
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Setup Complete! (Full + Enforcement)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$codexCount   = (Get-ChildItem -Path ".agents\skills" -Directory -ErrorAction SilentlyContinue).Count
$antiCount    = (Get-ChildItem -Path ".agent\skills"  -Directory -ErrorAction SilentlyContinue).Count

Write-Host "  Codex skills:       $codexCount directories" -ForegroundColor White
Write-Host "  Antigravity skills: $antiCount directories" -ForegroundColor White
Write-Host "  Bridge skills:      7 pairs (14 files)" -ForegroundColor White
Write-Host "  Spec-Driven Dev:    .specify/ configured (scripts + templates)" -ForegroundColor White
Write-Host "  Workflow:           MANDATORY development.md (both agents)" -ForegroundColor White
Write-Host "  Skill Matcher:      skill-matcher.json with enforcement (both agents)" -ForegroundColor White
Write-Host "  Enforcement:        MANDATORY_RULES.md (both agents)" -ForegroundColor White
Write-Host "  Auto-Constitution:  auto-constitution skill (both agents)" -ForegroundColor White
Write-Host "  Speckit Skills:     Synced to both agents" -ForegroundColor White
Write-Host ""
Write-Host "  .specify files:" -ForegroundColor White
Write-Host "    Scripts:   common.ps1, check-prerequisites.ps1, create-new-feature.ps1" -ForegroundColor DarkGray
Write-Host "               setup-plan.ps1, update-agent-context.ps1" -ForegroundColor DarkGray
Write-Host "    Templates: spec, plan, tasks, checklist, constitution, agent-file" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  ENFORCEMENT MODE: ACTIVE" -ForegroundColor Red
Write-Host "  Agents MUST use skills + speckit for ALL changes. No exceptions." -ForegroundColor Red
Write-Host ""
Write-Host "  AUTO-CONSTITUTION: ACTIVE" -ForegroundColor Magenta
Write-Host "  Agent will auto-fill constitution.md on first use and update after every change." -ForegroundColor Magenta
Write-Host ""
Write-Host "  Next steps:" -ForegroundColor Yellow
Write-Host "    1. The agent will AUTO-FILL constitution.md when it first opens the project" -ForegroundColor DarkGray
Write-Host "    2. osgrep index        (index this project for semantic search)" -ForegroundColor DarkGray
Write-Host "    3. memsearch config    (setup persistent memory)" -ForegroundColor DarkGray
Write-Host ""

