---
external help file: Brownserve.PuppetModulePSTools-help.xml
Module Name: Brownserve.PuppetModulePSTools
online version:
schema: 2.0.0
---

# Add-BrownserveModuleHiera

## SYNOPSIS
Adds module layer hiera to an existing Puppet module

## SYNTAX

```
Add-BrownserveModuleHiera [-ModulePath] <String> [[-HieraPaths] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
This cmdlet can be used to quickly add our default module layer hiera configuration to a pre-existing Puppet module.

## EXAMPLES

### Example 1
```powershell
Add-BrownserveModuleHiera -ModulePath C:\myModule
```

This would add our default module layer hiera configuration to the module located at `C:\myModule`

## PARAMETERS

### -HieraPaths
A list of hiera paths to be created

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: common.yaml
Accept pipeline input: False
Accept wildcard characters: False
```

### -ModulePath
The path to the module to add the hiera configuration to

```yaml
Type: String
Parameter Sets: (All)
Aliases: Path, PSPath

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
