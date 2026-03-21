---
external help file: CpmfUipsCLI-help.xml
Module Name: CpmfUipsCLI
online version:
schema: 2.0.0
---

# Invoke-CpmfUipsCLI

## SYNOPSIS
Single entry point for the CpmfUipsCLI wrapper.
Dispatches to CpmfUipsPack public functions.

## SYNTAX

```
Invoke-CpmfUipsCLI [-Command] <String> [-ProjectJson <String>] [-FeedPath <String>] [-Targets <String[]>]
 [-NoBump] [-UseWorktree] [-SkipInstall] [-MultiTfm] [-ConfigFile <String>] [-CliVersion <String>]
 [-CliVersionNet6 <String>] [-CliVersionNet8 <String>] [-ToolBase <String>] [-Force]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Invoke-CpmfUipsCLI routes a subcommand string to the corresponding CpmfUipsPack function.
All remaining parameters are forwarded via splatting.
UIPS_* environment variables are
applied as defaults before forwarding, following the same four-layer hierarchy as CpmfUipsPack.

Subcommands:
  pack              Invoke-CpmfUipsPack
  install-tool      Install-CpmfUipsPackCommandLineTool
  uninstall-tool    Uninstall-CpmfUipsPackCommandLineTool
  install-config    Install-CpmfUipsPackConfig
  uninstall-config  Uninstall-CpmfUipsPackConfig
  install-hook      Install-CpmfUipsPackGitHook
  diagnose          Get-CpmfUipsPackDiagnostics

## EXAMPLES

### EXAMPLE 1
```
Invoke-CpmfUipsCLI pack -ProjectJson C:\repos\MyBot\project.json
```

### EXAMPLE 2
```
Invoke-CpmfUipsCLI pack -ProjectJson C:\repos\MyBot\project.json -Targets net6,net8 -WhatIf
```

### EXAMPLE 3
```
Invoke-CpmfUipsCLI install-tool
```

### EXAMPLE 4
```
Invoke-CpmfUipsCLI diagnose
```

## PARAMETERS

### -Command
The subcommand to execute.
Tab-completable.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProjectJson
Path to the UiPath project.json.
Forwarded to pack and install-hook subcommands.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FeedPath
NuGet feed path.
Forwarded to pack.
Defaults to UIPS_FEEDPATH env var if set.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Targets
Target TFMs to build.
E.g.
@('net6') or @('net6','net8').
Forwarded to pack.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoBump
Skip the version bump.
Forwarded to pack.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseWorktree
Pack from a clean git worktree.
Forwarded to pack.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkipInstall
Skip uipcli auto-install.
Forwarded to pack.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -MultiTfm
Merge net6/net8 TFM outputs into a single nupkg.
Forwarded to pack.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigFile
Per-project config file (.psd1).
Forwarded to pack.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CliVersion
uipcli version (deprecated alias).
Forwarded to pack.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CliVersionNet6
uipcli version for the net6 target.
Forwarded to pack and install-tool.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CliVersionNet8
uipcli version for the net8 target.
Forwarded to pack and install-tool.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ToolBase
Base directory for managed tool installs.
Forwarded to pack, install-tool, uninstall-tool.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Overwrite existing config.
Forwarded to install-config.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### [string[]] for the pack subcommand (paths to staged .nupkg files).
### [string]   for the diagnose subcommand (pseudonymized environment report).
### No output for lifecycle subcommands.
## NOTES

## RELATED LINKS
