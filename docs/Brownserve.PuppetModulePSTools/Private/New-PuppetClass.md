---
external help file: Brownserve.PuppetModulePSToolsPrivate-help.xml
Module Name: Brownserve.PuppetModulePSToolsPrivate
online version:
schema: 2.0.0
---

# New-PuppetClass

## SYNOPSIS
Creates a new Puppet class

## SYNTAX

```
New-PuppetClass [-Name] <String> [-ModuleName] <String> [[-Description] <String[]>] [[-Content] <String[]>]
 [-Private] [<CommonParameters>]
```

## DESCRIPTION
Creates a new Puppet class

## EXAMPLES

### Example 1
```powershell
New-PuppetClass `
    -Name 'myClass' `
    -ModuleName 'myClass' `
    -Description 'This is my class!'
```

Would create a new class called `myClass`

## PARAMETERS

### -Content
Any content you want to include in the class

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
The description/summary of the class

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

### -ModuleName
The name of the module this class belongs to

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

### -Name
The name of the class

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

### -Private
Make the class private

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
