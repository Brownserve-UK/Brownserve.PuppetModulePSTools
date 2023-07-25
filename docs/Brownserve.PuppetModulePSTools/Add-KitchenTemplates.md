---
external help file: Brownserve.PuppetModulePSTools-help.xml
Module Name: Brownserve.PuppetModulePSTools
online version:
schema: 2.0.0
---

# Add-KitchenTemplates

## SYNOPSIS
Adds kitchen template files to a given path.

## SYNTAX

```
Add-KitchenTemplates [-Path] <String> [[-DirectoryName] <Object>] [[-ProvisionerConfigKey] <String>]
 [[-PlatformConfigKey] <String[]>] [[-SuitesConfigKey] <String[]>] [[-VerifierConfigKey] <String>]
 [[-DriverConfigKey] <String>] [-Force] [[-ProvisionerConfigFile] <String>] [[-PlatformConfigFile] <String>]
 [[-VerifierConfigFile] <String>] [[-SuitesConfigFile] <String>] [[-DriverConfigFile] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
This cmdlet will add Kitchen templates to a given path which can then be used to quickly build up kitchen test suites for modules. This cmdlet is designed to work with environment repositories that contain many modules rather than standalone modules where typically a self contained `kitchen.yml` is a better approach.  
The advantage to using templates is that you can quickly update common settings for tests in one place and still override them at a per-module level if desired.  
Due to the complex nature of Kitchen and the desire to set reusable default parameters this cmdlet makes use of [JSON config files](../ConfigFiles.md)

## EXAMPLES

### Example 1: Using defaults
```powershell
Add-KitchenTemplates -Path C:\myRepo
```

This would create the templates at `C:\myRepo\.kitchen-templates` using the default set of options found in the JSON config files.

### Example 2: Specify template directory
```powershell
Add-KitchenTemplates -Path C:\myRepo -DirectoryName 'my-kitchen-templates'
```

This would create the templates at `C:\myRepo\my-kitchen-templates` using the default set of options found in the JSON config files.

### Example 2: Supplying custom config
```powershell
Add-KitchenTemplates -Path C:\myRepo -ProvisionerConfigFile 'C:\myRepo\provisioner_config.json'
```

This would create the templates at `C:\myRepo\.kitchen-templates` using the default set of options found in the JSON config files with the exception of the provisioner which will use the config found at `C:\myRepo\provisioner_config.json`

## PARAMETERS

### -DirectoryName
The name of the directory in which to store the templates, this will be a child directory of the `-Path` parameter.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: '.kitchen-templates'
Accept pipeline input: False
Accept wildcard characters: False
```

### -DriverConfigFile
The path to the configuration file that includes the driver configuration(s)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 11
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DriverConfigKey
The from the `DriverConfigFile` JSON config file that contains the driver configuration you wish to use. If none is specified the default will be used.

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

### -Force
If passed will forcefully overwrite any templates that already exist.

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

### -Path
The path to where you want to add the Kitchen templates. A child directory will be created here as specified in the `-DirectoryName` parameter

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

### -PlatformConfigFile
The path to the configuration file that contains the platform configuration(s)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PlatformConfigKey
The from the `PlatformConfigFile` JSON config file that contains the platform configuration you wish to use. If none is specified the default will be used.

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

### -ProvisionerConfigFile
The path to the configuration file that contains the provisioner configuration(s)

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

### -ProvisionerConfigKey
The from the `ProvisionerConfigFile` JSON config file that contains the provisioner configuration you wish to use. If none is specified the default will be used.

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

### -SuitesConfigFile
The path to the configuration file that contains the suites configurations(s).

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SuitesConfigKey
The from the `SuitesConfigFile` JSON config file that contains the suite configuration you wish to use. If none is specified the default will be used.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -VerifierConfigFile
The path to the config file that contains the verifier configuration(s)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -VerifierConfigKey
The from the `VerifierConfigFile` JSON config file that contains the verifier configuration you wish to use. If none is specified the default will be used.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
