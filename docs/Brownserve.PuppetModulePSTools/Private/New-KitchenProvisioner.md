---
external help file: Brownserve.PuppetModulePSToolsPrivate-help.xml
Module Name: Brownserve.PuppetModulePSToolsPrivate
online version:
schema: 2.0.0
---

# New-KitchenProvisioner

## SYNOPSIS
Creates a new provisioner block for test-kitchen

## SYNTAX

```
New-KitchenProvisioner [-ManifestName] <String> [[-ProvisionerName] <String>] [[-ManifestPath] <String>]
 [[-ExternalModulesPath] <String>] [[-HieraDataPath] <String>] [[-HieraConfigPath] <String>]
 [[-EnableHieraDeepMerge] <Boolean>] [[-CustomFacts] <Hashtable>] [[-IgnoredPathsFromRoot] <String[]>]
 [[-RequireChefForBusser] <Boolean>] [[-ResolveWithLibrarianPuppet] <Boolean>] [[-RequirePuppetRepo] <Boolean>]
 [[-VerifyHostKey] <Boolean>] [[-MaxRetries] <Int32>] [[-WaitForRetry] <Int32>] [[-RetryOnExitCode] <Int32[]>]
 [[-DetailedExitCodes] <Boolean>] [[-PuppetVerbose] <Boolean>] [[-PuppetDebug] <Boolean>]
 [[-PuppetShowDiff] <Boolean>] [[-PuppetNoOp] <Boolean>] [-AsHashtable] [<CommonParameters>]
```

## DESCRIPTION
Creates a new provisioner block for test-kitchen as either a hashtable or YAML

## EXAMPLES

### Example 1
```powershell
New-KitchenProvisioner `
    -ManifestName 'myModule_tests.pp
```

Would return a YAML test-kitchen provisioner

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

### -CustomFacts
Any custom facts you wish to use

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DetailedExitCodes
Enable detailed exit codes

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 16
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EnableHieraDeepMerge
Enable deep hiera merges

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExternalModulesPath
The path to where external modules are loaded

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

### -HieraConfigPath
The path to where test hiera configuration will be stored

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

### -HieraDataPath
The path to where test hiera will be stored

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IgnoredPathsFromRoot
Paths to be ignored

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ManifestName
The name of the test Puppet manifest to be run

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

### -ManifestPath
The path to where test manifests are stored

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

### -MaxRetries
The maximum number of retries to use

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 13
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProvisionerName
The name of the provisioner to run

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PuppetDebug
Enable Puppet debug mode

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 18
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PuppetNoOp
Perform a no-op

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 20
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PuppetShowDiff
Enable Puppet diffs

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 19
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PuppetVerbose
Enable Puppet verbose mode

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 17
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RequireChefForBusser
Require chef for busser

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

### -RequirePuppetRepo
Require the Puppet repo

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 11
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ResolveWithLibrarianPuppet
Use librarian Puppet

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RetryOnExitCode
The exit codes to retry Puppet runs on

```yaml
Type: Int32[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 15
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -VerifyHostKey
Verify host key

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 12
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WaitForRetry
How long to wait between retries

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 14
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
