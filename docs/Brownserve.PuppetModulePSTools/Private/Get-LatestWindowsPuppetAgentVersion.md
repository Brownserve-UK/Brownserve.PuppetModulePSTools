---
external help file: Brownserve.PuppetModulePSToolsPrivate-help.xml
Module Name: Brownserve.PuppetModulePSToolsPrivate
online version:
schema: 2.0.0
---

# Get-LatestWindowsPuppetAgentVersion

## SYNOPSIS
Attempts to ascertain the latest version of Puppet available for a given major version of Puppet

## SYNTAX

```
Get-LatestWindowsPuppetAgentVersion [[-URI] <String>] [-MajorVersion] <Int32[]> [-Arch <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Attempts to ascertain the latest version of Puppet available for a given major version of Puppet. This cmdlet is not currently used but may be implemented in the future.

## EXAMPLES

### Example 1
```powershell
Get-LatestWindowsPuppetAgentVersion -MajorVersion 6
```

Would return the latest available version of Puppet Agent for Windows for Puppet v6.

## PARAMETERS

### -Arch
The architecture to get

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: x64, x86

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MajorVersion
The major version of Puppet you wish to get the latest version for

```yaml
Type: Int32[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -URI
The URI to where Puppet MSI installers are stored

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: http://downloads.puppetlabs.com/windows/
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
