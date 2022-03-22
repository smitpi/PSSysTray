---
external help file: PSSysTray-help.xml
Module Name: PSSysTray
online version:
schema: 2.0.0
---

# New-PSSysTrayConfigFile

## SYNOPSIS
Creates the config file for Start-PSSysTray

## SYNTAX

```
New-PSSysTrayConfigFile [[-ConfigPath] <DirectoryInfo>] [-CreateShortcut] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Creates the config file for Start-PSSysTray

## EXAMPLES

### EXAMPLE 1
```
New-PSSysTrayConfigFile -ConfigPath C:\temp -CreateShortcut
```

## PARAMETERS

### -ConfigPath
Path where config file will be saved.

```yaml
Type: DirectoryInfo
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CreateShortcut
Create a shortcut to a .ps1 file that will launch the gui.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
