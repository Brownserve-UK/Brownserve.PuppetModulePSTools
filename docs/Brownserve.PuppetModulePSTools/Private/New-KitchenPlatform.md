---
external help file: Brownserve.PuppetModulePSToolsPrivate-help.xml
Module Name: Brownserve.PuppetModulePSToolsPrivate
online version:
schema: 2.0.0
---

# New-KitchenPlatform

## SYNOPSIS
Creates a test-kitchen platform block

## SYNTAX

```
New-KitchenPlatform [-PlatformName] <String> [[-DriverPlugin] <KitchenDriver>] [[-TransportMethod] <String>]
 [[-DriverConfigOptions] <Hashtable>] [[-DriverOptions] <Hashtable>] [[-ProvisionerOptions] <Hashtable>]
 [-AsHashtable] [<CommonParameters>]
```

## DESCRIPTION
Creates and returns a test-kitchen platform block, can be returned as a hashtable or YAML.

## EXAMPLES

### Example 1
```powershell
New-KitchenPlatform
    -PlatformName 'test' `

```

Would return a kitchen platform in YAML form.

## PARAMETERS

### -AsHashtable
Returns a hashtable instead of a YAML string

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

### -DriverConfigOptions
Sets driver config options

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DriverOptions
Sets driver options

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DriverPlugin
The plugin to use

```yaml
Type: KitchenDriver
Parameter Sets: (All)
Aliases:
Accepted values: vagrant

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PlatformName
The name of the platform to create

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

### -ProvisionerOptions
Sets any provisioner options

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TransportMethod
The transport method to use

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
