---
external help file: PSSysTray-help.xml
Module Name: PSSysTray
online version:
schema: 2.0.0
---

# Start-PSSysTray

## SYNOPSIS
This function reads csv config file and creates the gui in your system tray.

## SYNTAX

```
Start-PSSysTray [-ConfigFilePath] <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
This function reads csv config file and creates the gui in your system tray.

## EXAMPLES

### EXAMPLE 1
```
Start-PSSysTray -ConfigFilePath C:\temp\PSSysTrayConfig.csv
```

## PARAMETERS

### -ConfigFilePath
Path to the config file created by New-PSSysTrayConfigFile

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
