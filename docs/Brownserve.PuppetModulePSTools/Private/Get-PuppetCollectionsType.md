---
external help file: Brownserve.PuppetModulePSToolsPrivate-help.xml
Module Name: Brownserve.PuppetModulePSToolsPrivate
online version:
schema: 2.0.0
---

# Get-PuppetCollectionsType

## SYNOPSIS
Determines the collection repo type for a given URI.

## SYNTAX

```
Get-PuppetCollectionsType [-CollectionsRepoURI] <String> [<CommonParameters>]
```

## DESCRIPTION
This cmdlet is used to work out what type of collection repo a given URI is (currently can be either `yum` or `apt`). This is used to ensure we can set the correct option in kitchen tests.

## EXAMPLES

### Example 1
```powershell
Get-PuppetCollectionsType `
    -CollectionsRepoURI 'https://apt.puppet.com/puppet6-release-jammy.deb'
```

Would return `PuppetAptCollectionsRepo`

## PARAMETERS

### -CollectionsRepoURI
The URI to the collection repo you want to check.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
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
