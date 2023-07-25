---
external help file: Brownserve.PuppetModulePSTools-help.xml
Module Name: Brownserve.PuppetModulePSTools
online version:
schema: 2.0.0
---

# Add-BrownservePuppetTestKitchen

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

```
Add-BrownservePuppetTestKitchen [-ModuleName] <String> [-ModulePath] <String> [-ModuleType] <PuppetModuleType>
 [[-HieraContent] <String>] [-SupportedOSFamilies] <String[]>
 [[-SupportedOSConfiguration] <BSPuppetModuleSupportedOSConfiguration>] [<CommonParameters>]
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

### -HieraContent
{{ Fill HieraContent Description }}

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

### -ModuleName
{{ Fill ModuleName Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
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
Accept pipeline input: True (ByPropertyName)
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
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SupportedOSConfiguration
{{ Fill SupportedOSConfiguration Description }}

```yaml
Type: BSPuppetModuleSupportedOSConfiguration
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: True (ByPropertyName)
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
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
### PuppetModuleType
### System.String[]
### BSPuppetModuleSupportedOSConfiguration
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
