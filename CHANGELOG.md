# Changelog

All notable changes to CpmfUipsCLI are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Versions follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.3.0] — 2026-05-06

### Changed

- **Path-first CLI configuration** — `CPMF_UIPS_UIPCLI_NET6_PATH`,
  `CPMF_UIPS_UIPCLI_NET8_PATH`, and `CPMF_UIPS_TOOLBASE_PATH` are now
  first-class inputs. Repo-root `cpmf-uips.psd1` supplies opinionated defaults,
  env vars override config, and compatibility `UIPS_*` values are still honored
  during the transition.

- **`Invoke-CpmfUipsCLI`** — now accepts `-Version` to print the wrapper and
  dependency versions without dispatching a subcommand.

- **Required module floor** — `CpmfUipsCLI.psd1` now requires
  `CpmfUipsPack >= 0.3.0`.

---

## [0.2.2] — 2026-05-05

### Changed

- **`CpmfUipsCLI.psd1`** — `RequiredModules` minimum version raised from `0.2.0` to `0.2.5`.
  `CpmfUipsPack 0.2.5` defaults `install-tool` / `uninstall-tool` to uipcli `25.10.15` and
  fixes version dispatch for the dotnet global tool packaging format introduced in `25.10.2-20251124-7`.

---

## [0.2.1] — 2026-03-24

### Fixed

- **`install-tool` / `uninstall-tool`** — translate `-CliVersionNet6` / `-CliVersionNet8`
  to `-CliVersion` before forwarding to `Install-CpmfUipsPackCommandLineTool` /
  `Uninstall-CpmfUipsPackCommandLineTool`. Previously passing `-CliVersionNet8` threw
  `A parameter cannot be found that matches parameter name 'CliVersionNet8'`. Closes #10.

---

## [0.2.0] — 2026-03-24

### Added

- **`analyze` subcommand** — dispatches to `Invoke-CpmfUipsAnalyze` in
  CpmfUipsPack. Returns analyzer output as `[string[]]`.
- **`-Backend uipcli|uipathcli`** — forwarded to both `pack` and `analyze`
  subcommands. Defaults to `uipcli` (no breaking change).
- **`install-uipathcli` / `uninstall-uipathcli` subcommands** — manage the
  uipathcli Go binary via `Install-UipathcliTool` / `Uninstall-UipathcliTool`.

### Changed

- Requires CpmfUipsPack `0.2.0`.

---

## [0.1.1] — 2026-03-21

### Added

- **Pack progress feedback** — `Invoke-CpmfUipsCLI pack` now emits `[pack] Packing <name> …`
  before dispatching and `[pack] Staged: <file>` for each staged nupkg on success. These
  `Write-Host` messages are always visible without `-Verbose`, preventing the silent-hang
  appearance during long uipcli runs.

### Changed

- `RequiredModules` bumped to `CpmfUipsPack 0.1.1` to pick up the noise-filtered failure
  output and GUID temp-folder fix.

---

## [0.1.0] — 2026-03-21

Initial release. Establishes the module structure and dispatch pattern.

### Added

**Single entry point dispatcher**
- `Invoke-CpmfUipsCLI` — routes a tab-completable `-Command` string to the
  corresponding `CpmfUipsPack` public function via splatting

**Subcommands**
- `pack` → `Invoke-CpmfUipsPack`
- `install-tool` → `Install-CpmfUipsPackCommandLineTool`
- `uninstall-tool` → `Uninstall-CpmfUipsPackCommandLineTool`
- `install-config` → `Install-CpmfUipsPackConfig`
- `uninstall-config` → `Uninstall-CpmfUipsPackConfig`
- `install-hook` → `Install-CpmfUipsPackGitHook`
- `diagnose` → `Get-CpmfUipsPackDiagnostics`

**UIPS_* environment variable injection**
- Applied at the CLI layer before forwarding to `CpmfUipsPack`
- Explicit parameters always win; env vars fill in only unbound parameters
- Supported: `UIPS_FEEDPATH`, `UIPS_TOOLBASE`, `UIPS_TARGETS`,
  `UIPS_CLIVERSION_NET6`, `UIPS_CLIVERSION_NET8`, `UIPS_USE_WORKTREE`,
  `UIPS_NO_BUMP`

**Stream discipline**
- Zero `Write-Host` — all progress via `Write-Verbose`, results via `Write-Output`
- `PSScriptAnalyzer` configured to flag any `Write-Host` addition as an error

**Test infrastructure**
- 11 Pester 5 tests covering all subcommand routes, parameter filtering, and
  env-var override behaviour
- `scripts/Test-LocalInstall.ps1` — installs `CpmfUipsPack` (via its own
  test script), then copies `CpmfUipsCLI` to user PSModulePath, imports by
  name, runs Pester; supports `-SkipPackInstall` and `-Cleanup`

**Reference documentation**
- `docs/reference/Invoke-CpmfUipsCLI.md` — platyPS-generated reference page
- `CpmfUipsCLI/en-US/CpmfUipsCLI-help.xml` — MAML help file

[Unreleased]: https://github.com/rpapub/cpmf-uips-pwshcli/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/rpapub/cpmf-uips-pwshcli/releases/tag/v0.1.0
