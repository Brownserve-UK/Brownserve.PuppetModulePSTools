---
external help file: Brownserve.PuppetModulePSToolsPrivate-help.xml
Module Name: Brownserve.PuppetModulePSToolsPrivate
online version:
schema: 2.0.0
---

# New-PuppetModuleMetadata

## SYNOPSIS
Creates Puppet module metadata

## SYNTAX

```
New-PuppetModuleMetadata [-ModuleName] <String> [-ForgeUsername] <String> [-ModuleAuthor] <String>
 [-ModuleSummary] <String> [-License] <String> [-SupportedOS] <OrderedDictionary[]>
 [-Requirements] <Hashtable[]> [[-Source] <Uri>] [<CommonParameters>]
```

## DESCRIPTION
Returns Puppet module metadata in JSON format

## EXAMPLES

### Example 1
```powershell
New-PuppetModuleMetadata `
    -ModuleName 'myModule' `
    -ForgeUsername 'puppet' `
    -ModuleAuthor 'puppet' `
    -ModuleSummary 'My awesome module' `
    -License 'mit' `
    -SupportedOS $SupportedOS
```

Would return a JSON object with the desired metadata

## PARAMETERS

### -ForgeUsername
The username of the owner of this module on the Puppet forge

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -License
The license to use for this module

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ModuleAuthor
The author of the module

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ModuleName
The name of the module

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

### -ModuleSummary
The summary/description of the module

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Requirements
Any requirements the module has

```yaml
Type: Hashtable[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Source
The URI to the repository/source code for this module

```yaml
Type: Uri
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SupportedOS
A list of supported operating systems and their versions for this module

```yaml
Type: OrderedDictionary[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 5
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
