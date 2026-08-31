# CpmfUipsCLI

A thin PowerShell 7 CLI wrapper. It wraps [CpmfUipsPack](https://github.com/rpapub/cpmf-uips-pwshpack), providing a single `Invoke-CpmfUipsCLI` entry point with tab-completable subcommands and shared path-first configuration via `CPMF_UIPS_*_PATH`.

> **Trademark notice:** UiPath and UiPath Studio are trademarks of UiPath Inc.
> This module is not affiliated with or endorsed by UiPath Inc.

---

## Requirements

- PowerShell 7.0 or later
- Windows (x64)
- [CpmfUipsPack](https://www.powershellgallery.com/packages/CpmfUipsPack) >= 0.3.0 (installed automatically as a `RequiredModules` dependency)

---

## Installation

```powershell
Install-Module CpmfUipsCLI -Scope CurrentUser
```

`CpmfUipsPack` is declared as a `RequiredModules` dependency and will be installed automatically.

### Update

```powershell
# If originally installed via Install-Module:
Update-Module CpmfUipsCLI

# If installed any other way (local copy, manual import, etc.):
Install-Module CpmfUipsCLI -Scope CurrentUser -Force
Import-Module CpmfUipsCLI -Force
```

---

## Quick start

```powershell
# Bump version, pack, copy .nupkg to the configured feed
Invoke-CpmfUipsCLI pack -ProjectJson 'C:\repos\MyProject\project.json'

# Show the wrapper and dependency versions and exit
Invoke-CpmfUipsCLI -Version

# Run diagnostics (pseudonymized — safe to paste into a GitHub issue)
Invoke-CpmfUipsCLI diagnose
```

---

## Subcommands

| Subcommand | Dispatches to | Purpose |
|---|---|---|
| `pack` | `Invoke-CpmfUipsPack` | Bump, pack, stage `.nupkg` |
| `analyze` | `Invoke-CpmfUipsAnalyze` | Run the Workflow Analyzer against a project |
| `install-tool` | `Install-CpmfUipsPackCommandLineTool` | Download uipcli and .NET runtime into user profile |
| `uninstall-tool` | `Uninstall-CpmfUipsPackCommandLineTool` | Remove uipcli and runtime |
| `install-uipathcli` | `Install-UipathcliTool` | Download the uipathcli Go binary |
| `uninstall-uipathcli` | `Uninstall-UipathcliTool` | Remove the uipathcli Go binary |
| `install-config` | `Install-CpmfUipsPackConfig` | Scaffold user-level config file |
| `uninstall-config` | `Uninstall-CpmfUipsPackConfig` | Remove user-level config file |
| `install-hook` | `Install-CpmfUipsPackGitHook` | Install git pre-push hook |
| `diagnose` | `Get-CpmfUipsPackDiagnostics` | Pseudonymized environment report |

All subcommands support `-WhatIf`, `-Confirm`, and `-Verbose`.

---

## Common options

```powershell
# Pack without bumping the version
Invoke-CpmfUipsCLI pack -ProjectJson '...' -NoBump

# Pack from a clean git worktree — avoids Studio file locks
Invoke-CpmfUipsCLI pack -ProjectJson '...' -UseWorktree

# Send the .nupkg to a different feed directory
Invoke-CpmfUipsCLI pack -ProjectJson '...' -FeedPath 'D:\nugetfeed'

# Dry run
Invoke-CpmfUipsCLI pack -ProjectJson '...' -WhatIf

# Build for both .NET 6 and .NET 8 Orchestrators
Invoke-CpmfUipsCLI pack -ProjectJson '...' -Targets net6, net8

# Install tools for net8
Invoke-CpmfUipsCLI install-tool -CliVersionNet8 '25.10.11'

# Install git pre-push hook
Invoke-CpmfUipsCLI install-hook -ProjectJson 'C:\repos\MyProject\project.json'
```

---

## Pack backends

`-Backend` chooses the tool that performs the pack: `workflowcompiler` (default), `uipcli`,
or `uipathcli`. `-Targets` defaults to `net8`.

`workflowcompiler` invokes `UiPath.WorkflowCompiler` directly — the engine the other two
drive internally. It exists because the compiler's `--include-sources` defaults to **true**
and `uipcli package pack` exposes no flag for it, so packages packed through `uipcli` ship
their full `.cs` source in plaintext under `content/`. This backend defaults it to `false`
and can also override the package id without editing `project.json`.

```powershell
Invoke-CpmfUipsCLI pack -ProjectJson '...\project.json' -Targets net8 `
    -Backend workflowcompiler `
    -PublisherProps 'D:\schemas\publisher.props' `
    -PackageId 'MyBrand.MyLib'

# Ship sources deliberately
Invoke-CpmfUipsCLI pack -ProjectJson '...' -Backend workflowcompiler -IncludeSources
```

`-PublisherProps` reads shared package identity (author, tags, project URL, repository
type) and pack policy from an MSBuild-style `.props` file, plus the compiler location via
`PublisherPackWorkflowCompilerPath`. Individual fields can also be passed directly:
`-PackageId`, `-PackageAuthor`, `-PackageDescription`, `-PackageTags`, `-IconUrl`,
`-ProjectUrl`, `-ReleaseNotes`, `-RepositoryType`, `-RepositoryUrl`, `-RepositoryBranch`,
`-RepositoryCommit`. Repository fields default to the project's git checkout.

The backend is net8-only: `-MultiTfm` and `-Targets net6` are rejected, and `analyze` is
not supported for it. Use `-Backend uipcli -Targets net6` for a net6 build, or
`-Backend uipcli -Targets net6,net8 -MultiTfm` to merge both TFMs — those backends always
pack sources and ignore the identity parameters, and warn when you supply them.

---

## Configuration

`CpmfUipsCLI` uses the same path-first configuration model as `CpmfUipsPack`. Settings are applied in priority order — a higher-priority source always wins.

```
Priority (lowest → highest)
────────────────────────────────────────────────────────────────
 1. Repo config     .\cpmf-uips.psd1
 2. Env vars        CPMF_UIPS_*_PATH, UIPS_* (compatibility)
 3. Project config  -ConfigFile .\uipath-pack.psd1
 4. Parameters      -FeedPath, -Targets, ...   ← always win
────────────────────────────────────────────────────────────────
```

`CpmfUipsCLI` applies the repo-root defaults and environment variables at the CLI layer before forwarding to `CpmfUipsPack`, so both modules honour them correctly.

| Variable | Parameter | Notes |
|---|---|---|
| `CPMF_UIPS_UIPCLI_NET6_PATH` | `-UipcliPathNet6` | path to the .NET 6 `uipcli.exe` |
| `CPMF_UIPS_UIPCLI_NET8_PATH` | `-UipcliPathNet8` | path to the .NET 8 `uipcli.exe` |
| `CPMF_UIPS_TOOLBASE_PATH` | `-ToolBasePath` | root directory for managed tools |
| `CPMF_UIPS_OUTPUT_PATH` | `-OutputPath` | base directory for native `uipcli` output |
| `UIPS_FEEDPATH` | `-FeedPath` | compatibility |
| `UIPS_TOOLBASE` | `-ToolBasePath` | compatibility |
| `UIPS_TARGETS` | `-Targets` | comma-separated: `net6,net8` |
| `UIPS_CLIVERSION_NET6` | `-CliVersionNet6` | |
| `UIPS_CLIVERSION_NET8` | `-CliVersionNet8` | |
| `UIPS_USE_WORKTREE` | `-UseWorktree` | any non-empty value = `$true` |
| `UIPS_NO_BUMP` | `-NoBump` | any non-empty value = `$true` |

```powershell
# Example: CI pipeline injects tool path via env var
$env:CPMF_UIPS_TOOLBASE_PATH = 'D:\cpmf\tools'
Invoke-CpmfUipsCLI pack -ProjectJson '...'
```

---

## Diagnostics

```powershell
Invoke-CpmfUipsCLI diagnose
```

Returns a pseudonymized environment report — no usernames, computer names, or personal paths. Safe to paste directly into a GitHub issue.

---

## Uninstall

```powershell
# Remove uipcli and .NET runtimes
Invoke-CpmfUipsCLI uninstall-tool                                    # net6
Invoke-CpmfUipsCLI uninstall-tool -CliVersionNet8 '25.10.11'        # net8

# Remove user-level config
Invoke-CpmfUipsCLI uninstall-config

# Remove both modules
Uninstall-Module CpmfUipsCLI
Uninstall-Module CpmfUipsPack
```

---

## Help wanted

The full install chain (CpmfUipsPack installing .NET and uipcli from scratch, then CpmfUipsCLI on top) has not been verified on a clean machine. If you test this, please [open an issue](https://github.com/rpapub/cpmf-uips-pwshcli/issues/1) and report your findings.

---

## License

Apache 2.0 — © 2026 Christian Prior-Mamulyan
