# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`CpmfUipsCLI` is a **thin CLI wrapper** around `CpmfUipsPack`. It adds nothing beyond:

1. A single `Invoke-CpmfUipsCLI` entry point with tab-completable subcommands
2. UIPS_* env-var injection at the CLI layer (before forwarding to CpmfUipsPack)
3. Clean stream discipline — no Write-Host anywhere

**No business logic lives here.** All UiPath pack/install/version logic stays in `CpmfUipsPack`.

Dependency: `CpmfUipsPack >= 0.1.0` (declared in `RequiredModules`).

## Module structure

```
CpmfUipsCLI/
  CpmfUipsCLI.psd1              # Manifest — RequiredModules = CpmfUipsPack 0.1.0
  CpmfUipsCLI.psm1              # Loader: dot-sources Public/
  PSScriptAnalyzerSettings.psd1
  Public/
    Invoke-CpmfUipsCLI.ps1      # Single dispatcher; routes $Command to CpmfUipsPack functions
  tests/
    Invoke-CpmfUipsCLI.Tests.ps1
```

## Commands

```powershell
# Run tests (CpmfUipsPack must be importable — either installed or on the sibling path)
Invoke-Pester ./CpmfUipsCLI/tests/ -Output Normal

# Lint
Invoke-ScriptAnalyzer -Path ./CpmfUipsCLI -Recurse -Settings ./CpmfUipsCLI/PSScriptAnalyzerSettings.psd1

# Validate manifest
Test-ModuleManifest ./CpmfUipsCLI/CpmfUipsCLI.psd1

# Load locally (CpmfUipsPack must already be imported)
Import-Module ./CpmfUipsCLI/CpmfUipsCLI.psd1 -Force
```

## Subcommand routing

`Invoke-CpmfUipsCLI -Command <subcommand>` dispatches to:

| Subcommand       | CpmfUipsPack function                      |
|------------------|--------------------------------------------|
| `pack`           | `Invoke-CpmfUipsPack`                      |
| `install-tool`   | `Install-CpmfUipsPackCommandLineTool`      |
| `uninstall-tool` | `Uninstall-CpmfUipsPackCommandLineTool`    |
| `install-config` | `Install-CpmfUipsPackConfig`               |
| `uninstall-config`| `Uninstall-CpmfUipsPackConfig`            |
| `install-hook`   | `Install-CpmfUipsPackGitHook`              |
| `diagnose`       | `Get-CpmfUipsPackDiagnostics`              |

## Stream discipline (enforced — no exceptions)

| Stream        | Cmdlet          | When                                   |
|---------------|-----------------|----------------------------------------|
| Pipeline      | `Write-Output`  | Machine-readable results (paths, strings) |
| Progress      | `Write-Verbose` | Human-readable status (opt-in)         |
| Anomalies     | `Write-Warning` | Recoverable issues, deprecations       |
| Errors        | `throw`         | Terminating failures                   |
| **Never**     | `Write-Host`    | —                                      |

PSScriptAnalyzer is configured to flag any `Write-Host` addition as an error.

## Env-var injection pattern

The dispatcher applies UIPS_* env vars as Layer-2 defaults before forwarding:

```powershell
if (-not $PSBoundParameters.ContainsKey('FeedPath') -and $env:UIPS_FEEDPATH) {
    $PSBoundParameters['FeedPath'] = $env:UIPS_FEEDPATH
}
```

Explicit parameters always win. Do not change this pattern.

## Adding a new subcommand

1. Add the value to `[ValidateSet(...)]` in `Invoke-CpmfUipsCLI.ps1`
2. Add a `case` block in the `switch` that strips irrelevant params and splats to the target function
3. Add a test in `Invoke-CpmfUipsCLI.Tests.ps1` verifying the mock is called
4. Update the subcommand table in this CLAUDE.md and in README.md
