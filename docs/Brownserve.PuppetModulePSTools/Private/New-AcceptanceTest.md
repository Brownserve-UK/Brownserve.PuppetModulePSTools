---
external help file: Brownserve.PuppetModulePSToolsPrivate-help.xml
Module Name: Brownserve.PuppetModulePSToolsPrivate
online version:
schema: 2.0.0
---

# New-AcceptanceTest

## SYNOPSIS
Creates an acceptance test in our expected format.

## SYNTAX

```
New-AcceptanceTest [[-Requirements] <String[]>] [[-RelativeRequirements] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Creates an acceptance test in our expected format. Currently does not support setting the test content.

## EXAMPLES

### Example 1
```powershell
New-AcceptanceTest `
    -Requirements 'puppet' `
    -RelativeRequirements '../spec_helper.rb'
```

Would return an acceptance test in the form of a block of ruby with the given requirements.

## PARAMETERS

### -RelativeRequirements
A list of requirements that are local and relative to the acceptance test being created. (e.g. helper files)

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Requirements
Any required gems that should be loaded.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
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
