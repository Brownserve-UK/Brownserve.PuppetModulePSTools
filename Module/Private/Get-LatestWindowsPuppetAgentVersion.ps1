<#
.SYNOPSIS
    Attempts to find the latest available version of Puppet agent for Windows by querying the Puppet agent download URL
.DESCRIPTION
    On Windows based platforms using 'latest' for the Puppet Agent version presently results in a Puppet Agent 5 package
    from 2018 being installed, though in the future 'latest' may well result in the latest dev version being installed.
    This is due to a combination of how Puppet now store their Windows downloads and the logic in kitchen-puppet
    that determines what version of Puppet to be installed.
    So we need to manually work out what 'latest' is at the time of this cmdlet being called and then set that
    explicitly in the platform config.
    This does mean that we'll need to update this on occasion though.
.EXAMPLE
    Get-LatestWindowsPuppetAgentVersion -MajorVersion 6
    
    This will get the latest Windows Puppet agent for Puppet6 using the default settings
#>


function Get-LatestWindowsPuppetAgentVersion
{
    [CmdletBinding()]
    param
    (
        # The URL to where Puppet stores Windows versions
        [Parameter(Mandatory = $false, Position = 0)]
        [string]
        $URI = 'http://downloads.puppetlabs.com/windows/',

        # The major version of Puppet to find the latest versions for
        [Parameter(Mandatory = $true, Position = 1)]
        [int]
        $MajorVersion,

        # The architecture to get
        [Parameter(Mandatory = $false)]
        [ValidateSet('x64', 'x86')]
        [string]
        $Arch = 'x64'
    )
    
    begin
    {

    }
    
    process
    {
        <# 
            Attempt to get the latest version of Puppet for Windows by querying the download URL for the major version we are working with for all available versions
            Then we grep that result for a basic regex version number match and then cast that to a PowerShell version object so we can easily sort it and find the latest version.
        #>
        try
        {
            <# 
                Sometimes we can end up with this being an empty value due to weird PowerShell reasons.
                We can't validate on the param because it's an int, so we do so here.
                We also check that it's not below 3 as those binaries don't exist in repository.
            #>
            if ((!$MajorVersion) -or ($MajorVersion -lt 5))
            {
                Write-Error "MajorVersion is not set to a valid value. ($MajorVersion)"
            }
            $MajorURI = $URI + "puppet$MajorVersion"
            $PuppetAgentVersions = (Invoke-WebRequest $MajorURI -ErrorAction 'Stop').Links | 
                Where-Object { $_.href -like "puppet-agent-*-$Arch.msi" } | 
                    Select-Object -ExpandProperty href | ForEach-Object {
                        if ($_.ToLower() -match '^puppet-agent-([\d\.]*)')
                        {
                            [version]$Matches[1]
                        }
                        else
                        {
                            Write-Debug "'$_' does not appear to match a version number"
                        }
                    }
        }
        catch
        {
            throw "Failed to query Puppet agent downloads.$($_.Exception.Message)"
        }
        if (!$PuppetAgentVersions)
        {
            throw 'Failed to find any matching Puppet versions.'
        }
        # Finally sort the object, select the last entry and convert it to a string
        $LatestVersion = ($PuppetAgentVersions | Sort-Object | Select-Object -Last 1).ToString()
    }
    
    end
    {
        if ($LatestVersion)
        {
            return $LatestVersion
        }
        else
        {
            return $null
        }
    }
}