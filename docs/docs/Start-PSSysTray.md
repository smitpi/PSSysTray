---
external help file: PSSysTray-help.xml
Module Name: PSSysTray
online version: 
schema: 2.0.0
---

# Start-PSSysTray

## SYNOPSIS

Gui menu app in your systray with custom executable functions

## SYNTAX

### __AllParameterSets

```
Start-PSSysTray [-ConfigFilePath] <String> [-Confirm] [-WhatIf] [<CommonParameters>]
```

## DESCRIPTION

Gui menu app in your systray with custom executable functions


## EXAMPLES

### Example 1: EXAMPLE 1

```
Start-PSSysTray -ConfigFilePath C:\temp\PSSysTrayConfig.csv
```








## PARAMETERS

### -ConfigFilePath

Path to .csv config file created from New-PSSysTrayConfigFile

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (All) False (None)
Position: 0
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -Confirm

{{ Fill Confirm Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf
Accepted values: 

Required: True (None) False (All)
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -WhatIf

{{ Fill WhatIf Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi
Accepted values: 

Required: True (None) False (All)
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```


### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## NOTES



## RELATED LINKS

Fill Related Links Here
