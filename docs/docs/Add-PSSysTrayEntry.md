---
external help file: PSSysTray-help.xml
Module Name: PSSysTray
online version:
schema: 2.0.0
---

# Add-PSSysTrayEntry

## SYNOPSIS
Add an entry in the csv file

## SYNTAX

```
Add-PSSysTrayEntry [-PSSysTrayConfigFilePath] <String> [<CommonParameters>]
```

## DESCRIPTION
Add an entry in the csv file

## EXAMPLES

### EXAMPLE 1
```
Add-PSSysTrayEntry -PSSysTrayConfigFilePath C:\temp\PSSysTrayConfig.csv
```

## PARAMETERS

### -PSSysTrayConfigFilePath
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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
