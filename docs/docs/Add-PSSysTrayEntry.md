---
external help file: PSSysTray-help.xml
Module Name: PSSysTray
online version:
schema: 2.0.0
---

# Add-PSSysTrayEntry

## SYNOPSIS
Add an entry in the csv config file.

## SYNTAX

```
Add-PSSysTrayEntry [-PSSysTrayConfigFile] <FileInfo> [-Execute] [<CommonParameters>]
```

## DESCRIPTION
Add an entry in the csv config file.

## EXAMPLES

### EXAMPLE 1
```
An Add-PSSysTrayEntry -PSSysTrayConfigFile C:\temp\PSSysTrayConfig.csv
```

## PARAMETERS

### -PSSysTrayConfigFile
Path to the config file created by New-PSSysTrayConfigFile

```yaml
Type: FileInfo
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Execute
Start the tool after adding the configuration.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
