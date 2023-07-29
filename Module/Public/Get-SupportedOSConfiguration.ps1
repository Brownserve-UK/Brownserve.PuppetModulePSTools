<#
.SYNOPSIS
    This cmdlet helps to get precise operating system information for the operating systems a given Pupport module
    should support
.DESCRIPTION
    Due to how complicated
#>


function Get-SupportedOSConfiguration
{
    [CmdletBinding()]
    param
    (
        # The operating systems to create configs for
        [Parameter(Mandatory = $false)] # TODO: make this mandatory
        [string[]]
        $OperatingSystems = @('UbuntuServer'),

        # The special config file to use
        [Parameter(Mandatory = $false, DontShow)]
        [string]
        $OSMappingConfigFile = (Join-Path $Script:ModuleConfigDirectory 'os_mapping_config.json')
    )
    
    begin
    {
        $Return = @()
    }
    
    process
    {
        if (!$OSMappingConfig)
        {
            try
            {
                $OSMappingConfig = Get-Content $OSMappingConfigFile -Raw | ConvertFrom-Json -AsHashtable
            }
            catch
            {
                throw "Failed to read configuration file '$OSMappingConfigFile'.`n$($_.Exception.Message)"
            }
        }

        $Linux = @()
        $Windows = @()
        $Metadata = @{}
        $KitchenPlatforms = @()
        $KitchenSuites = @()
        $KitchenLinuxSuites = @()
        $KitchenWindowsSuites = @()
        $ThisReturn = @{
            MetadataSupportedReleases = $null
            KitchenPlatforms          = $null
            KitchenSuites             = $null
        }

        try
        {
            # First check we've actually got the operating system configs that have been requested.
            $SupportedConfigs = $OSMappingConfig.Keys
            $OperatingSystems | ForEach-Object {
                if ($_ -notin $SupportedConfigs)
                {
                    throw "Operating system '$_' does not have a matching config. Possible options are:`n$($SupportedConfigs)"
                }
            }
            $OSMappingConfig.GetEnumerator() | ForEach-Object {
                # Careful! 'switch' replaces $_ so we need to explicitly set some variables
                $OSName = $_.Key
                $OSObject = $_
                # Add the OSName to the list of suites, we'll use it later to work out the regex for platform to suite mappings
                $KitchenLinuxSuites += $OSName
                if ($OSName -in $OperatingSystems)
                {
                    $Kernel = $_.Value.Kernel
                    switch ($Kernel)
                    {
                        'linux'
                        {
                            $Linux += $OSObject
                        }
                        'Windows'
                        {
                            $Windows += $OSObject
                        }
                        Default
                        {
                            throw "Unsupported kernel '$Kernel'"
                        }
                    }
                }
                else
                {
                    Write-Verbose "OS '$OSName' not in [$($OperatingSystems -join ', ')]"
                }
            }
        }
        catch
        {
            throw "$($_.Exception.Message)"
        }

        Write-Debug "Linux count: $($Linux.Count)"
        if ($Linux.Count -gt 0)
        {
            foreach ($OS in $Linux)
            {
                # Because we previously expanded the entry before dropping it in the Linux array 
                # we shouldn't need to use GetEnumerator() again
                $OSName = $OS | Select-Object -ExpandProperty Key
                $MetadataName = $OS.Value.MetadataName
                $TestPlatforms = $OS.Value.TestPlatforms
                $MetadataReleases = @()

                Write-Debug "OSName: $OSName`nMetadataName: $MetadataName`nTestPlatforms: $($TestPlatforms | Out-String)"
                
                $TestPlatforms.GetEnumerator() | ForEach-Object {
                    $PlatformName = $_ | Select-Object -ExpandProperty Key
                    $MetadataRelease = $_.Value.MetadataRelease
                    Write-Debug "MetadataRelease: $MetadataRelease"
                    $MetadataReleases += $MetadataRelease
                    if ($_.Value.KitchenPlatformSettings)
                    {
                        $KitchenPlatformParams = $_.Value.KitchenPlatformSettings
                        $KitchenPlatformName = "$OSName-$PlatformName"
                        Write-Verbose "Creating kitchen platform for $KitchenPlatformName"
                        Write-Debug "KitchenPlatformName: $KitchenPlatformName`nKitchenPlatformParams: $($KitchenPlatformParams | Out-String)"
                        $KitchenPlatformParams.Add('PlatformName', $KitchenPlatformName)
                        try
                        {
                            $KitchenPlatforms += New-KitchenPlatform @KitchenPlatformParams -ErrorAction 'Stop'
                        }
                        catch
                        {
                            throw "Failed to create kitchen platform '$KitchenPlatformName'.`n$($_.Exception.Message)"
                        }
                    }
                }

                if ($Metadata.$MetadataName)
                {
                    $Metadata.$MetadataName += $MetadataReleases
                }
                else
                {
                    $Metadata.Add($MetadataName, $MetadataReleases)
                }
            }
        }

        Write-Debug "Windows count: $($Windows.Count)"
        # TODO: Windows equiv

        if ($KitchenLinuxSuites.Count -gt 0)
        {
            $RegexKitchenLinuxSuites = @()
            $KitchenLinuxSuites | ForEach-Object {
                $RegexKitchenLinuxSuites += "/$_/"
            }
            try
            {
                $KitchenSuites += New-KitchenSuite `
                    -SuiteName 'LinuxTests' `
                    -SpecFileName 'default_linux_spec.rb' `
                    -Includes $RegexKitchenLinuxSuites
            }
            catch
            {
                throw "Failed to create Linux suites.`n$($_.Exception.Message)"
            }
        }

        if ($KitchenWindowsSuites.Count -gt 0)
        {

        }

        # Remove any metadata dupes
        Write-Debug "Metadata pre-dedupe: $($Metadata | Out-String)"
        # Can't change values while iterating through a collection
        $MetadataClone = $Metadata.Clone()
        $MetadataClone.GetEnumerator() | ForEach-Object {
            $Key = $_.Key
            $Metadata.$Key = $Metadata.$Key | Select-Object -Unique
        }
        Write-Debug "Metadata post-dedupe: $($Metadata | Out-String)"

        Write-Debug "Kitchen platforms: $($KitchenPlatforms | Out-String)"

        Write-Debug "Kitchen suites: $($KitchenSuites | Out-String)"

        # Build up the ThisReturn object
        $ThisReturn.MetadataSupportedReleases = $Metadata
        if ($KitchenPlatforms)
        {
            $ThisReturn.KitchenPlatforms = $KitchenPlatforms
        }
        if ($KitchenSuites)
        {
            $ThisReturn.KitchenSuites = $KitchenSuites
        }
        $Return += $ThisReturn
    }
    
    end
    {
        if ($Return.Count -gt 0)
        {
            return $Return
        }
        else
        {
            return $null
        }
    }
}