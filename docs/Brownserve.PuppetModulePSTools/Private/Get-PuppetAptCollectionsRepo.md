---
external help file: Brownserve.PuppetModulePSToolsPrivate-help.xml
Module Name: Brownserve.PuppetModulePSToolsPrivate
online version:
schema: 2.0.0
---

# Get-PuppetAptCollectionsRepo

## SYNOPSIS
Attempts to find the correct apt repository for a given OS.
This cmdlet is incomplete and not yet implemented.

## SYNTAX

```
Get-PuppetAptCollectionsRepo [-ReleaseName] <String> [-PuppetMajorVersion] <String>
 [[-PuppetAptCollectionURI] <String>] [<CommonParameters>]
```

## DESCRIPTION
Attempts to find the correct apt repository for a given OS.
This cmdlet is incomplete and not yet implemented.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-PuppetAptCollectionsRepo
```

N/A

## PARAMETERS

### -PuppetAptCollectionURI
The URI to where apt collections are stored.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PuppetMajorVersion
The major version of Puppet that you wish to test against.

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

### -ReleaseName
The release name of the OS.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
