# CpmfUipsCLI

A thin PowerShell 7 CLI wrapper. Initially wraps [CpmfUipsPack](https://github.com/rpapub/cpmf-uips-pwshpack), providing a single `Invoke-CpmfUipsCLI` entry point with tab-completable subcommands and `UIPS_*` environment variable injection.

> **Trademark notice:** UiPath and UiPath Studio are trademarks of UiPath Inc.
> This module is not affiliated with or endorsed by UiPath Inc.

---

## Requirements

- PowerShell 7.0 or later
- Windows (x64)
- [CpmfUipsPack](https://www.powershellgallery.com/packages/CpmfUipsPack) >= 0.1.0 (installed automatically as a `RequiredModules` dependency)

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

# Run diagnostics (pseudonymized — safe to paste into a GitHub issue)
Invoke-CpmfUipsCLI diagnose
```

---

## Subcommands

| Subcommand | Dispatches to | Purpose |
|---|---|---|
| `pack` | `Invoke-CpmfUipsPack` | Bump, pack, stage `.nupkg` |
| `install-tool` | `Install-CpmfUipsPackCommandLineTool` | Download uipcli and .NET runtime into user profile |
| `uninstall-tool` | `Uninstall-CpmfUipsPackCommandLineTool` | Remove uipcli and runtime |
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

## Configuration

`CpmfUipsCLI` inherits the full four-layer configuration hierarchy from `CpmfUipsPack`. Settings are applied in priority order — a higher-priority source always wins.

```
Priority (lowest → highest)
────────────────────────────────────────────────────────────────
 1. User config     %LOCALAPPDATA%\cpmf\CpmfUipsPack\config.psd1
 2. Env vars        UIPS_*
 3. Project config  -ConfigFile .\uipath-pack.psd1
 4. Parameters      -FeedPath, -Targets, ...   ← always win
────────────────────────────────────────────────────────────────
```

`CpmfUipsCLI` applies `UIPS_*` env vars at the CLI layer before forwarding to `CpmfUipsPack`, so both modules honour them correctly.

| Variable | Parameter | Notes |
|---|---|---|
| `UIPS_FEEDPATH` | `-FeedPath` | |
| `UIPS_TOOLBASE` | `-ToolBase` | |
| `UIPS_TARGETS` | `-Targets` | comma-separated: `net6,net8` |
| `UIPS_CLIVERSION_NET6` | `-CliVersionNet6` | |
| `UIPS_CLIVERSION_NET8` | `-CliVersionNet8` | |
| `UIPS_USE_WORKTREE` | `-UseWorktree` | any non-empty value = `$true` |
| `UIPS_NO_BUMP` | `-NoBump` | any non-empty value = `$true` |

```powershell
# Example: CI pipeline injects feed path via env var
$env:UIPS_FEEDPATH = '\\buildserver\nugetfeed'
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
