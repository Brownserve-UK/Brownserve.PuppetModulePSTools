function New-KitchenProvisioner
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

        # The version of Puppet to be used
        [Parameter(Mandatory = $false)]
        [string]
        $PuppetAgentVersion = 'latest',

        # Any additional driver config options
        [Parameter(Mandatory = $false)]
        [YamlKey[]]
        $DriverConfigOptions,

        # Any additional driver options
        [Parameter(Mandatory = $false)]
        [YamlKey[]]
        $DriverOptions,

        # Allows us to override any kitchen provisioner options at the platform level
        [Parameter(Mandatory = $false)]
        [YamlKey[]]
        $ProvisionerOptions


    )
    
    begin
    {
    }
    
    process
    {
        $ProvisionerTemplate = @"
  - name: '$PlatformName'
    driver_plugin: $DriverPlugin`n
"@
        if ($DriverConfigOptions)
        {
            $ProvisionerTemplate += "    driver_config:`n"
            $DriverConfigOptions | Foreach-Object {
                $ProvisionerTemplate += ($_ | ConvertTo-YamlKey -Indentation 6) + "`n"
            }
        }
        if ($DriverOptions)
        {
            $ProvisionerTemplate += "    driver:`n"
            $DriverOptions | Foreach-Object {
                $ProvisionerTemplate += ($_ | ConvertTo-YamlKey -Indentation 6) + "`n"
            }
        }
        if ($ProvisionerOptions)
        {
            $ProvisionerTemplate += "    provisioner:`n"
            $ProvisionerOptions | Foreach-Object {
                $ProvisionerTemplate += ($_ | ConvertTo-YamlKey -Indentation 6) + "`n"
            }
        }
    }
    
    end
    {
        return $ProvisionerTemplate
    }
}