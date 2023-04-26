---
external help file: Brownserve.PuppetModulePSTools-help.xml
Module Name: Brownserve.PuppetModulePSTools
online version:
schema: 2.0.0
---

# New-BrownservePuppetModule

## SYNOPSIS
Create a new Puppet module in our expected format

## SYNTAX

```
New-BrownservePuppetModule [-ModuleName] <String> [-ModulePath] <String> [[-Description] <String[]>]
 [-ModuleType] <PuppetModuleType> [-SupportedOSFamilies] <String[]> [[-ModuleAuthor] <String>]
 [[-ForgeUsername] <String>] [[-ModuleLicense] <String>] [[-ModuleRequirements] <Hashtable[]>]
 [[-IncludeParams] <Boolean>] [-Force] [[-SupportedOSConfiguration] <BSPuppetModuleSupportedOSConfiguration>]
 [<CommonParameters>]
```

## DESCRIPTION
This cmdlet can be used to create a new Puppet module in the standard Brownserve format.  
The output from this cmdlet can be piped into some other cmdlets for quickly creating tests and hiera.

## EXAMPLES

### Example 1
```powershell
New-BrownservePuppetModule `
    -ModuleName 'myModule' `
    -ModulePath 'C:\' `
```

This would create a new module at `C:\myModule`

## PARAMETERS

### -Description
An optional summary/description of the module.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Forces creation even if the module already exists

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

### -ForgeUsername
The name of the user who will own this module on Puppet forge (only used when creating public modules).

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: brownserve
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeParams
If set to true will include a private params class

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: True
Accept pipeline input: False
Accept wildcard characters: False
```

### -ModuleAuthor
The name of the person who wrote this module (only used when creating public modules)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ModuleLicense
The license to use for this module (only used when creating a public module)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: mit
Accept pipeline input: False
Accept wildcard characters: False
```

### -ModuleName
The name of the module to be created

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ModulePath
The path to where the module should be created

```yaml
Type: String
Parameter Sets: (All)
Aliases: Path, PSPath

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ModuleRequirements
An optional list of requirements this module needs to work

```yaml
Type: Hashtable[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ModuleType
Whether the module is public (i.e. public repository or uploaded to the forge) or private (i.e. private repo, local to the Puppet server or an environment)

```yaml
Type: PuppetModuleType
Parameter Sets: (All)
Aliases:
Accepted values: private, public

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SupportedOSConfiguration
The configuration to use for supported operating systems [(see SupportedOSConfiguration.md)](../../SupportedOSConfiguration.md)

```yaml
Type: BSPuppetModuleSupportedOSConfiguration
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SupportedOSFamilies
The family of operating systems that should be supported (e.g. 'ubuntu','windows' etc).
These must be present in the `-SupportedOSConfiguration` parameter

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
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
