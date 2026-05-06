function Get-CpmfUipsCLIEffectiveConfig {
<#
.SYNOPSIS
    Merges the CLI repo config and environment variables into one hashtable.

.DESCRIPTION
    Priority (lowest to highest): repo config → env vars.
    Explicit command-line parameters are NOT applied here — that is done by the
    caller (Invoke-CpmfUipsCLI) using PSBoundParameters.

    Layer 1 — Repo config (opinionated defaults):
        cpmf-uips.psd1 next to the module repo root.
        Loaded silently if present; missing file is not an error.

    Layer 2 — Environment variables:
        CPMF_UIPS_UIPCLI_NET6_PATH → UipcliPathNet6
        CPMF_UIPS_UIPCLI_NET8_PATH → UipcliPathNet8
        CPMF_UIPS_TOOLBASE_PATH    → ToolBasePath
        UIPS_FEEDPATH              → FeedPath
        UIPS_TOOLBASE              → ToolBasePath
        UIPS_TARGETS               → Targets
        UIPS_CLIVERSION_NET6       → CliVersionNet6
        UIPS_CLIVERSION_NET8       → CliVersionNet8
        UIPS_WORKTREE_BASE         → WorktreeBase
        UIPS_USE_WORKTREE          → UseWorktree
        UIPS_NO_BUMP               → NoBump
#>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param()

    function Resolve-ConfigValue {
        param([object]$Value)

        if ($Value -is [string] -and $Value -match '^\$env:([^\\]+)(.*)$') {
            $envName = $Matches[1]
            $suffix = $Matches[2]
            $envValue = [Environment]::GetEnvironmentVariable($envName)
            if ([string]::IsNullOrWhiteSpace($envValue)) {
                throw "Environment variable $envName is not set for config value '$Value'."
            }

            return Join-Path $envValue $suffix.TrimStart('\')
        }

        return $Value
    }

    $repoRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
    $repoConfigPath = Join-Path $repoRoot 'cpmf-uips.psd1'
    $repoCfg = if (Test-Path -LiteralPath $repoConfigPath) {
        Write-Verbose "[Config] Loading repo config: $repoConfigPath"
        $cfg = Read-CpmfUipsCLIConfig -Path $repoConfigPath
        foreach ($key in @($cfg.Keys)) {
            $cfg[$key] = Resolve-ConfigValue $cfg[$key]
        }
        $cfg
    } else {
        @{}
    }

    $envCfg = @{}
    $envMap = [ordered]@{
        'CPMF_UIPS_UIPCLI_NET6_PATH' = 'UipcliPathNet6'
        'CPMF_UIPS_UIPCLI_NET8_PATH' = 'UipcliPathNet8'
        'CPMF_UIPS_TOOLBASE_PATH'    = 'ToolBasePath'
        'UIPS_FEEDPATH'              = 'FeedPath'
        'UIPS_TOOLBASE'              = 'ToolBasePath'
        'UIPS_TARGETS'               = 'Targets'
        'UIPS_CLIVERSION_NET6'       = 'CliVersionNet6'
        'UIPS_CLIVERSION_NET8'       = 'CliVersionNet8'
        'UIPS_WORKTREE_BASE'         = 'WorktreeBase'
        'UIPS_USE_WORKTREE'          = 'UseWorktree'
        'UIPS_NO_BUMP'               = 'NoBump'
    }

    foreach ($envKey in $envMap.Keys) {
        $val = [Environment]::GetEnvironmentVariable($envKey)
        if (-not [string]::IsNullOrWhiteSpace($val)) {
            $paramKey = $envMap[$envKey]
            switch ($paramKey) {
                'Targets' {
                    $envCfg[$paramKey] = [string[]]($val -split ',\s*' | Where-Object { $_ -ne '' })
                }
                { $_ -in @('UseWorktree', 'NoBump') } {
                    $envCfg[$paramKey] = $true
                }
                default {
                    $envCfg[$paramKey] = $val
                }
            }
            Write-Verbose "[Config] Env var $envKey → $paramKey = $val"
        }
    }

    $merged = @{}
    foreach ($src in @($repoCfg, $envCfg)) {
        foreach ($k in $src.Keys) { $merged[$k] = $src[$k] }
    }

    return $merged
}
