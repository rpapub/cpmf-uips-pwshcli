@{
    # Backend and Targets are intentionally not pinned here: the module now
    # defaults to Backend = 'workflowcompiler' and Targets = @('net8'), and a
    # pin at this layer would silently override that for every pack in this repo.
    # Set Backend = 'uipcli' with Targets = @('net6') only for a net6 build.
    FeedPath       = 'C:\Users\Public\nugetfeed'
    OutputPath     = '$env:PUBLIC\UiPath.CLI.Windows\pack-output'
    UipcliPathNet6 = '$env:LOCALAPPDATA\cpmf\tools\uipcli-23.10.9351.15515\extracted\tools\uipcli.exe'
    UipcliPathNet8 = '$env:LOCALAPPDATA\cpmf\tools\uipcli-25.10.15\uipcli.exe'
    ToolBasePath   = '$env:LOCALAPPDATA\cpmf\tools'
}
