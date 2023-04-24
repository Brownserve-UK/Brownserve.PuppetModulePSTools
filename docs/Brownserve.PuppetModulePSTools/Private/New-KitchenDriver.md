---
external help file: Brownserve.PuppetModulePSToolsPrivate-help.xml
Module Name: Brownserve.PuppetModulePSToolsPrivate
online version:
schema: 2.0.0
---

# New-KitchenDriver

## SYNOPSIS
Creates a test-kitchen driver block.

## SYNTAX

```
New-KitchenDriver [[-Driver] <KitchenDriver>] [[-AdditionalParameters] <Hashtable>] [-AsHashtable]
 [<CommonParameters>]
```

## DESCRIPTION
Creates a test-kitchen driver block. Can be returned as YAML (Default) or as a hashtable.

## EXAMPLES

### Example 1
```powershell
New-KitchenDriver `
    -Driver $MyDriverObject
```

Would return a YAML block.

## PARAMETERS

### -AdditionalParameters
Any additional parameters to be set

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AsHashtable
Returns a hashtable instead of YAML, useful when building separate objects.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Driver
The driver to be created.

```yaml
Type: KitchenDriver
Parameter Sets: (All)
Aliases:
Accepted values: vagrant

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
