<#
.SYNOPSIS
    Creates a new driver configuration for use in a kitchen.yml file.
.DESCRIPTION
    Creates a new driver configuration for use in a kitchen.yml file.
    Returns a hashtable with the header and section instead of YAML.
    This is done so that it can be easily merged into the kitchen.yml file or consumed by other functions.
.EXAMPLE
    New-KitchenDriver -Driver 'vagrant'
    New-KitchenDriver -Driver 'vagrant' -AdditionalParameters @{box = 'chef/centos-7.2'}
    New-KitchenDriver -Driver 'vagrant' -AdditionalParameters @{box = 'chef/centos-7.2'} -Header 'This is a header'
    New-KitchenDriver -Driver 'vagrant' -AdditionalParameters @{box = 'chef/centos-7.2'} -Header 'This is a header' -Verbose
#>


function New-KitchenDriver
{
    [CmdletBinding()]
    param
    (
        # The name of the driver to be used
        [Parameter(Mandatory = $true)]
        [KitchenDriver]
        $Driver,

        # Any additional parameters to be used (can vary by driver)
        [Parameter(Mandatory = $false)]
        [hashtable]
        $AdditionalParameters,

        # An optional header to be displayed above the driver
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string[]]
        $Header = @(
            "The below contains driver configuration",
            "This is where you specify what driver to use for the tests.",
            "This can be overridden at the platform/suite level."
        )
    )
    
    begin
    {
        
    }
    
    process
    {
        if ($null -ne $Header)
        {
            $Header = $Header | ConvertTo-BlockComment
        }
        $DriverHash = @{
            name = $Driver
        }
        if ($AdditionalParameters)
        {
            try
            {
                $DriverHash = $DriverHash + $AdditionalParameters
            }
            catch
            {
                throw "Failed to merge driver hashtable objects.`n$($_.Exception.Message)"
            }
        }
        $Return = @{
            Header = $Header
            Section = $DriverHash
        }
    }
    
    end
    {
        if ($Return)
        {
            return $Return
        }
        else
        {
            return $null
        }
    }
}