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
        $TransportOptions,

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
        $ProvisionerOptions
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
        if ($TransportOptions)
        {
            $YAMLHash[0].Add('transport', $TransportOptions)
        }
        $PlatformTemplate = $YAMLHash
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