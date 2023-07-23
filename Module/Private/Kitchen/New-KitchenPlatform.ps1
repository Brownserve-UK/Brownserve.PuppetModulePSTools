function New-KitchenPlatform
{
    [CmdletBinding()]
    param
    (
        # The name of the operating system to use
        [Parameter(Mandatory = $true)]
        [string]
        $PlatformName,

        # The plugin to be used
        [Parameter(Mandatory = $false)]
        [KitchenDriver]
        $DriverPlugin = 'vagrant',

        # An optional transport method to be used
        [Parameter(Mandatory = $false)]
        [string]
        $TransportMethod,

        # Any additional driver config options
        [Parameter(Mandatory = $false)]
        [hashtable]
        $DriverConfigOptions,

        # Any additional driver options
        [Parameter(Mandatory = $false)]
        [hashtable]
        $DriverOptions,

        # Allows us to override any kitchen provisioner options at the platform level
        [Parameter(Mandatory = $false)]
        [hashtable]
        $ProvisionerOptions,

        # If set returns the object as a Hashtable instead of as YAML
        [Parameter(Mandatory = $false)]
        [switch]
        $AsHashtable,

        # The indentation to use for the returned YAML
        [Parameter(Mandatory = $false, DontShow)]
        [int]
        $Indentation = 2
    )
    
    begin
    {
    }
    
    process
    {
        $YAMLHash = @(
            [ordered]@{
                name          = $PlatformName
                driver_plugin = $DriverPlugin
            }
        )
        if ($DriverOptions)
        {
            $YAMLHash[0].Add('driver', $DriverOptions)
        }
        # Empty hashtables still seem to get picked up and end up in the YAML. Looks messy so only add them if they contain something
        if ($DriverConfigOptions.Count -ne 0)
        {
            $YAMLHash[0].Add('driver_config', $DriverConfigOptions)
        }
        if ($ProvisionerOptions.Count -ne 0)
        {
            $YAMLHash[0].Add('provisioner', $ProvisionerOptions)
        }
        if ($TransportMethod)
        {
            $YAMLHash[0].Add('transport', @{name = $TransportMethod })
        }
        if ($AsHashtable)
        {
            $PlatformTemplate = $YAMLHash
        }
        else
        {
            try
            {
                $PlatformTemplate = $YAMLHash | Invoke-ConvertToYaml @{ KeepArray = $true } -ErrorAction 'Stop'
            }
            catch
            {
                throw "Failed to convert object into YAML.`n$($_.Exception.Message)"
            }
            if ($Indentation -gt 0)
            {
                $ProvisionerYAMLArray = $PlatformTemplate -split "`n"
                Clear-Variable 'PlatformTemplate'
                $Line = 0
                $ProvisionerYAMLArray | ForEach-Object {
                    $Line += 1
                    if ($Line -eq $ProvisionerYAMLArray.Count)
                    {
                        $PlatformTemplate += ' ' * $Indentation + $_ + "`r"
                    }
                    else
                    {
                        $PlatformTemplate += ' ' * $Indentation + $_ + "`n`r"
                    }
                }
            }
        }
    }
    
    end
    {
        if ($PlatformTemplate)
        {
            return $PlatformTemplate
        }
        else
        {
            return $null
        }
    }
}