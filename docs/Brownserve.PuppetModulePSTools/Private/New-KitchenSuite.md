---
external help file: Brownserve.PuppetModulePSToolsPrivate-help.xml
Module Name: Brownserve.PuppetModulePSToolsPrivate
online version:
schema: 2.0.0
---

# New-KitchenSuite

## SYNOPSIS
Creates a test-kitchen suite block

## SYNTAX

```
New-KitchenSuite [-SuiteName] <String> [-SpecFileName] <String> [[-SpecFileRelativePath] <String>]
 [[-SpecExecCommand] <String>] [-Includes <Array>] [-Excludes <Array>] [-AsHashtable] [<CommonParameters>]
```

## DESCRIPTION
Creates a test-kitchen suite block, can be returned as YAML or as a hashtable

## EXAMPLES

### Example 1
```powershell
New-KitchenSuite `
    -SuiteName 'linux_tests' `
    -SpecFileName 'linux_tests.rb' `
    -SpecFileRelativePath 'spec/'
```

Would return a YAML block with the desired kitchen suite

## PARAMETERS

### -AsHashtable
Returns a hashtable instead of YAML

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

### -Excludes
Any platforms that should be excluded from running this suite

```yaml
Type: Array
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Includes
Any platforms that should be included when running this suite

```yaml
Type: Array
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SpecExecCommand
The command to execute

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

### -SpecFileName
The file name to be run

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

### -SpecFileRelativePath
The relative path to where spec tests are stored

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

### -SuiteName
The name of the suite

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
