---
external help file: Brownserve.PuppetModulePSToolsPrivate-help.xml
Module Name: Brownserve.PuppetModulePSToolsPrivate
online version:
schema: 2.0.0
---

# Find-VagrantBox

## SYNOPSIS
Searches Vagrant Cloud for a given vagrant box

## SYNTAX

```
Find-VagrantBox [-BoxOwner] <String> [-OSName] <String> [[-AdditionalSearchString] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Searches Vagrant Cloud for a given vagrant box. This cmdlet is not currently used but may be implemented in the future.

## EXAMPLES

### Example 1
```powershell
PS C:\> Find-VagrantBox `
    -BoxOwner 'bento' `
    -OSName 'ubuntu-22.04'
```

Would return `https://vagrantcloud.com/bento/ubuntu-22.04`

## PARAMETERS

### -AdditionalSearchString
An optional additional string to be appended to the search

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

### -BoxOwner
The owner of the box on Vagrant Cloud.

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

### -OSName
The name of the OS to search for.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
