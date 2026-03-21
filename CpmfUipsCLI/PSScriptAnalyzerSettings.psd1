@{
    Severity     = @('Error', 'Warning')
    ExcludeRules = @(
        # Write-Host is intentionally absent from this module (all streams use Write-Verbose/Write-Output).
        # PSAvoidUsingWriteHost is not excluded — any Write-Host addition should be caught.
    )
}
