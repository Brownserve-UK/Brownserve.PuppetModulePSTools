---
external help file: Brownserve.PuppetModulePSTools-help.xml
Module Name: Brownserve.PuppetModulePSTools
online version:
schema: 2.0.0
---

# New-BrownservePuppetModule

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

```
New-BrownservePuppetModule [-ModuleName] <String> [-ModulePath] <String> [[-Description] <String[]>]
 [-ModuleType] <PuppetModuleType> [-SupportedOSFamilies] <String[]> [[-ModuleAuthor] <String>]
 [[-ForgeUsername] <String>] [[-ModuleLicense] <String>] [[-ModuleRequirements] <Hashtable[]>]
 [[-IncludeParams] <Boolean>] [-Force] [[-SupportedOSConfiguration] <BSPuppetModuleSupportedOSConfiguration>]
 [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Description
{{ Fill Description Description }}

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
{{ Fill Force Description }}

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
{{ Fill ForgeUsername Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeParams
{{ Fill IncludeParams Description }}

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ModuleAuthor
{{ Fill ModuleAuthor Description }}

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
{{ Fill ModuleLicense Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ModuleName
{{ Fill ModuleName Description }}

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
{{ Fill ModulePath Description }}

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
{{ Fill ModuleRequirements Description }}

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
{{ Fill ModuleType Description }}

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
{{ Fill SupportedOSConfiguration Description }}

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
{{ Fill SupportedOSFamilies Description }}

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
