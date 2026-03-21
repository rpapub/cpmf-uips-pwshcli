# Changelog

All notable changes to CpmfUipsCLI are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Versions follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

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
