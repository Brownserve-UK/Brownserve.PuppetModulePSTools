<#
.SYNOPSIS
    A short one-line action-based description, e.g. 'Tests if a function is valid'
.DESCRIPTION
    A longer description of the function, its purpose, common use cases, etc.
#>
function New-KitchenYml
{
    [CmdletBinding()]
    param
    (
        # Allows the cmdlet to accept a provisioner hashtable created elsewhere
        [Parameter(Mandatory = $false)]
        [hashtable]
        $Provisioner,

        # Allows the cmdlet to accept a driver hashtable created elsewhere
        [Parameter(Mandatory = $false)]
        [hashtable]
        $Driver,

        # Allows the cmdlet to accept a verifier hashtable created elsewhere
        [Parameter(Mandatory = $false)]
        [hashtable]
        $Verifier,

        # Allows the cmdlet to accept a platforms hashtable created elsewhere
        [Parameter(Mandatory = $false)]
        [hashtable[]]
        $Platforms,

        # Allows the cmdlet to accept a suites hashtable created elsewhere
        [Parameter(Mandatory = $false)]
        [hashtable[]]
        $Suites,

        # If set will instead of returning one kitchen.yml the output will be split into individual yaml files for each section
        [Parameter(
            Mandatory = $false
        )]
        [switch]
        $FilePerSection,

        # Parameter help description
        [Parameter(Mandatory = $false)]
        [string]
        $KitchenConfigProvisionerKey,

        # Parameter help description
        [Parameter(Mandatory = $false)]
        [string]
        $KitchenConfigVerifierKey,

        # Parameter help description
        [Parameter(Mandatory = $false)]
        [string]
        $KitchenConfigDriverKey,

        # Parameter help description
        [Parameter(Mandatory = $false)]
        [string[]]
        $KitchenConfigPlatformKey,

        # Parameter help description
        [Parameter(Mandatory = $false)]
        [string[]]
        $KitchenConfigSuitesKey,

        # Skip any sections that are not provided.
        [Parameter(Mandatory = $false)]
        [switch]
        $SkipMissingSections,

        # The special config file that holds OS information mappings
        [Parameter(
            Mandatory = $false,
            DontShow
        )]
        [string]
        $OSInfoConfigFile,

        # The special config file that holds the default parameters for the various New-Kitchen cmdlets
        [Parameter(
            Mandatory = $false,
            DontShow
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $KitchenConfigFile
    )
    
    begin
    {
        $FileHeader = "### THIS FILE IS MANAGED BY A TOOL MANUAL UPDATES MAY BE LOST ###`n"
    }
    
    process
    {   
        # If we've not passed in any one of the sections we need then we'll need to look up the config from our file
        if ((!$Provisioner) -or (!$Driver) -or (!$Verifier) -or (!$Platforms) -or (!$Suites))
        {
            try
            {
                if (!$KitchenConfigFile)
                {
                    throw "'-KitchenConfigFile' not declared and one or more Kitchen.yml sections have no declarations."
                }
                $KitchenConfig = Get-Content $KitchenConfigFile -Raw | ConvertFrom-Json -AsHashtable
                if (!$KitchenConfig)
                {
                    throw 'Importing config file resulted in an empty object.'
                }
            }
            catch
            {
                throw "Failed to load kitchen config. `n$($_.Exception.Message)"
            }

            # If we're missing any one of the keys then we need to load the default values
            if ((!$KitchenConfigProvisionerKey) -or (!$KitchenConfigVerifierKey) -or (!$KitchenConfigDriverKey) -or (!$KitchenConfigPlatformKey) -or (!$KitchenConfigSuitesKey))
            {
                try
                {
                    $Defaults = $KitchenConfig.Default
                    if (!$Defaults)
                    {
                        throw "No default values could be found in '$KitchenConfigFile'."
                    }

                    if (!$KitchenConfigProvisionerKey)
                    {
                        $KitchenConfigProvisionerKey = $Defaults.Provisioner
                    }
                    if (!$KitchenConfigVerifierKey)
                    {
                        $KitchenConfigVerifierKey = $Defaults.Verifier
                    }
                    if (!$KitchenConfigDriverKey)
                    {
                        $KitchenConfigDriverKey = $Defaults.Driver
                    }
                    if (!$KitchenConfigPlatformKey)
                    {
                        $KitchenConfigPlatformKey = $Defaults.Platforms
                    }
                    if (!$KitchenConfigSuitesKey)
                    {
                        $KitchenConfigSuitesKey = $Defaults.Suites
                    }
                }
                catch
                {
                    throw "Failed to load default values from kitchen configuration. `n$($_.Exception.Message)"
                }
            }
        }
        <#
            Now we'll use either the loaded config or user provided blocks to start building up the templates.
            The general process is the same for each, we read the config then pass those values to the corresponding
            cmdlet that will generate a hashtable in the format we expect so we can convert it to YAML.
            We ensure we can generate all the files first before writing anything to disk.
            I've broken the process for the provisioner for reference, the others are largely the same
        #>
        try
        {
            $ProvisionerYMLContent = ""
            # Create a hashtable that we can use to convert into YAML
            $ProvisionerYMLHash = @{provisioner = $null }

            <#
                If the user has already created a provisioner block elsewhere (e.g. another cmdlet/external process etc)
                then we simply use that without performing any fancy logic.
                This allows the cmdlet to be reasonably versatile
            #>
            if ($Provisioner)
            {
                Write-Verbose 'Provisioner provided, skipping generation'
                $ProvisionerYMLHash.provisioner = $Provisioner
            }
            else
            {
                # If a user hasn't provided a specific provisioner config to use then load the default
                if (!$KitchenConfigProvisionerKey)
                {
                    throw "The '-KitchenConfigProvisionerKey' was not provided and no 'Default' provisioner key was found in '$KitchenConfigFile'."
                }
                Write-Debug "KitchenConfigProvisionerKey: $KitchenConfigProvisionerKey"


                # Build the parameters that are passed to the New-KitchenProvisioner cmdlet
                $ProvisionerParams = $KitchenConfig.Provisioner.$KitchenConfigProvisionerKey
                if (!$ProvisionerParams)
                {
                    throw "The key '$KitchenConfigProvisionerKey' was not found in the provisioner config."
                }

                # Generate the provisioner values and store them in our hashtable
                $NewProvisioner = New-KitchenProvisioner @ProvisionerParams
                $ProvisionerYMLHash.provisioner = $NewProvisioner.Section
                # If we've got a header add to the start of the file
                if ($NewProvisioner.Header)
                {
                    $ProvisionerYMLContent += $NewProvisioner.Header
                }
            }
            # Convert the hashtable to YAML
            $ProvisionerYMLContent += $ProvisionerYMLHash | Invoke-ConvertToYaml -ErrorAction 'Stop'
        }
        catch
        {
            throw "Failed to generate kitchen provisioner.`n$($_.Exception.Message)"
        }

        try
        {
            $PlatformsYMLContent = ""
            $PlatformsYMLHash = @{platforms = @() }

            if ($Platforms)
            {
                Write-Verbose 'Platforms provided, skipping generation'
                $PlatformsYMLHash.platforms = $Platforms
            }
            else
            {
                $Platforms = @()
                if (!$KitchenConfigPlatformKey)
                {
                    throw "The '-KitchenConfigPlatformKey' was not provided and no 'Default' platforms key was found in '$KitchenConfigFile'."
                }
                Write-Debug "KitchenConfigPlatformKey: $KitchenConfigPlatformKey"

                # We often want to support multiple platforms so we iterate over the default, even if it turns out to be a string this should be safe to do.
                $KitchenConfigPlatformKey | ForEach-Object {
                    if (!$KitchenConfig.Platforms.$_)
                    {
                        throw "The key '$_' was not found in the platforms config of '$KitchenConfigFile'."
                    }
                    $Platforms += $KitchenConfig.Platforms.$_
                }
                Write-Debug "Platforms: $($Platforms -join ', ')"
                $PlatformsTotal = $Platforms.Count
                $PlatformsCount = 0
                $Platforms | ForEach-Object {
                    $PlatformsCount++
                    $PlatformsParams = $_
                    if ($OSInfoConfigFile)
                    {
                        $PlatformsParams.Add('OSInfoConfigFile', $OSInfoConfigFile)
                    }
                    $NewPlatform = New-KitchenPlatform @PlatformsParams -ErrorAction 'Stop'
                    $PlatformsYMLHash.platforms += $NewPlatform | Select-Object -ExpandProperty Section
                    # Ensure we only get one header
                    if (($NewPlatform.Header) -and ($PlatformsCount -eq $PlatformsTotal))
                    {
                        $PlatformsYMLContent += $NewPlatform.Header
                    }
                }
            }
            $PlatformsYMLContent += $PlatformsYMLHash | Invoke-ConvertToYaml -ErrorAction 'Stop'
        }
        catch
        {
            throw "Failed to generate kitchen platforms.`n$($_.Exception.Message)"
        }

        try
        {
            $DriverYMLContent = ""
            $DriverYMLHash = @{driver = $null }
            if ($Driver)
            {
                Write-Verbose 'Driver provided, skipping generation'
                $DriverYMLHash.driver = $Driver
            }
            else
            {
                if (!$KitchenConfigDriverKey)
                {
                    throw "The '-KitchenConfigDriverKey' was not provided and no 'Default' driver key was found in '$KitchenConfigFile'."
                }

                Write-Debug "KitchenConfigDriverKey: $KitchenConfigDriverKey"

                $DriverParams = $KitchenConfig.Driver.$KitchenConfigDriverKey
                if (!$DriverParams)
                {
                    throw "The key '$KitchenConfigDriverKey' was not found in the driver config."
                }
                $NewDriver = New-KitchenDriver @DriverParams -ErrorAction 'Stop'
                $DriverYMLHash.driver = $NewDriver.Section
                if ($NewDriver.Header)
                {
                    $DriverYMLContent += $NewDriver.Header
                }
            }
            $DriverYMLContent += $DriverYMLHash | Invoke-ConvertToYaml -ErrorAction 'Stop'
        }
        catch
        {
            throw "Failed to create driver YAML.`n$($_.Exception.Message)"
        }

        try
        {
            $VerifierYMLContent += ""
            $VerifierYMLHash = @{verifier = $null }
            if ($Verifier)
            {
                Write-Verbose 'Verifier provided, skipping generation'
                $VerifierYMLHash.verifier = $Verifier
            }
            else
            {
                if (!$KitchenConfigVerifierKey)
                {
                    throw "The '-KitchenConfigVerifierKey' was not provided and no 'Default' verifier key was found in '$KitchenConfigFile'."
                }

                Write-Debug "KitchenConfigVerifierKey: $KitchenConfigVerifierKey"
                $VerifierParams = $KitchenConfig.Verifier.$KitchenConfigVerifierKey
                if (!$VerifierParams)
                {
                    throw "The key '$KitchenConfigVerifierKey' was not found in the verifier config."
                }
                $NewVerifier = New-KitchenVerifier @VerifierParams
                $VerifierYMLHash.verifier = $NewVerifier.Section
                if ($NewVerifier.Header)
                {
                    $VerifierYMLContent += $NewVerifier.Header
                }
            }
            $VerifierYMLContent += $VerifierYMLHash | Invoke-ConvertToYaml -ErrorAction 'Stop'
        }
        catch
        {
            throw "Failed to create verifier YAML.`n$($_.Exception.Message)"
        }

        try
        {
            $SuitesYMLContent = ""
            $SuitesYMLHash = @{suites = @() }
            if ($Suites)
            {
                Write-Verbose 'Suites provided, skipping generation'
                $SuitesYMLHash.suites = $Suites
            }
            else
            {
                $Suites = @()
                if (!$KitchenConfigSuitesKey)
                {
                    throw "The '-KitchenConfigSuitesKey' was not provided and no 'Default' suites key was found in '$KitchenConfigFile'."
                }

                # We may have more than one default suite so iterate over
                $KitchenConfigSuitesKey | ForEach-Object {
                    if (!$KitchenConfig.Suites.$_)
                    {
                        throw "The key '$_' was not found in the suites config."
                    }
                    $Suites += $KitchenConfig.Suites.$_
                }
                $SuitesTotal = $Suites.Count
                $SuitesCount = 0
                $Suites | ForEach-Object {
                    $SuitesCount++
                    $NewSuite = New-KitchenSuite @_
                    $SuitesYMLHash.suites += $NewSuite.Section
                    if ($NewSuite.Header -and ($SuitesCount -eq $SuitesTotal))
                    {
                        $SuitesYMLContent += $NewSuite.Header
                    }
                }
            }
            $SuitesYMLContent += $SuitesYMLHash | Invoke-ConvertToYaml -ErrorAction 'Stop'
        }
        catch
        {
            throw "Failed to generate kitchen suite(s).`n$($_.Exception.Message)"
        }

        if ($FilePerSection)
        {
            $YamlFiles = @(
                @{
                    FileName = 'provisioner.yml'
                    Content  = $ProvisionerYMLContent
                    Object   = $ProvisionerYMLHash
                },
                @{
                    FileName = 'driver.yml'
                    Content  = $DriverYMLContent
                    Object   = $DriverYMLHash
                },
                @{
                    FileName = 'platforms.yml'
                    Content  = $PlatformsYMLContent
                    Object   = $PlatformsYMLHash
                },
                @{
                    FileName = 'verifier.yml'
                    Content  = $VerifierYMLContent
                    Object   = $VerifierYMLHash
                },
                @{
                    FileName = 'suites.yml'
                    Content  = $SuitesYMLContent
                    Object   = $SuitesYMLHash
                }
            )
            $YamlFiles | ForEach-Object { $_.Content = $FileHeader + $_.Content }
        }
        else
        {
            $KitchenObject = $ProvisionerYMLHash + $DriverYMLHash + $VerifierYMLHash + $PlatformsYMLHash + $SuitesYMLHash
            $KitchenYaml = $FileHeader + $ProvisionerYMLContent + "`n" + $DriverYMLContent + "`n" + $VerifierYMLContent + "`n" + $PlatformsYMLContent + "`n" + $SuitesYMLContent
            $YamlFiles = @(@{
                    FileName = '.kitchen.yml'
                    Content  = $KitchenYaml
                    Object   = $KitchenObject
                })
        }
    }
    
    end
    {
        if ($YamlFiles)
        {
            return $YamlFiles
        }
        else
        {
            return $null
        }
    }
}