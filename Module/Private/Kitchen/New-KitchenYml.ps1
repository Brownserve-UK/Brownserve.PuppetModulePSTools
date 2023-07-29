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

        # The provisioner config to use
        [Parameter(
            Mandatory = $false
        )]
        [string]
        $ProvisionerConfigKey,

        # The platform config to use
        [Parameter(
            Mandatory = $false
        )]
        [string[]]
        $PlatformConfigKey,

        # The suites config to use
        [Parameter(
            Mandatory = $false
        )]
        [string[]]
        $SuitesConfigKey,

        # The verifier config to use
        [Parameter(
            Mandatory = $false
        )]
        [string]
        $VerifierConfigKey,

        # The driver key to use
        [Parameter(
            Mandatory = $false
        )]
        [string]
        $DriverConfigKey,

        # If set will instead of returning one kitchen.yml the output will be split into individual yaml files for each section
        [Parameter(
            Mandatory = $false
        )]
        [switch]
        $FilePerSection,

        # The provisioner config file
        [Parameter(
            Mandatory = $false,
            DontShow
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $ProvisionerConfigFile = (Join-Path $Script:ModuleConfigDirectory 'provisioner_config.json'),

        # The platform config file
        [Parameter(
            Mandatory = $false,
            DontShow
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $PlatformConfigFile = (Join-Path $Script:ModuleConfigDirectory 'platforms_config.json'),

        # The config file for verifiers
        [Parameter(
            Mandatory = $false,
            DontShow
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $VerifierConfigFile = (Join-Path $Script:ModuleConfigDirectory 'verifier_config.json'),

        # The config file for suites
        [Parameter(
            Mandatory = $false,
            DontShow
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $SuitesConfigFile = (Join-Path $Script:ModuleConfigDirectory 'suites_config.json'),

        # The config file for drivers
        [Parameter(
            Mandatory = $false,
            DontShow
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $DriverConfigFile = (Join-Path $Script:ModuleConfigDirectory 'driver_config.json')
    )
    
    begin
    {
        $FileHeader = "### THIS FILE IS MANAGED BY A TOOL MANUAL UPDATES MAY BE LOST ###`n"
    }
    
    process
    {        
        if ((!$PlatformConfig) -and (!$Platforms))
        {
            try
            {
                Write-Verbose "Loaded platform config from '$PlatformConfigFile'"
                $PlatformConfig = Get-Content $PlatformConfigFile -Raw | ConvertFrom-Json -AsHashtable
            }
            catch
            {
                throw "Failed to load platform config.`n$($_.Exception.Message)"
            }
        }

        if ((!$SuitesConfig) -and (!$Suites))
        {
            try
            {
                Write-Verbose "Loaded suites config from '$SuitesConfigFile'"
                $SuitesConfig = Get-Content $SuitesConfigFile -Raw | ConvertFrom-Json -AsHashtable
            }
            catch
            {
                throw "Failed to get suites config.`n$($_.Exception.Message)"
            }
        }
        

        if ((!$DriverConfig) -and (!$Driver))
        {
            try
            {
                Write-Verbose "Loaded driver config from '$DriverConfigFile'"
                $DriverConfig = Get-Content $DriverConfigFile -Raw | ConvertFrom-Json -AsHashtable
            }
            catch
            {
                throw "Failed to get driver config.`n$($_.Exception.Message)"
            }
        }

        if ((!$VerifierConfig) -and (!$Verifier))
        {
            try
            {
                Write-Verbose "Loaded verifier config from '$VerifierConfig'"
                $VerifierConfig = Get-Content $VerifierConfigFile -Raw | ConvertFrom-Json -AsHashtable
            }
            catch
            {
                throw "Failed to get verifier config.`n$($_.Exception.Message)"
            }
        }

        if ((!$ProvisionerConfig) -and (!$Provisioner))
        {
            try
            {
                Write-Verbose "Loaded provisioner config from '$ProvisionerConfigFile'"
                $ProvisionerConfig = Get-Content $ProvisionerConfigFile -Raw | ConvertFrom-Json -AsHashtable
            }
            catch
            {
                throw "Failed to get provisioner config.`n$($_.Exception.Message)"
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
            # Start by having some header text explaining what the section does
            $ProvisionerYMLContent = @"
# The below contains the provisioner config.
# This instructs kitchen on how to provision the test vm/container with Puppet.
# For a detailed list of options please see https://github.com/neillturner/kitchen-puppet/blob/master/provisioner_options.md`n
"@
            # Create a hashtable that we can use to convert into YAML
            $ProvisionerYMLHash = @{provisioner = $null }

            <#
                If the user has already created a provisioner block elsewhere (e.g. another cmdlet/external process etc)
                then we simply use that without performing any fancy logic.
                This allows the cmdlet to be reasonably versatile
            #>
            if ($Provisioner)
            {
                Write-Verbose "Provisioner provided, skipping generation"
                $ProvisionerYMLHash.provisioner = $Provisioner
            }
            else
            {
                # If a user hasn't provided a specific provisioner config to use then load the default
                if (!$ProvisionerConfigKey)
                {
                    Write-Verbose "Using 'Default' provisioner"
                    if (!$ProvisionerConfig.Default)
                    {
                        throw "The '-ProvisionerConfigKey' was not provided and no 'Default' key was found in the provisioner config."
                    }
                    $ProvisionerConfigKey = $ProvisionerConfig.Default
                }
                Write-Debug "ProvisionerConfigKey = $ProvisionerConfigKey"

                if (!$ProvisionerConfig.$ProvisionerConfigKey)
                {
                    throw "The key '$ProvisionerConfigKey' was not found in the provisioner config."
                }

                # Build the parameters that are passed to the New-KitchenProvisioner cmdlet
                $ProvisionerParams = $ProvisionerConfig.$ProvisionerConfigKey

                # Generate the provisioner values and store them in our hashtable
                $ProvisionerYMLHash.provisioner = New-KitchenProvisioner @ProvisionerParams
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
            $PlatformsYMLContent = @"
# The below contains the platform configuration.
# These are effectively where you will define the operating systems that your tests will run against.
# You can choose to override specific settings at a platform level if you wish (e.g. driver, transport_method etc)`n
"@
            $PlatformsYMLHash = @{platforms = @() }

            if ($Platforms)
            {
                Write-Verbose "Platforms provided, skipping generation"
                $PlatformsYMLHash.platforms = $Platforms
            }
            else
            {
                $Platforms = @()
                if (!$PlatformConfigKey)
                {
                    Write-Verbose "Using 'Default' platform"
                    if (!$PlatformConfig.Default)
                    {
                        throw "The '-PlatformConfigKey' was not provided and no 'Default' key was found in the platform config."
                    }
                    $PlatformConfigKey = $PlatformConfig.Default
                }
                Write-Debug "PlatformConfigKey = $PlatformConfigKey"

                # We often want to support multiple platforms so we iterate over the default, even if it turns out to be a string this should be safe to do.
                $PlatformConfigKey | ForEach-Object {
                    if (!$PlatformConfig.$_)
                    {
                        throw "The key '$_' was not found in the platform config."
                    }
                    $Platforms += $PlatformConfig.$_
                }
                Write-Debug "Platforms = $($Platforms -join ', ')"
                $Platforms | ForEach-Object {
                    $PlatformsYMLHash.platforms += New-KitchenPlatform @_ -ErrorAction 'Stop'
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
            $DriverYMLContent = @"
# The below contains driver configuration
# This is where you specify what driver to use for the tests.
# This can be overridden at the platform/suite level.`n
"@
            $DriverYMLHash = @{driver = $null }
            if ($Driver)
            {
                Write-Verbose "Driver provided, skipping generation"
                $DriverYMLHash.driver = $Driver
            }
            else
            {
                if (!$DriverConfigKey)
                {
                    Write-Verbose "Using 'Default' driver"
                    if (!$DriverConfig.Default)
                    {
                        throw "The '-DriverConfigKey' was not provided and no 'Default' key was found in the driver config."
                    }
                    $DriverConfigKey = $DriverConfig.Default
                }

                Write-Debug "DriverConfigKey = $DriverConfigKey"

                if (!$DriverConfig.$DriverConfigKey)
                {
                    throw "The key '$DriverConfigKey' was not found in the driver config."
                }
            
                $DriverParams = $DriverConfig.$DriverConfigKey
                $DriverYMLHash.driver = New-KitchenDriver @DriverParams -ErrorAction 'Stop'
            }
            $DriverYMLContent += $DriverYMLHash | Invoke-ConvertToYaml -ErrorAction 'Stop'
        }
        catch
        {
            throw "Failed to create driver YAML.`n$($_.Exception.Message)"
        }

        try
        {
            $VerifierYMLContent += @"
# The below contains verifier configuration.
# This tests the configuration applied by the provisioner. 
# It can be overridden at the suite/platform level.`n
"@
            $VerifierYMLHash = @{verifier = $null }
            if ($Verifier)
            {
                Write-Verbose "Verifier provided, skipping generation"
                $VerifierYMLHash.verifier = $Verifier
            }
            else
            {
                if (!$VerifierConfigKey)
                {
                    Write-Verbose "Using 'Default' verifier"
                    if (!$VerifierConfig.Default)
                    {
                        throw "The '-VerifierConfigKey' was not provided and no 'Default' key was found in the verifier config."
                    }
                    $VerifierConfigKey = $VerifierConfig.Default
                }

                Write-Debug "VerifierConfigKey = $VerifierConfigKey"
                if (!$VerifierConfig.$VerifierConfigKey)
                {
                    throw "The key '$VerifierConfigKey' was not found in the verifier config."
                }
                $VerifierParams = $VerifierConfig.$VerifierConfigKey
                $VerifierYMLHash.verifier = New-KitchenVerifier @VerifierParams
            }
            $VerifierYMLContent += $VerifierYMLHash | Invoke-ConvertToYaml -ErrorAction 'Stop'
        }
        catch
        {
            throw "Failed to create verifier YAML.`n$($_.Exception.Message)"
        }

        try
        {
            $SuitesYMLContent = @"
# The below are the test suites kitchen will apply.
# The "verifier: {command:}" dictionary is where the command that executes the verification is stored.
# These use the serverSpec standard (https://serverspec.org/).
# By default suites are applied to _every_ platform unless you specify an includes/excludes array.
# This is typically where you'll want to override any settings from other sections that require specific overrides 
# for a particular OS/manifest combination.`n
"@
            $SuitesYMLHash = @{suites = @() }
            if ($Suites)
            {
                Write-Verbose "Suites provided, skipping generation"
                $SuitesYMLHash.suites = $Suites
            }
            else
            {
                $Suites = @()
                if (!$SuitesConfigKey)
                {
                    Write-Verbose "Using 'Default' suites"
                    if (!$SuitesConfig.Default)
                    {
                        throw "The '-SuitesConfigKey' was not provided and no 'Default' key was found in the suites config."
                    }
                    $SuitesConfigKey = $SuitesConfig.Default
                }

                # We may have more than one default suite so iterate over
                $SuitesConfigKey | ForEach-Object {
                    if (!$SuitesConfig.$_)
                    {
                        throw "The key '$_' was not found in the suites config."
                    }
                    $Suites += $SuitesConfig.$_
                }
                $Suites | ForEach-Object {
                    $SuitesYMLHash.suites += New-KitchenSuite @_
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
                },
                @{
                    FileName = 'driver.yml'
                    Content  = $DriverYMLContent
                },
                @{
                    FileName = 'platforms.yml'
                    Content  = $PlatformsYMLContent
                },
                @{
                    FileName = 'verifier.yml'
                    Content  = $VerifierYMLContent
                },
                @{
                    FileName = 'suites.yml'
                    Content  = $SuitesYMLContent
                }
            )
            $YamlFiles | ForEach-Object { $_.Content = $FileHeader + $_.Content }
        }
        else
        {
            $KitchenYaml = $FileHeader + $ProvisionerYMLContent + "`n" + $DriverYMLContent + "`n" + $VerifierYMLContent + "`n" + $PlatformsYMLContent + "`n" + $SuitesYMLContent
            $YamlFiles = @(@{
                    FileName = 'kitchen.yml'
                    Content  = $KitchenYaml
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