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

### __AllParameterSets

```
New-PSSysTrayConfigFile [[-ConfigPath <DirectoryInfo>]] [-Confirm] [-CreateShortcut] [-WhatIf] [<CommonParameters>]
```

## DESCRIPTION

Creates the needed .csv file in the specified folder.


## EXAMPLES

### Example 1: EXAMPLE 1

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
Accepted values: 

Required: True (None) False (All)
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

### -CreateShortcut

Create a shortcut to a .ps1 file that will launch the gui.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: Named
Default value: False
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

