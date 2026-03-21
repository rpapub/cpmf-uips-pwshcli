# Contributing to CpmfUipsCLI

## Prerequisites

- PowerShell 7+
- Git
- Pester 5: `Install-Module Pester -Scope CurrentUser -Force`
- PSScriptAnalyzer: `Install-Module PSScriptAnalyzer -Scope CurrentUser -Force`
- `CpmfUipsPack` installed: `Install-Module CpmfUipsPack -Scope CurrentUser -Force`

## Setup after cloning

```powershell
# Activate the pre-push hook (once per clone)
pwsh -File scripts/Install-GitHooks.ps1
```

This sets `core.hooksPath = ./hooks` in your local git config so that
`hooks/pre-push` runs automatically before every `git push`.

## Running checks locally

```powershell
# All Pester tests
Invoke-Pester ./CpmfUipsCLI/tests/ -Output Normal

# PSScriptAnalyzer
Invoke-ScriptAnalyzer -Path ./CpmfUipsCLI -Recurse -Settings ./CpmfUipsCLI/PSScriptAnalyzerSettings.psd1

# Validate manifest
Test-ModuleManifest ./CpmfUipsCLI/CpmfUipsCLI.psd1

# Full pre-push gate (same as the hook)
pwsh -File scripts/Invoke-PrePushChecks.ps1
```

## Testing against latest CpmfUipsPack

The tests import `CpmfUipsCLI` by manifest path and mock all `CpmfUipsPack`
calls, so no live uipcli is needed for the test suite.

To smoke-test against the real pack module:

```powershell
Import-Module D:\path\to\cpmf-uips-pwshpack\CpmfUipsPack\CpmfUipsPack.psd1 -Force
Import-Module .\CpmfUipsCLI\CpmfUipsCLI.psd1 -Force
Invoke-CpmfUipsCLI pack -ProjectJson 'C:\path\to\project.json'
```

## Branch workflow

- `development` — active development; PRs target this branch
- `main` — protected; only merged via PR after CI passes
- Branch protection requires: CI green, no direct pushes

## Pre-push hook

`hooks/pre-push` is a bash shim (tracked in the repo) that calls
`scripts/Invoke-PrePushChecks.ps1`. It runs PSScriptAnalyzer and Pester and
blocks the push if either fails.

The hook only activates after running `scripts/Install-GitHooks.ps1` once.
Without that step git uses `.git/hooks/` (empty on a fresh clone).

## Releasing

1. Bump `ModuleVersion` in `CpmfUipsCLI/CpmfUipsCLI.psd1`
2. Bump `RequiredModules` `ModuleVersion` if a new `CpmfUipsPack` is required
3. Add a `## [x.y.z]` entry in `CHANGELOG.md`
4. Commit, push `development`, open PR → `main`
5. After merge: `git tag vx.y.z origin/main && git push origin vx.y.z`
6. The `publish.yml` workflow publishes to PSGallery automatically on a
   non-prerelease semver tag (`v[0-9]+.[0-9]+.[0-9]+`)
