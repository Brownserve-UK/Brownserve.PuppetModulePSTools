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
        [hashtable]
        $TransportOptions,

        # Any additional driver config options
        [Parameter(Mandatory = $false)]
        [hashtable]
        $DriverConfigOptions = @{},

        # Any additional driver options
        [Parameter(Mandatory = $false)]
        [hashtable]
        $DriverOptions = @{},

        # Allows us to override any kitchen provisioner options at the platform level
        [Parameter(Mandatory = $false)]
        [hashtable]
        $ProvisionerOptions,

        # Special parameter for looking up OS info
        [Parameter(Mandatory = $false)]
        [OSInfoObject]
        $OSInfoObject,

        # Our special OS info config file that helps map various OS configurations together in one place
        [Parameter(Mandatory = $false)]
        [string]
        $OSInfoConfigFile
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
        if ($OSInfoObject)
        {
            if (!$OSInfoConfigFile)
            {
                throw "OSInfoObject specified but no OSInfoConfigFile was passed."
            }
            try
            {
                $OSInfo = Get-Content $OSInfoConfigFile -Raw | ConvertFrom-Json -AsHashtable
            }
            catch
            {
                throw "Failed to read OSInfo config.`n$($_.Exception.Message)"
            }
            $OSFamily = $OSInfoObject.OSFamily
            $TestPlatform = $OSInfoObject.TestPlatform
            Write-Debug "OSFamily: $OSFamily"
            Write-Debug "TestPlatform: $TestPlatform"
            $OSInfo = $OSInfo.$OSFamily.TestPlatforms.$TestPlatform
            if (!$OSInfo)
            {
                throw 'OSInfo is empty.'
            }
        }
        if ($DriverPlugin -eq 'vagrant')
        {
            if ((!$DriverOptions.box_url) -and (!$DriverOptions.box))
            {
                if ($OSInfo.vagrant_box)
                {
                    if ($OSInfo.vagrant_box.url)
                    {
                        $DriverOptions.Add('box_url',$OSInfo.vagrant_box.url)
                    }
                    if ($OSInfo.vagrant_box.name)
                    {
                        $DriverOptions.Add('box',$OSInfo.vagrant_box.name)
                    }
                    
                }
                # If both of these are still blank, throw
                if ((!$DriverOptions.box_url) -and (!$DriverOptions.box))
                {
                    throw "Using vagrant but neither 'box' nor 'box_url' have been provided"
                }
            }
        }
        if ($DriverPlugin -eq 'docker')
        {
            if ((!$DriverConfigOptions.image) -or (!$DriverConfigOptions.platform))
            {
                if ($OSInfo.docker_image)
                {
                    if ($OSInfo.docker_image.image)
                    {
                        $DriverConfigOptions.Add('image',$OSInfo.docker_image.image)
                    }
                    if ($OSInfo.docker_image.platform)
                    {
                        $DriverConfigOptions.add('platform',$OSInfo.docker_image.platform)
                    }
                }
                if ((!$DriverConfigOptions.image) -or (!$DriverConfigOptions.platform))
                {
                    throw "Using docker but one of 'image' or 'platform' has not been provided"
                }
            }
        }
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