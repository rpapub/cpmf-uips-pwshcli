<#
.SYNOPSIS
    Installs CpmfUipsCLI (and its dependency CpmfUipsPack) from local repo copies into
    the user PSModulePath, then runs the full Pester suite against the installed copy.

.DESCRIPTION
    Simulates the user experience of a deployed module without requiring a PSGallery publish.

    Flow:
      1. Install CpmfUipsPack from its local repo (via pwshpack's Test-LocalInstall.ps1)
      2. Copy  <RepoRoot>\CpmfUipsCLI\ → <UserModules>\CpmfUipsCLI\
      3. Import CpmfUipsCLI by name (RequiredModules pulls CpmfUipsPack automatically)
      4. Run Pester against the installed copy's tests\
      5. Report pass/fail
      6. Optionally remove both installed copies (-Cleanup)

.PARAMETER RepoRoot
    Path to this repository root. Defaults to the parent of this script's directory.

.PARAMETER PackRepoRoot
    Path to the CpmfUipsPack repository root. Defaults to the sibling folder
    cpmf-uips-pwshpack next to this repo's parent.

.PARAMETER Cleanup
    Remove both installed module copies after the test run.

.PARAMETER SkipPackInstall
    Skip step 1 (CpmfUipsPack install). Useful when CpmfUipsPack is already installed.

.EXAMPLE
    # Run from anywhere
    pwsh -File 'D:\github.com\rpapub\cpmf-uips-pwshcli\scripts\Test-LocalInstall.ps1'

.EXAMPLE
    # Run and clean up afterwards
    .\scripts\Test-LocalInstall.ps1 -Cleanup

.EXAMPLE
    # Skip reinstalling CpmfUipsPack (already in place)
    .\scripts\Test-LocalInstall.ps1 -SkipPackInstall

.NOTES
    For a PSGallery variant, replace steps 1-2 with:
        Install-Module CpmfUipsPack  -Repository PSGallery -Scope CurrentUser -Force
        Install-Module CpmfUipsCLI   -Repository PSGallery -Scope CurrentUser -Force
    Steps 3-6 are identical.
#>
[CmdletBinding()]
param(
    [string]$RepoRoot      = (Split-Path $PSScriptRoot -Parent),
    [string]$PackRepoRoot  = (Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) 'cpmf-uips-pwshpack'),
    [switch]$Cleanup,
    [switch]$SkipPackInstall
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$cliModuleName  = 'CpmfUipsCLI'
$packModuleName = 'CpmfUipsPack'
$userModules    = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'PowerShell\Modules'
$cliInstallDest = Join-Path $userModules $cliModuleName

# ── Step 1: install CpmfUipsPack via its own Test-LocalInstall ────────────────
if (-not $SkipPackInstall) {
    $packScript = Join-Path $PackRepoRoot 'scripts\Test-LocalInstall.ps1'
    if (-not (Test-Path $packScript)) {
        throw "CpmfUipsPack test-install script not found: $packScript`nSet -PackRepoRoot to the correct path."
    }
    Write-Host "[Test-LocalInstall] Installing dependency $packModuleName from $PackRepoRoot ..."
    & pwsh -NoProfile -File $packScript -RepoRoot $PackRepoRoot
    if ($LASTEXITCODE -ne 0) {
        throw "$packModuleName install/test failed (exit $LASTEXITCODE). Fix CpmfUipsPack before testing the CLI wrapper."
    }
    Write-Host "[Test-LocalInstall] $packModuleName installed."
} else {
    Write-Host "[Test-LocalInstall] -SkipPackInstall: assuming $packModuleName is already in PSModulePath."
}

# ── Step 2: copy CpmfUipsCLI to user PSModulePath ────────────────────────────
$cliSource = Join-Path $RepoRoot $cliModuleName
if (-not (Test-Path $cliSource)) {
    throw "Module source not found: $cliSource"
}

Write-Host "[Test-LocalInstall] Copying $cliModuleName → $cliInstallDest"
if (Test-Path $cliInstallDest) {
    Remove-Item $cliInstallDest -Recurse -Force
}
$null = New-Item -ItemType Directory -Path $userModules -Force
Copy-Item -LiteralPath $cliSource -Destination $cliInstallDest -Recurse -Force
Write-Host "[Test-LocalInstall] Copy complete."

if (-not (Test-Path (Join-Path $cliInstallDest "$cliModuleName.psd1"))) {
    throw "Installed manifest not found at $cliInstallDest\$cliModuleName.psd1"
}

# ── Step 3: import by name ────────────────────────────────────────────────────
Remove-Module $cliModuleName  -Force -ErrorAction SilentlyContinue
Remove-Module $packModuleName -Force -ErrorAction SilentlyContinue
Write-Host "[Test-LocalInstall] Importing $cliModuleName by name..."
Import-Module $cliModuleName -Force

$importedFrom = (Get-Module $cliModuleName).ModuleBase
Write-Host "[Test-LocalInstall] Loaded from: $importedFrom"
if ($importedFrom -ne $cliInstallDest) {
    Write-Warning "[Test-LocalInstall] Module loaded from unexpected location: $importedFrom (expected $cliInstallDest)"
}

# ── Step 4: run Pester against the installed copy's tests ────────────────────
$testsPath = Join-Path $cliInstallDest 'tests'
Write-Host "[Test-LocalInstall] Running Pester tests from $testsPath ..."

$result = Invoke-Pester -Path $testsPath -Output Normal -PassThru

# ── Step 5: report ────────────────────────────────────────────────────────────
Write-Host ""
if ($result.FailedCount -eq 0) {
    Write-Host "[Test-LocalInstall] PASS — $($result.PassedCount) tests passed." -ForegroundColor Green
} else {
    Write-Host "[Test-LocalInstall] FAIL — $($result.FailedCount) failed, $($result.PassedCount) passed." -ForegroundColor Red
}

# ── Step 6: optional cleanup ──────────────────────────────────────────────────
if ($Cleanup) {
    Remove-Module $cliModuleName  -Force -ErrorAction SilentlyContinue
    Remove-Module $packModuleName -Force -ErrorAction SilentlyContinue
    Remove-Item $cliInstallDest -Recurse -Force
    Write-Host "[Test-LocalInstall] Cleaned up: $cliInstallDest removed."

    $packInstallDest = Join-Path $userModules $packModuleName
    if (Test-Path $packInstallDest) {
        Remove-Item $packInstallDest -Recurse -Force
        Write-Host "[Test-LocalInstall] Cleaned up: $packInstallDest removed."
    }
}

# Propagate failure to calling process
if ($result.FailedCount -gt 0) {
    exit 1
}
