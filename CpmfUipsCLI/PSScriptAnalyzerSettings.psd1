@{
    Severity     = @('Error', 'Warning')
    ExcludeRules = @(
        'PSUseBOMForUnicodeEncodedFile'  # files are UTF-8 without BOM throughout
        'PSAvoidUsingWriteHost'          # CLI wrapper intentionally uses Write-Host for always-visible user feedback
        'PSShouldProcess'               # Invoke-CpmfUipsCLI delegates WhatIf/Confirm to subcommands via @forwardParams
    )
}
