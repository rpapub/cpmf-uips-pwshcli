#Requires -Version 7
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0' }

BeforeAll {
    # Test the module source from the repo under development.
    $packRepoRoot = Join-Path (Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Parent) 'cpmf-uips-pwshpack'
    $packManifest = Join-Path $packRepoRoot 'CpmfUipsPack\CpmfUipsPack.psd1'
    if (Test-Path -LiteralPath $packManifest) {
        Import-Module $packManifest -Force -ErrorAction Stop
    } else {
        Import-Module CpmfUipsPack -Force -ErrorAction Stop
    }
    Import-Module (Join-Path $PSScriptRoot '../CpmfUipsCLI.psd1') -Force -ErrorAction Stop
}

Describe 'Invoke-CpmfUipsCLI — dispatch' {

    Context 'version shortcut' {
        It 'prints wrapper and dependency versions without a command' {
            (Invoke-CpmfUipsCLI -ShowVersion) | Should -BeLike 'CpmfUipsCLI * (CpmfUipsPack *)'
        }
    }

    Context 'pack subcommand' {
        It 'forwards to Invoke-CpmfUipsPack' {
            Mock -ModuleName CpmfUipsCLI Invoke-CpmfUipsPack { return @('C:\Users\Public\UiPath.CLI.Windows\pack-output\MyBot.1.0.0.nupkg') }

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

        It 'forwards -ProjectVersion to Invoke-CpmfUipsPack' {
            Mock -ModuleName CpmfUipsCLI Invoke-CpmfUipsPack {
                param([string]$ProjectVersion)
                return @($ProjectVersion)
            }

            $result = Invoke-CpmfUipsCLI pack -ProjectJson 'C:\repos\MyBot\project.json' -ProjectVersion '2.1.0'

            $result | Should -Be '2.1.0'
            Should -Invoke Invoke-CpmfUipsPack -ModuleName CpmfUipsCLI -Times 1 `
                -ParameterFilter { $ProjectVersion -eq '2.1.0' }
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

        It 'injects CPMF_UIPS_OUTPUT_PATH env var when OutputPath not bound' {
            $env:CPMF_UIPS_OUTPUT_PATH = 'C:\Users\Public\UiPath.CLI.Windows\pack-output\test-output-root'
            Mock -ModuleName CpmfUipsCLI Invoke-CpmfUipsPack {
                param([string]$OutputPath)
                return @($OutputPath)
            }

            $result = Invoke-CpmfUipsCLI pack -ProjectJson 'C:\repos\MyBot\project.json'

            $result | Should -Be 'C:\Users\Public\UiPath.CLI.Windows\pack-output\test-output-root'
            Should -Invoke Invoke-CpmfUipsPack -ModuleName CpmfUipsCLI -Times 1
            Remove-Item Env:\CPMF_UIPS_OUTPUT_PATH -ErrorAction SilentlyContinue
        }

        It 'explicit -OutputPath overrides CPMF_UIPS_OUTPUT_PATH env var' {
            $env:CPMF_UIPS_OUTPUT_PATH = 'C:\Users\Public\UiPath.CLI.Windows\pack-output\env-output'
            Mock -ModuleName CpmfUipsCLI Invoke-CpmfUipsPack {
                param([string]$OutputPath)
                return @($OutputPath)
            }

            $result = Invoke-CpmfUipsCLI pack -ProjectJson 'C:\repos\MyBot\project.json' -OutputPath 'C:\Users\Public\UiPath.CLI.Windows\pack-output\explicit-output'

            $result | Should -Be 'C:\Users\Public\UiPath.CLI.Windows\pack-output\explicit-output'
            Remove-Item Env:\CPMF_UIPS_OUTPUT_PATH -ErrorAction SilentlyContinue
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
