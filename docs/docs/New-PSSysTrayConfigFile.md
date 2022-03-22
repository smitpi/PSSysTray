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

### __AllParameterSets

```
New-PSSysTrayConfigFile [[-ConfigPath <DirectoryInfo>]] [-CreateShortcut] [<CommonParameters>]
```

## DESCRIPTION

Creates the config file for Start-PSSysTray


## EXAMPLES

### Example 1: EXAMPLE 1

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
Accepted values: 

Required: True (None) False (All)
Position: 0
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -CreateShortcut

Create a shortcut to launch the gui

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


### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## NOTES



## RELATED LINKS

Fill Related Links Here

