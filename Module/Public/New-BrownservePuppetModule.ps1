function New-BrownservePuppetModule
{
    [CmdletBinding()]
    param
    (
        # The name of the module
        [Parameter(Mandatory = $true)]
        [string]
        $ModuleName,

        # The path to where the module should be created
        [Parameter(Mandatory = $true)]
        [string]
        $Path,

        # An optional description for this module
        [Parameter(Mandatory = $false)]
        [string[]]
        $Description,

        # The type of module to be created, public (forge) or private (environment)
        [Parameter(Mandatory = $true)]
        [PuppetModuleType]
        $ModuleType,

        # The supported operating systems
        [Parameter(Mandatory = $true)]
        [string[]]
        $SupportedOS,

        # The author of the module
        [Parameter(Mandatory = $false)]
        [string]
        $ModuleAuthor = [Environment]::UserName,

        # The account that uploads this module to the forge
        [Parameter(Mandatory = $false)]
        [string]
        $ForgeUsername = 'brownserve',

        # The license to use for this module
        [Parameter(Mandatory = $false)]
        [string]
        $ModuleLicense = 'mit',

        # The requirements for this module
        [Parameter(Mandatory = $false)]
        [hashtable[]]
        $ModuleRequirements,

        # Whether to include a params class
        [Parameter(Mandatory = $false)]
        [bool]
        $IncludeParams = $true,

        # Forces the creation of the module even if it exists
        [Parameter(Mandatory = $false)]
        [switch]
        $Force,

        # The configuration file to use
        [Parameter(Mandatory = $false, DontShow)]
        [string]
        $ConfigurationFile = (Join-Path $PSScriptRoot 'configuration.jsonc')
    )
    
    begin
    {
        if (!$Configuration)
        {
            try
            {
                $Configuration = Get-Content $ConfigurationFile | ConvertFrom-Json -AsHashtable
            }
            catch
            {
                throw "Failed to load configuration.`n$($_.Exception.Message)"
            }
        }
        if (!$ModuleRequirements)
        {
            # Forge modules _must_ have the upper version number set, if it's not then it'll be added automatically and it may impact the modules score.
            $PuppetUpperVersion = 8
            if ($script:DefaultPuppetMajorVersion -eq $PuppetUpperVersion)
            {
                throw 'Cannot automatically set Puppet version requirements'
            }
            $ModuleRequirements = @{
                name                = 'puppet'
                version_requirement = ">= $script:DefaultPuppetMajorVersion.0.0 < 8.0.0"
            }
        }
    }
    
    process
    {
        $OSVersions = @{}
        $SanitizedSupportedOS = @()
        $ModuleName = $ModuleName.ToLower() # In the future might be good to filter this to allowed Puppet characters too
        # Ensure the module doesn't already exists
        $ModuleAbsolutePath = Join-Path $Path $ModuleName
        if ($Force -ne $true)
        {
            if (Test-Path $ModuleAbsolutePath)
            {
                throw "Module already exists at '$ModuleAbsolutePath'."
            }
        }
        
        foreach ($OS in $SupportedOS)
        {
            try
            {
                # try and sanitize the name for the forge
                switch -wildcard ($OS)
                {
                    # We may have ubuntu and ubuntu-desktop
                    'ubuntu'
                    {
                        $OSName = 'ubuntu'
                    }
                    # We may have windows-desktop, windows-server etc
                    'windows'
                    {
                        $OSName = 'windows'
                    }
                    Default
                    {
                        # Unknown OS just assume it's correct
                        $OSName = $OS
                    }
                }
                if ($OSVersions.Keys -notcontains $OSName)
                {
                    $OSVersions.Add($OSName,@())
                }
                $Details = $Configuration | Select-Object -ExpandProperty $OS -ErrorAction 'SilentlyContinue'
                if (!$Details)
                {
                    throw "No operating system matching '$OS' found in configuration."
                }
                $Releases = $Details | Select-Object -ExpandProperty Releases -ErrorAction 'SilentlyContinue'
                if (!$Releases)
                {
                    throw "No releases found for OS '$OS'."
                }
                $ReleaseVersions = $Releases.Values | Select-Object -ExpandProperty ReleaseVersion -ErrorAction 'SilentlyContinue'
                if (!$ReleaseVersions)
                {
                    throw "Unable to find release versions for OS '$OS'."
                }
                $ReleaseVersions | ForEach-Object {
                    if ($OSVersions.$OSName -notcontains $_)
                    {
                        $OSVersions.$OSName += $_
                    }
                }
            }
            catch
            {
                throw "$($_.Exception.Message)"
            }
        }
        $ManifestDirectory = Join-Path $ModuleAbsolutePath 'manifests'
        $InitParams = @{
            Name       = $ModuleName
            ModuleName = $ModuleName
        }
        if ($Description)
        {
            $InitParams.Add('Description', $Description)
        } 
        if ($IncludeParams)
        {
            $InitParams.Add('Content', "include $ModuleName::params")
            $ParamsParams = @{
                Name        = 'params'
                ModuleName  = $ModuleName
                Description = 'Private class for managing module parameters'
                Private     = $true
            }
        }

        try
        {
            $InitContent = New-PuppetClass @InitParams -ErrorAction 'stop'
        }
        catch
        {
            throw "Failed to generate init content.`n$($_.Exception.Message)"
        }
        if ($ParamsParams)
        {
            try
            {
                $ParamsContent = New-PuppetClass @ParamsParams -ErrorAction 'stop'
            }
            catch
            {
                throw "Failed to generate params content.`n$($_.Exception.Message)"
            }
        }
        try
        {
            $OSVersions.GetEnumerator() | ForEach-Object {
                $SanitizedSupportedOS += [ordered]@{
                    operatingsystem = $_.Key
                    operatingsystemrelease = $_.Value
                }
            }
            $Metadata = New-PuppetModuleMetadata `
                -ModuleName $ModuleName `
                -ForgeUsername $ForgeUsername `
                -ModuleAuthor $ModuleAuthor `
                -ModuleSummary ($Description | Out-String -NoNewline) `
                -License $ModuleLicense `
                -SupportedOS $SanitizedSupportedOS `
                -Requirements $ModuleRequirements `
                -ErrorAction 'Stop'
            if (!$Metadata)
            {
                throw 'Empty metadata.'
            }
        }
        catch
        {
            throw "Failed to create module metadata.`n$($_.Exception.Message)"
        }

        # Now that everything has been done we can create the module
        try
        {
            New-Item $ModuleAbsolutePath -ItemType 'directory' -ErrorAction 'stop' -Force:$Force | Out-Null
        }
        catch
        {
            throw "Failed to create '$ModuleAbsolutePath'.`n$($_.Exception.Message)"
        }

        try
        {
            New-Item $ManifestDirectory -ItemType 'directory' -ErrorAction 'stop' -Force:$Force | Out-Null
        }
        catch
        {
            throw "Failed to create '$ManifestDirectory'.`n$($_.Exception.Message)"
        }

        try
        {
            New-Item (Join-Path $ManifestDirectory 'init.pp') -Value $InitContent -ErrorAction 'stop' -Force:$Force | Out-Null
        }
        catch
        {
            throw "Failed to create init.pp.`n$($_.Exception.Message)"
        }

        if ($ParamsParams)
        {
            try
            {
                New-Item (Join-Path $ManifestDirectory 'params.pp') -Value $ParamsContent -ErrorAction 'stop' -Force:$Force | Out-Null
    
            }
            catch
            {
                throw "Failed to create params.pp`n$($_.Exception.Message)"
            }        
        }

        try
        {
            New-Item (Join-Path $ModuleAbsolutePath 'metadata.json') -Value $Metadata -ErrorAction 'Stop' -Force:$Force | Out-Null
        }
        catch
        {
            throw "Failed to create metadata.json.`n$($_.Exception.Message)"
        }
    }
    
    end
    {
        
    }
}