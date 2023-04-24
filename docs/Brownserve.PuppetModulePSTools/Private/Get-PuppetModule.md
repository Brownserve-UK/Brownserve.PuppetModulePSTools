---
external help file: Brownserve.PuppetModulePSToolsPrivate-help.xml
Module Name: Brownserve.PuppetModulePSToolsPrivate
online version:
schema: 2.0.0
---

# Get-PuppetModule

## SYNOPSIS
Returns a list of Puppet modules from a given path

## SYNTAX

```
Get-PuppetModule [-ModulePath] <String[]> [<CommonParameters>]
```

## DESCRIPTION
This cmdlet will scan a given path for any Puppet modules, it does this by looking for a a particular directory structure
and by checking for the presence of .pp files within that structure.
Should they be found then an object is returned with the name of the module and the path to it on disk.

## EXAMPLES

### Example 1: Single module
```powershell
PS C:\> Get-PuppetModule -
    ModulePath `c:\myModule`
```

This would return the individual module located at `C:\myModule`

### Example 2: Environment modules
```powershell
PS C:\> Get-PuppetModule -
    ModulePath `c:\myEnvironment`
```

This would return all the modules located at `C:\myEnvironment`

## PARAMETERS

### -ModulePath
The path to where the modules are stored

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
