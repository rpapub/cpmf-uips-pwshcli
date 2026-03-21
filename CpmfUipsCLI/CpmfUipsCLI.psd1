@{
    RootModule        = 'CpmfUipsCLI.psm1'
    ModuleVersion     = '0.1.0'
    GUID              = '4c877d80-6d0c-403e-b0f2-02120b868ef8'
    Author            = 'Christian Prior-Mamulyan'
    CompanyName       = 'cprima'
    Copyright         = '(c) Christian Prior-Mamulyan. All rights reserved.'
    Description       = 'Thin CLI wrapper around CpmfUipsPack. Provides a single Invoke-CpmfUipsCLI entry point that dispatches to all CpmfUipsPack public functions. Env-var injection, SupportsShouldProcess, and machine-readable output throughout. UiPath and UiPath Studio are trademarks of UiPath Inc. This module is not affiliated with or endorsed by UiPath Inc.'
    PowerShellVersion = '7.0'

    RequiredModules   = @(
        @{ ModuleName = 'CpmfUipsPack'; ModuleVersion = '0.1.0' }
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
            ReleaseNotes = 'Exploratory release. Single Invoke-CpmfUipsCLI dispatcher wrapping all CpmfUipsPack public functions.'
        }
    }
}
