---
external help file: Brownserve.PuppetModulePSToolsPrivate-help.xml
Module Name: Brownserve.PuppetModulePSToolsPrivate
online version:
schema: 2.0.0
---

# New-ModuleHiera

## SYNOPSIS
Creates module layer hiera

## SYNTAX

```
New-ModuleHiera [-HieraHierarchy] <HieraHierarchy[]> [[-DataDirectory] <String>] [[-DataHashType] <String>]
 [[-HieraVersion] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
Creates module layer hiera

## EXAMPLES

### Example 1
```powershell
New-ModuleHiera `
    -HieraHierarchy @{
        Name = 'module layer hiera'
        Paths = @('common.yaml','linux.yaml')
    }
```

Would return a hiera configuration with the desired options.

## PARAMETERS

### -DataDirectory
The directory to use for storing the hiera (local to the module)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: data
Accept pipeline input: False
Accept wildcard characters: False
```

### -DataHashType
The hash to be used

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: yaml_data
Accept pipeline input: False
Accept wildcard characters: False
```

### -HieraHierarchy
The paths to be used

```yaml
Type: HieraHierarchy[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -HieraVersion
{{ Fill HieraVersion Description }}

```yaml
Type: Int32
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
