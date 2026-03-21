#Requires -Version 7
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0' }

BeforeAll {
    $modulePath = Resolve-Path "$PSScriptRoot/../../CpmfUipsCLI/CpmfUipsCLI.psd1"

    # Import CpmfUipsPack from the sibling repo (dev path) if not already available.
    if (-not (Get-Module CpmfUipsPack)) {
        $packPath = Resolve-Path "$PSScriptRoot/../../../cpmf-uips-pwshpack/CpmfUipsPack/CpmfUipsPack.psd1" `
                    -ErrorAction SilentlyContinue
        if (-not $packPath) {
            # Fallback: installed copy
            $packPath = "$HOME/Documents/PowerShell/Modules/CpmfUipsPack/CpmfUipsPack.psd1"
        }
        Import-Module $packPath -Force -ErrorAction Stop
    }

    Import-Module $modulePath -Force -ErrorAction Stop
}

Describe 'Invoke-CpmfUipsCLI — dispatch' {

    Context 'pack subcommand' {
        It 'forwards to Invoke-CpmfUipsPack' {
            Mock -ModuleName CpmfUipsCLI Invoke-CpmfUipsPack { return @('C:\feed\MyBot.1.0.0.nupkg') }

            $result = Invoke-CpmfUipsCLI pack -ProjectJson 'C:\repos\MyBot\project.json'

            Should -Invoke Invoke-CpmfUipsPack -ModuleName CpmfUipsCLI -Times 1
            $result | Should -BeOfType [string]
        }

        It 'does not forward -Force to Invoke-CpmfUipsPack' {
            Mock -ModuleName CpmfUipsCLI Invoke-CpmfUipsPack {
                param([switch]$Force)
                if ($PSBoundParameters.ContainsKey('Force')) {
                    throw '-Force must not reach Invoke-CpmfUipsPack'
                }
                return @()
            }

            { Invoke-CpmfUipsCLI pack -ProjectJson 'C:\repos\MyBot\project.json' -Force } |
                Should -Not -Throw
            Should -Invoke Invoke-CpmfUipsPack -ModuleName CpmfUipsCLI -Times 1
        }

        It 'injects UIPS_FEEDPATH env var when FeedPath not bound' {
            $env:UIPS_FEEDPATH = 'D:\testfeed'
            Mock -ModuleName CpmfUipsCLI Invoke-CpmfUipsPack {
                param([string]$FeedPath)
                return @($FeedPath)
            }

            $result = Invoke-CpmfUipsCLI pack -ProjectJson 'C:\repos\MyBot\project.json'

            $result | Should -Be 'D:\testfeed'
            Should -Invoke Invoke-CpmfUipsPack -ModuleName CpmfUipsCLI -Times 1
            Remove-Item Env:\UIPS_FEEDPATH -ErrorAction SilentlyContinue
        }

        It 'explicit -FeedPath overrides UIPS_FEEDPATH env var' {
            $env:UIPS_FEEDPATH = 'D:\envfeed'
            Mock -ModuleName CpmfUipsCLI Invoke-CpmfUipsPack {
                param([string]$FeedPath)
                return @($FeedPath)
            }

            $result = Invoke-CpmfUipsCLI pack -ProjectJson 'C:\repos\MyBot\project.json' -FeedPath 'D:\explicit'

            $result | Should -Be 'D:\explicit'
            Remove-Item Env:\UIPS_FEEDPATH -ErrorAction SilentlyContinue
        }
    }

    Context 'install-tool subcommand' {
        It 'forwards to Install-CpmfUipsPackCommandLineTool' {
            Mock -ModuleName CpmfUipsCLI Install-CpmfUipsPackCommandLineTool {}

            Invoke-CpmfUipsCLI 'install-tool'

            Should -Invoke Install-CpmfUipsPackCommandLineTool -ModuleName CpmfUipsCLI -Times 1
        }
    }

    Context 'uninstall-tool subcommand' {
        It 'forwards to Uninstall-CpmfUipsPackCommandLineTool' {
            Mock -ModuleName CpmfUipsCLI Uninstall-CpmfUipsPackCommandLineTool {}

            Invoke-CpmfUipsCLI 'uninstall-tool'

            Should -Invoke Uninstall-CpmfUipsPackCommandLineTool -ModuleName CpmfUipsCLI -Times 1
        }
    }

    Context 'install-config subcommand' {
        It 'forwards -Force to Install-CpmfUipsPackConfig' {
            Mock -ModuleName CpmfUipsCLI Install-CpmfUipsPackConfig {}

            Invoke-CpmfUipsCLI 'install-config' -Force

            Should -Invoke Install-CpmfUipsPackConfig -ModuleName CpmfUipsCLI -Times 1 `
                -ParameterFilter { $Force -eq $true }
        }
    }

    Context 'uninstall-config subcommand' {
        It 'forwards to Uninstall-CpmfUipsPackConfig' {
            Mock -ModuleName CpmfUipsCLI Uninstall-CpmfUipsPackConfig {}

            Invoke-CpmfUipsCLI 'uninstall-config'

            Should -Invoke Uninstall-CpmfUipsPackConfig -ModuleName CpmfUipsCLI -Times 1
        }
    }

    Context 'install-hook subcommand' {
        It 'forwards -ProjectJson to Install-CpmfUipsPackGitHook' {
            Mock -ModuleName CpmfUipsCLI Install-CpmfUipsPackGitHook {}

            Invoke-CpmfUipsCLI 'install-hook' -ProjectJson 'C:\repos\MyBot\project.json'

            Should -Invoke Install-CpmfUipsPackGitHook -ModuleName CpmfUipsCLI -Times 1 `
                -ParameterFilter { $ProjectJson -eq 'C:\repos\MyBot\project.json' }
        }
    }

    Context 'diagnose subcommand' {
        It 'forwards to Get-CpmfUipsPackDiagnostics and returns output' {
            Mock -ModuleName CpmfUipsCLI Get-CpmfUipsPackDiagnostics { return 'diag output' }

            $result = Invoke-CpmfUipsCLI 'diagnose'

            Should -Invoke Get-CpmfUipsPackDiagnostics -ModuleName CpmfUipsCLI -Times 1
            $result | Should -Be 'diag output'
        }
    }

    Context 'parameter validation' {
        It 'rejects unknown subcommand' {
            { Invoke-CpmfUipsCLI 'explode' } | Should -Throw
        }
    }
}
