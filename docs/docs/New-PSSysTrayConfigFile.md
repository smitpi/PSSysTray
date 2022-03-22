---
external help file: PSSysTray-help.xml
Module Name: PSSysTray
online version:
schema: 2.0.0
---

# New-PSSysTrayConfigFile

## SYNOPSIS
Creates the needed .csv file in the specified folder.

## SYNTAX

```
New-PSSysTrayConfigFile [[-ConfigPath] <DirectoryInfo>] [-CreateShortcut] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Creates the needed .csv file in the specified folder.

## EXAMPLES

### EXAMPLE 1
```
New-PSSysTrayConfigFile -ConfigPath C:\temp -CreateShortcut
```

## PARAMETERS

### -ConfigPath
Path to where the config file will be saved.

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
Runs the script without changes.

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
Will ask before changes are made.

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
