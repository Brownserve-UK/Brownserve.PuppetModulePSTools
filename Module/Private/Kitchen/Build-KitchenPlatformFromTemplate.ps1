<#
.SYNOPSIS
    Creates a new kitchen platform yaml block from a template
.DESCRIPTION
    Creates a kitchen platform block from a given template file so it can be injected into a larger kitchen manifest
.NOTES
    Templates are stored in the .build/Modules/PuppetTools/Private/templates/kitchen/platforms directory by default
    TODO: Remove individual params leaving just -Platforms, they will never get used! (Unless this cmdlet become public?)
.EXAMPLE
    New-KitchenPlatformFromTemplate -Platform 'ubuntu_server' -OSReleases 'stable'
    
    Would create a new kitchen platform block for Ubuntu-20.04
#>
function Build-KitchenPlatformFromTemplate
{
    [CmdletBinding(DefaultParameterSetName = 'default')]
    param
    (
        # The Operating System that this platform should support
        [Parameter(Mandatory = $true, ParameterSetName = 'default')]
        [TestOperatingSystems]
        $OperatingSystem,

        # The releases(s) for the Operating System(s)
        [Parameter(Mandatory = $true, ParameterSetName = 'default')]
        [OSRelease[]]
        $OSReleases,

        # The name for this platform, if left blank will be auto-generated from the OperatingSystem parameter
        # When defining multiple OS releases each release will be appended to the PlatformName
        [Parameter(Mandatory = $false, ParameterSetName = 'default')]
        [string]
        $PlatformName = $OperatingSystem,

        # The version of Puppet agent to be used with this platform (defaults to latest)
        [Parameter(Mandatory = $false, ParameterSetName = 'default')]
        [PuppetAgentVersion]
        $PuppetVersion = 'latest',

        # The major version(s) of Puppet this platform should test against
        [Parameter(Mandatory = $false)]
        [int[]]
        $PuppetMajorVersion = $script:DefaultPuppetMajorVersion,

        # The directory the template files live in
        [Parameter(Mandatory = $false)]
        [string]
        $TemplateDirectory = (Join-Path $Script:PuppetTemplateDirectory 'kitchen' 'platforms'),

        # The template file to use for creating the platform, these should live in the template directory specified above
        [Parameter(Mandatory = $false)]
        [string]
        $TemplateFile = 'default.yml',

        # Special hidden parameter for when we know what we're doing.
        # We don't support piping for 2 reasons; it applies param validation in the process block which is too late when
        # we have malformed data and secondly it performs the Windows Puppet agent check for each object in the pipe :(
        [Parameter(Mandatory = $true, ValueFromPipeline = $false, ParameterSetName = 'platforms', DontShow)]
        [ValidateNotNullOrEmpty()]
        [KitchenPlatform[]]
        $Platforms
    )
    
    begin
    {
        $Return = @()
        # Get our list of supported platforms and their boxes
        try
        {
            Get-Item $TemplateDirectory -ErrorAction 'Stop' | Out-Null
        }
        catch
        {
            throw "Failed to find the template directory.`n$($_.Exception.Message)"
        }
        try
        {
            $PlatformTemplate = Get-Content (Join-Path $TemplateDirectory $TemplateFile) -ErrorAction 'Stop'
        }
        catch
        {
            throw "Unable to load platform template file.`n$($_.Exception.Message)"
        }
        try
        {
            $BoxURLS = Get-Content (Join-Path $TemplateDirectory 'boxes.json') -Raw -ErrorAction 'Stop' | ConvertFrom-Json -AsHashtable
        }
        catch
        {
            throw "Failed to import box list.`n$($_.Exception.Message)"
        }
    }
    
    process
    {   
        # If we don't have our special pipeline input then we'll create it from the named parameters
        if (!$Platforms)
        {
            $Platforms = @{
                PlatformName       = $PlatformName
                OperatingSystem    = $OperatingSystem
                OSRelease          = $OSReleases
                PuppetAgentVersion = $PuppetVersion
                PuppetMajorVersion = $PuppetMajorVersion
            }
        }
        Write-Debug "Platforms:$($Platforms | Out-String)"
        <# 
            See Get-LatestWindowsPuppetAgentVersion as for why this is needed.
            As this involves doing a web request we try to only do this once when we are defining multiple platforms
            hence why this is performed at this stage.
        #>
        $WindowsPACheck = $Platforms | 
            Where-Object { ($_.OperatingSystem -like 'windows*') -and ($_.PuppetAgentVersion -eq 'latest') }
        if ($WindowsPACheck)
        {
            Write-Debug 'Performing lookup for latest Windows Puppet Agent version'
            try
            {
                $Versions = $WindowsPACheck | Select-Object -ExpandProperty PuppetMajorVersion -Unique
                if (!$Versions)
                {
                    Write-Error "Unable to determine platform puppet versions"
                }
                $LatestWindowsPuppet = Get-LatestWindowsPuppetAgentVersion `
                    -MajorVersion $Versions `
                    -ErrorAction 'Stop'
            }
            catch
            {
                throw "Failed to get latest version of Puppet for Windows.`n$($_.Exception.Message)"
            }
        }
        # Use a proper for-each to avoid any logic issues with continues/breaks
        foreach ($Entry in $Platforms)
        {
            if ($Entry.OSRelease -gt 1)
            {
                $AppendRelease = $true
            }
            foreach ($Release in $Entry.OSRelease)
            {
                foreach ($MajorVersion in $Entry.PuppetMajorVersion)
                {
                    $Template = $PlatformTemplate
                    $PlatformName = $Entry.PlatformName
                    if ($AppendRelease -eq $true)
                    {
                        $PlatformName = $PlatformName + "_$Release"
                    }
                    # Remove any whitespace from the platform name and cast it to lowercase
                    $PlatformName = ($PlatformName -replace '\s', '_').ToLower()
                    # This comment will be used to automagically update vagrant boxes when changing major versions
                    $OSVersionComment = "$($Entry.OperatingSystem)-$($Entry.OSRelease)"
                    $PAComment = "Sometimes it's handy to lock the Puppet version to a specific release if we need to avoid a particularly buggy release."
                    if ($Entry.OperatingSystem -like '*windows*')
                    {
                        $VMHostname = 'windows-tests'
                    }
                    else
                    {
                        $VMHostname = 'linux-tests'
                    }
                    # Ensure the Puppet Agent version is hardcoded on Windows until kitchen-puppet or Puppet handles things better
                    if (($Entry.OperatingSystem -like '*windows*') -and ($Entry.PuppetAgentVersion -eq 'latest'))
                    {
                        $PAComment = " On Windows 'latest' defaults to an ancient version of Puppet (due to the way Puppetlabs structure their downloads and how kitchen-puppet handles latest)`n      # so we unfortunately need to explicitly set this "
                        $PlatformPuppetVersion = $LatestWindowsPuppet | Where-Object {$_.MajorVersion -eq $MajorVersion}
                        if (!$PlatformPuppetVersion)
                        {
                            throw "Got a null Puppet Agent version."
                        }
                    }
                    else
                    {
                        $PlatformPuppetVersion = $Entry.PuppetAgentVersion.ToString()
                    }
                    if ($BoxURLS)
                    {
                        $BoxPlatform = $BoxURLS.GetEnumerator() |
                            Where-Object { $_.Key.ToLower() -eq $Entry.OperatingSystem.ToLower() } | 
                                Select-Object -ExpandProperty Value
                        if (!$BoxPlatform)
                        {
                            Write-Error "Cannot find any platforms that match $($Entry.OperatingSystem.ToLower()) in boxes.json"
                            # If we're not stopping on errors then we'll need to skip over this one
                            Continue
                        }
                        $BoxURL = $BoxPlatform.GetEnumerator() | 
                            Where-Object { $_.Key.ToLower() -eq $Release.ToLower() } | 
                                Select-Object -ExpandProperty Value
                    }
                    ## Build up the template
                    # Set the name of the platform
                    $Template = $Template -replace '<PLATFORM_NAME>', $PlatformName
                    # Set the URL of the box
                    $Template = $Template -replace '<BOX_URL>', $BoxURL
                    # Set the comment for this box so we can easily replace it.
                    $Template = $Template -replace '<OS_VERSION_TAG>', $OSVersionComment
                    # Set the VM hostname (it's commented out in the config, but handy to have in case we run into the hostname too long bug)
                    $Template = $Template -replace '<VM_HOSTNAME>', $VMHostname
                    # Set the comment for the platform
                    $Template = $Template -replace '<PUPPET_AGENT_VERSION_COMMENT>', $PAComment
                    # Set the version of Puppet for this platform
                    $Template = $Template -replace '<PUPPET_AGENT_VERSION>', $PlatformPuppetVersion

                    # Add the fully built template to the return object
                    $Return += $Template
                }
            }
        }
    }
    
    end
    {
        if ($Return -ne @())
        {
            Write-Debug "Build-KitchenPlatformFromTemplate returns:`n$($Return | Out-String)"
            Return ($Return | Out-String) # Make sure we return a string so it can be ingested easily elsewhere.
        }
        else
        {
            Return $null
        }
    }
}