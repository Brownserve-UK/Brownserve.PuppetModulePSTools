---
external help file: Brownserve.PuppetModulePSToolsPrivate-help.xml
Module Name: Brownserve.PuppetModulePSToolsPrivate
online version:
schema: 2.0.0
---

# New-KitchenVerifier

## SYNOPSIS
Creates a test-kitchen verifier block

## SYNTAX

```
New-KitchenVerifier [[-Verifier] <String>] [-AsHashtable] [<CommonParameters>]
```

## DESCRIPTION
Creates a test-kitchen verifier block

## EXAMPLES

### Example 1
```powershell
New-KitchenVerifier `
    -Verifier 'shell'
```

Creates a test-kitchen verifier in YAML form

## PARAMETERS

### -AsHashtable
Returns a hashtable instead of YAML

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

### -Verifier
The verifier to use

```yaml
Type: String
Parameter Sets: (All)
Aliases:

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
