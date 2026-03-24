function Invoke-CpmfUipsCLI {
    <#
    .SYNOPSIS
        Single entry point for the CpmfUipsCLI wrapper. Dispatches to CpmfUipsPack public functions.

    .DESCRIPTION
        Invoke-CpmfUipsCLI routes a subcommand string to the corresponding CpmfUipsPack function.
        All remaining parameters are forwarded via splatting. UIPS_* environment variables are
        applied as defaults before forwarding, following the same four-layer hierarchy as CpmfUipsPack.

        Subcommands:
          pack                  Invoke-CpmfUipsPack
          analyze               Invoke-CpmfUipsAnalyze
          install-tool          Install-CpmfUipsPackCommandLineTool
          uninstall-tool        Uninstall-CpmfUipsPackCommandLineTool
          install-uipathcli     Install-UipathcliTool
          uninstall-uipathcli   Uninstall-UipathcliTool
          install-config        Install-CpmfUipsPackConfig
          uninstall-config      Uninstall-CpmfUipsPackConfig
          install-hook          Install-CpmfUipsPackGitHook
          diagnose              Get-CpmfUipsPackDiagnostics

    .PARAMETER Command
        The subcommand to execute. Tab-completable.

    .PARAMETER ProjectJson
        Path to the UiPath project.json. Forwarded to pack and install-hook subcommands.

    .PARAMETER FeedPath
        NuGet feed path. Forwarded to pack. Defaults to UIPS_FEEDPATH env var if set.

    .PARAMETER Targets
        Target TFMs to build. E.g. @('net6') or @('net6','net8'). Forwarded to pack.

    .PARAMETER NoBump
        Skip the version bump. Forwarded to pack.

    .PARAMETER UseWorktree
        Pack from a clean git worktree. Forwarded to pack.

    .PARAMETER SkipInstall
        Skip uipcli auto-install. Forwarded to pack.

    .PARAMETER MultiTfm
        Merge net6/net8 TFM outputs into a single nupkg. Forwarded to pack.

    .PARAMETER ConfigFile
        Per-project config file (.psd1). Forwarded to pack.

    .PARAMETER CliVersion
        uipcli version (deprecated alias). Forwarded to pack.

    .PARAMETER CliVersionNet6
        uipcli version for the net6 target. Forwarded to pack and install-tool.

    .PARAMETER CliVersionNet8
        uipcli version for the net8 target. Forwarded to pack and install-tool.

    .PARAMETER ToolBase
        Base directory for managed tool installs. Forwarded to pack, install-tool, uninstall-tool.

    .PARAMETER Force
        Overwrite existing config. Forwarded to install-config.

    .EXAMPLE
        Invoke-CpmfUipsCLI pack -ProjectJson C:\repos\MyBot\project.json

    .EXAMPLE
        Invoke-CpmfUipsCLI pack -ProjectJson C:\repos\MyBot\project.json -Targets net6,net8 -WhatIf

    .EXAMPLE
        Invoke-CpmfUipsCLI install-tool

    .EXAMPLE
        Invoke-CpmfUipsCLI diagnose

    .OUTPUTS
        [string[]] for the pack subcommand (paths to staged .nupkg files).
        [string]   for the diagnose subcommand (pseudonymized environment report).
        No output for lifecycle subcommands.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([string[]], ParameterSetName = '__AllParameterSets')]
    param(
        [Parameter(Mandatory, Position = 0)]
        [ValidateSet('pack', 'analyze', 'install-tool', 'uninstall-tool', 'install-uipathcli', 'uninstall-uipathcli', 'install-config', 'uninstall-config', 'install-hook', 'diagnose')]
        [string] $Command,

        # --- shared / pack / analyze ---
        [string]   $ProjectJson,
        [string]   $FeedPath,
        [string[]] $Targets,
        [ValidateSet('uipcli', 'uipathcli')]
        [string]   $Backend,
        [switch]   $NoBump,
        [switch]   $UseWorktree,
        [switch]   $SkipInstall,
        [switch]   $MultiTfm,
        [string]   $ConfigFile,

        # --- tool version ---
        [string]   $CliVersion,        # deprecated passthrough
        [string]   $CliVersionNet6,
        [string]   $CliVersionNet8,
        [string]   $ToolBase,

        # --- install-config ---
        [switch]   $Force
    )

    # Inject UIPS_* env var defaults before forwarding (Layer 2 of config hierarchy).
    # Explicit parameters always win — only apply env var when the caller did not bind the param.
    if (-not $PSBoundParameters.ContainsKey('FeedPath') -and $env:UIPS_FEEDPATH) {
        $FeedPath = $env:UIPS_FEEDPATH
        $PSBoundParameters['FeedPath'] = $FeedPath
    }
    if (-not $PSBoundParameters.ContainsKey('ToolBase') -and $env:UIPS_TOOLBASE) {
        $ToolBase = $env:UIPS_TOOLBASE
        $PSBoundParameters['ToolBase'] = $ToolBase
    }
    if (-not $PSBoundParameters.ContainsKey('Targets') -and $env:UIPS_TARGETS) {
        $Targets = $env:UIPS_TARGETS -split ','
        $PSBoundParameters['Targets'] = $Targets
    }
    if (-not $PSBoundParameters.ContainsKey('NoBump') -and $env:UIPS_NO_BUMP -eq '1') {
        $NoBump = $true
        $PSBoundParameters['NoBump'] = $NoBump
    }

    # Build a plain hashtable copy for splatting — PSBoundParametersDictionary has no .Clone().
    $forwardParams = @{}
    foreach ($kv in $PSBoundParameters.GetEnumerator()) { $forwardParams[$kv.Key] = $kv.Value }
    $forwardParams.Remove('Command') | Out-Null

    # Also remove CLI-only params not accepted by specific subcommands.
    $toolOnly     = @('CliVersionNet6', 'CliVersionNet8', 'ToolBase')
    $configOnly   = @('Force')

    switch ($Command) {
        'pack' {
            $remove = @('Force')
            foreach ($k in $remove) { $forwardParams.Remove($k) | Out-Null }
            Write-Verbose "[CpmfUipsCLI] → Invoke-CpmfUipsPack"
            $projectName = if ($ProjectJson) { Split-Path (Split-Path $ProjectJson -Parent) -Leaf } else { '(unknown)' }
            Write-Host "[pack] Packing $projectName …"
            $packResults = @(Invoke-CpmfUipsPack @forwardParams)
            foreach ($path in $packResults) {
                Write-Host "[pack] Staged: $(Split-Path $path -Leaf)"
            }
            Write-Output $packResults
        }

        'analyze' {
            $remove = @('FeedPath', 'UseWorktree', 'WorktreeSibling', 'MultiTfm', 'Force')
            foreach ($k in $remove) { $forwardParams.Remove($k) | Out-Null }
            Write-Verbose "[CpmfUipsCLI] → Invoke-CpmfUipsAnalyze"
            $projectName = if ($ProjectJson) { Split-Path (Split-Path $ProjectJson -Parent) -Leaf } else { '(unknown)' }
            Write-Host "[analyze] Analyzing $projectName …"
            Write-Output (Invoke-CpmfUipsAnalyze @forwardParams)
        }

        'install-uipathcli' {
            $keep = @('ToolBase', 'WhatIf', 'Confirm', 'Verbose')
            $toRemove = @($forwardParams.Keys) | Where-Object { $_ -notin $keep }
            foreach ($k in $toRemove) { $forwardParams.Remove($k) | Out-Null }
            Write-Verbose "[CpmfUipsCLI] → Install-UipathcliTool"
            Install-UipathcliTool @forwardParams
        }

        'uninstall-uipathcli' {
            $keep = @('ToolBase', 'WhatIf', 'Confirm', 'Verbose')
            $toRemove = @($forwardParams.Keys) | Where-Object { $_ -notin $keep }
            foreach ($k in $toRemove) { $forwardParams.Remove($k) | Out-Null }
            Write-Verbose "[CpmfUipsCLI] → Uninstall-UipathcliTool"
            Uninstall-UipathcliTool @forwardParams
        }

        'install-tool' {
            $keep = $toolOnly + @('WhatIf', 'Confirm', 'Verbose')
            $toRemove = @($forwardParams.Keys) | Where-Object { $_ -notin $keep }
            foreach ($k in $toRemove) { $forwardParams.Remove($k) | Out-Null }
            Write-Verbose "[CpmfUipsCLI] → Install-CpmfUipsPackCommandLineTool"
            Install-CpmfUipsPackCommandLineTool @forwardParams
        }

        'uninstall-tool' {
            $keep = $toolOnly + @('WhatIf', 'Confirm', 'Verbose')
            $toRemove = @($forwardParams.Keys) | Where-Object { $_ -notin $keep }
            foreach ($k in $toRemove) { $forwardParams.Remove($k) | Out-Null }
            Write-Verbose "[CpmfUipsCLI] → Uninstall-CpmfUipsPackCommandLineTool"
            Uninstall-CpmfUipsPackCommandLineTool @forwardParams
        }

        'install-config' {
            $keep = $configOnly + @('WhatIf', 'Confirm', 'Verbose')
            $toRemove = @($forwardParams.Keys) | Where-Object { $_ -notin $keep }
            foreach ($k in $toRemove) { $forwardParams.Remove($k) | Out-Null }
            Write-Verbose "[CpmfUipsCLI] → Install-CpmfUipsPackConfig"
            Install-CpmfUipsPackConfig @forwardParams
        }

        'uninstall-config' {
            $toRemove = @($forwardParams.Keys) | Where-Object { $_ -notin @('WhatIf', 'Confirm', 'Verbose') }
            foreach ($k in $toRemove) { $forwardParams.Remove($k) | Out-Null }
            Write-Verbose "[CpmfUipsCLI] → Uninstall-CpmfUipsPackConfig"
            Uninstall-CpmfUipsPackConfig @forwardParams
        }

        'install-hook' {
            $keep = @('ProjectJson', 'WhatIf', 'Confirm', 'Verbose')
            $toRemove = @($forwardParams.Keys) | Where-Object { $_ -notin $keep }
            foreach ($k in $toRemove) { $forwardParams.Remove($k) | Out-Null }
            Write-Verbose "[CpmfUipsCLI] → Install-CpmfUipsPackGitHook"
            Install-CpmfUipsPackGitHook @forwardParams
        }

        'diagnose' {
            $toRemove = @($forwardParams.Keys) | Where-Object { $_ -notin @('Verbose') }
            foreach ($k in $toRemove) { $forwardParams.Remove($k) | Out-Null }
            Write-Verbose "[CpmfUipsCLI] → Get-CpmfUipsPackDiagnostics"
            Write-Output (Get-CpmfUipsPackDiagnostics @forwardParams)
        }
    }
}
