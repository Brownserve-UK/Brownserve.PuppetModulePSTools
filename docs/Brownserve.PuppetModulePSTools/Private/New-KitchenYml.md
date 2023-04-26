---
external help file: Brownserve.PuppetModulePSToolsPrivate-help.xml
Module Name: Brownserve.PuppetModulePSToolsPrivate
online version:
schema: 2.0.0
---

# New-KitchenYml

## SYNOPSIS
Creates an entire kitchen.yml contents

## SYNTAX

```
New-KitchenYml [-ProvisionerOptions] <Hashtable> [-SuiteOptions] <Hashtable[]> [-PlatformOptions] <Hashtable[]>
 [[-VerifierOptions] <Hashtable>] [<CommonParameters>]
```

## DESCRIPTION
This cmdlet can be used to create the contents of a kitchen.yml file.

## EXAMPLES

### Example 1
```powershell
New-KitchenYml @Params
```

Would return a block of YAML

## PARAMETERS

### -PlatformOptions
The platform options you wish to set

```yaml
Type: Hashtable[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProvisionerOptions
The provisioner options you wish to use

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SuiteOptions
The suite options you wish to use

```yaml
Type: Hashtable[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -VerifierOptions
The verifier options you wish to use

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
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
