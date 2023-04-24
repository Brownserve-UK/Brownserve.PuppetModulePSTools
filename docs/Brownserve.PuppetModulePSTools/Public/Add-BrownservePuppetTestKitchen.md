---
external help file: Brownserve.PuppetModulePSTools-help.xml
Module Name: Brownserve.PuppetModulePSTools
online version:
schema: 2.0.0
---

# Add-BrownservePuppetTestKitchen

## SYNOPSIS
Adds Chef's test-kitchen to a given Puppet module

## SYNTAX

```
Add-BrownservePuppetTestKitchen [-ModuleName] <String> [-ModulePath] <String> [-ModuleType] <PuppetModuleType>
 [[-HieraContent] <String>] [-SupportedOSFamilies] <String[]>
 [[-SupportedOSConfiguration] <BSPuppetModuleSupportedOSConfiguration>] [<CommonParameters>]
```

## DESCRIPTION
This cmdlet adds a test-kitchen configuration to a given Puppet module using our standard configuration while allowing for some customisation.

## EXAMPLES

### Example 1
```powershell
PS C:\> Add-BrownservePuppetTestKitchen `
    -ModuleName 'myModule' `
    -ModulePath 'C:\myModule' `
    -ModuleType 'public' `
    -SupportedOSFamilies 'ubuntu'
```

This would add test-kitchen to the module located at `C:\myModule` and would ensure the module is tested against Ubuntu.

## PARAMETERS

### -HieraContent
Optional content to be added to the kitchen hiera

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ModuleName
The name of the module, this is used to set various bits of the kitchen configuration

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ModulePath
The path to the module where the test-kitchen configuration should be created

```yaml
Type: String
Parameter Sets: (All)
Aliases: Path, PSPath

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ModuleType
What type of module this is, public or private. Affects where acceptance test helpers are loaded from. 
[(see ModuleType.md)](../../ModuleType.md) for more information.
```yaml
Type: PuppetModuleType
Parameter Sets: (All)
Aliases:
Accepted values: private, public

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SupportedOSConfiguration
The configuration to use for supported operating systems [(see SupportedOSConfiguration.md)](../../SupportedOSConfiguration.md) for more information.

```yaml
Type: BSPuppetModuleSupportedOSConfiguration
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SupportedOSFamilies
The operating system families that this module supports and therefore should be tested against. (e.g. 'ubuntu','windows' etc)

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
### PuppetModuleType
### System.String[]
### BSPuppetModuleSupportedOSConfiguration
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
