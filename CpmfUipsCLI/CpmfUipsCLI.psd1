@{
    RootModule        = 'CpmfUipsCLI.psm1'
    ModuleVersion     = '0.3.1'
    GUID              = '4c877d80-6d0c-403e-b0f2-02120b868ef8'
    Author            = 'Christian Prior-Mamulyan'
    CompanyName       = 'cprima'
    Copyright         = '(c) Christian Prior-Mamulyan. All rights reserved.'
    Description       = 'Thin CLI wrapper around CpmfUipsPack. Provides a single Invoke-CpmfUipsCLI entry point that dispatches to all CpmfUipsPack public functions. Env-var injection, SupportsShouldProcess, and machine-readable output throughout. UiPath and UiPath Studio are trademarks of UiPath Inc. This module is not affiliated with or endorsed by UiPath Inc.'
    PowerShellVersion = '7.0'

    RequiredModules   = @(
        @{ ModuleName = 'CpmfUipsPack'; ModuleVersion = '0.3.5'; MaximumVersion = '0.3.9999' }
    )

    FunctionsToExport = @(
        'Invoke-CpmfUipsCLI'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()

    PrivateData = @{
        PSData = @{
            Tags        = @('UiPath', 'RPA', 'NuGet', 'CI', 'pack', 'cli', 'cpmf-uips')
            LicenseUri  = 'https://github.com/rpapub/cpmf-uips-pwshcli/blob/main/LICENSE'
            ProjectUri  = 'https://github.com/rpapub/cpmf-uips-pwshcli'
            ReleaseNotes = '0.3.1 renames -Version to -ShowVersion and adds -ProjectVersion [string] forwarded to the pack subcommand. Requires CpmfUipsPack >= 0.3.5. Full changelog: https://github.com/rpapub/cpmf-uips-pwshcli/blob/main/CHANGELOG.md'
        }
    }
}
