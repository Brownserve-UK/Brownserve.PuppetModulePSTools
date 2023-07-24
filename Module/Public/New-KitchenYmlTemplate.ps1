function New-KitchenYmlTemplate
{
    [CmdletBinding(
        DefaultParameterSetName = 'ConfigFiles'
    )]
    param
    (
        # The path to where to store the templates, a child directory will be created
        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'ConfigFiles'
        )]
        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'Config'
        )]
        [string]
        [ValidateNotNullOrEmpty()]
        $Path,
        
        # The directory to use for storing the templates
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'ConfigFiles'
        )]
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'Config'
        )]
        [string]
        [ValidateNotNullOrEmpty()]
        $DirectoryName = '.kitchen-templates',

        # The provisioner config to use
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'ConfigFiles'
        )]
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'Config'
        )]
        [string]
        $ProvisionerConfigKey,

        # The platform config to use
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'ConfigFiles'
        )]
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'Config'
        )]
        [string[]]
        $PlatformConfigKey,

        # The suites config to use
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'ConfigFiles'
        )]
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'Config'
        )]
        [string[]]
        $SuitesConfigKey,

        # The verifier config to use
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'ConfigFiles'
        )]
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'Config'
        )]
        [string]
        $VerifierConfigKey,

        # The driver key to use
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'ConfigFiles'
        )]
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'Config'
        )]
        [string]
        $DriverConfigKey,

        # Provisioner config
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'Config'
        )]
        [hashtable]
        $ProvisionerConfig,

        # The platform config
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'Config'
        )]
        [hashtable]
        $PlatformConfig,

        # The suites config
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'Config'
        )]
        [hashtable]
        $SuitesConfig,

        # The verifier config
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'Config'
        )]
        [hashtable]
        $VerifierConfig,

        # The driver config
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'Config'
        )]
        [hashtable]
        $DriverConfig,

        # Forces an overwrite if things already exist
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'ConfigFiles'
        )]
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'Config'
        )]
        [switch]
        $Force,

        # The provisioner config file
        [Parameter(
            Mandatory = $false,
            DontShow,
            ParameterSetName = 'ConfigFiles'
        )]
        [string]
        $ProvisionerConfigFile = (Join-Path $Script:ModuleConfigDirectory 'provisioner_config.json'),

        # The platform config file
        [Parameter(
            Mandatory = $false,
            DontShow,
            ParameterSetName = 'ConfigFiles'
        )]
        [string]
        $PlatformConfigFile = (Join-Path $Script:ModuleConfigDirectory 'platforms_config.json'),

        # The config file for verifiers
        [Parameter(
            Mandatory = $false,
            DontShow,
            ParameterSetName = 'ConfigFiles'
        )]
        [string]
        $VerifierConfigFile = (Join-Path $Script:ModuleConfigDirectory 'verifier_config.json'),

        # The config file for suites
        [Parameter(
            Mandatory = $false,
            DontShow,
            ParameterSetName = 'ConfigFiles'
        )]
        [string]
        $SuitesConfigFile = (Join-Path $Script:ModuleConfigDirectory 'suites_config.json'),

        # The config file for drivers
        [Parameter(
            Mandatory = $false,
            DontShow,
            ParameterSetName = 'ConfigFiles'
        )]
        [string]
        $DriverConfigFile = (Join-Path $Script:ModuleConfigDirectory 'driver_config.json')
    )
    
    begin
    {
        $FullPath = Join-Path $Path $DirectoryName
        if ((Test-Path $FullPath))
        {
            Assert-Directory $FullPath
        }
    }
    
    process
    {
        <#
            We make the concious decision to template all the sections that make up kitchen.yml.
            If desired a user can choose not to load a given template as part of their config.
        #>
        $DriverYMLPath = Join-Path $FullPath 'driver.yml'
        $PlatformsYMLPath = Join-Path $FullPath 'platforms.yml'
        $ProvisionerYMLPath = Join-Path $FullPath 'provisioner.yml'
        $VerifierYMLPath = Join-Path $FullPath 'verifier.yml'
        $SuitesYMLPath = Join-Path $FullPath 'suites.yml'
        $FoundFiles = @()

        # Ensure that none of the templates already exist
        @($DriverYMLPath, $PlatformsYMLPath, $ProvisionerYMLPath, $VerifierYMLPath, $SuitesYMLPath) | ForEach-Object {
            if ((Test-Path $_) -and (!$Force))
            {
                $FoundFiles += $_
            }
        }
        if ($FoundFiles.Count -gt 0)
        {
            throw "Kitchen template files already exist. Use 'Update-KitchenYMLTemplate' to update them.`n$FoundFiles"
        }

        <#
            Load the various config files to get our default settings if the user hasn't passed in custom configuration
        #>
        if (!$PlatformConfig)
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

        if (!$DriverConfig)
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

        if (!$VerifierConfig)
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

        if (!$SuitesConfig)
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

        if (!$ProvisionerConfig)
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
            Now we'll use either the loaded config or user provided config to start building up the templates.
            The general process is the same for each, we read the config then pass those values to the corresponding
            cmdlet that will generate a hashtable in the format we expect so we can convert it to YAML.
            We ensure we can generate all the files first before writing anything to disk.
            I've broken the process for the provisioner for reference, the others are largely the same
        #>
        try
        {
            # Start by having a header line
            $ProvisionerYMLContent = "# This file contains your provisioner config.`n"
            # Create a hashtable that we can use to convert into YAML
            $ProvisionerYMLHash = @{provisioner = $null }

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

            # Convert the hashtable to YAML
            $ProvisionerYMLContent += $ProvisionerYMLHash | Invoke-ConvertToYaml -ErrorAction 'Stop'
        }
        catch
        {
            throw "Failed to generate kitchen provisioner.`n$($_.Exception.Message)"
        }

        try
        {
            $PlatformsYMLContent = "# This file contains your platforms.`n"
            $Platforms = @()
            $PlatformsYMLHash = @{platforms = @() }

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
            Write-Debug "Platforms = $($Platforms -join ", ")"
            $Platforms | ForEach-Object {
                $PlatformsYMLHash.platforms += New-KitchenPlatform @_ -ErrorAction 'Stop'
            }
            $PlatformsYMLContent += $PlatformsYMLHash | Invoke-ConvertToYaml -ErrorAction 'Stop'
        }
        catch
        {
            throw "Failed to generate kitchen platforms.`n$($_.Exception.Message)"
        }

        try
        {
            $DriverYMLContent = "# This file contains driver configuration`n"

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
            $DriverYMLHash = @{driver = $null }
            $DriverYMLHash.driver = New-KitchenDriver @DriverParams -ErrorAction 'Stop'
            $DriverYMLContent += $DriverYMLHash | Invoke-ConvertToYaml -ErrorAction 'Stop'
        }
        catch
        {
            throw "Failed to create driver YAML.`n$($_.Exception.Message)"
        }

        try
        {
            $VerifierYMLContent += "# This file contains verifier configuration`n"

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
            
            $VerifierYMLHash = @{verifier = $null }
            $VerifierParams = $VerifierConfig.$VerifierConfigKey
            $VerifierYMLHash.verifier = New-KitchenVerifier @VerifierParams
            $VerifierYMLContent += $VerifierYMLHash | Invoke-ConvertToYaml -ErrorAction 'Stop'
        }
        catch
        {
            throw "Failed to create verifier YAML.`n$($_.Exception.Message)"
        }

        try
        {
            $SuitesYMLContent = "# These are the default suites`n"
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
            $SuitesYMLHash = @{suites = @() }
            $Suites | ForEach-Object {
                $SuitesYMLHash.suites += New-KitchenSuite @_
            }
            $SuitesYMLContent += $SuitesYMLHash | Invoke-ConvertToYaml -ErrorAction 'Stop'
        }
        catch
        {
            throw "Failed to generate kitchen suite(s).`n$($_.Exception.Message)"
        }

        $YamlFiles = @(
            @{
                Path    = $ProvisionerYMLPath
                Content = $ProvisionerYMLContent
            },
            @{
                Path    = $DriverYMLPath
                Content = $DriverYMLContent
            },
            @{
                Path    = $PlatformsYMLPath
                Content = $PlatformsYMLContent
            },
            @{
                Path    = $VerifierYMLPath
                Content = $VerifierYMLContent
            },
            @{
                Path    = $SuitesYMLPath
                Content = $SuitesYMLContent
            }
        )
        # Only generate files if we've got everything we need
        $EmptyContent = @()
        $YamlFiles | ForEach-Object {
            if (!($_.Content) -or ($_.Content -eq ''))
            {
                $EmptyContent += $_.Path
            }
        }
        if ($EmptyContent.Count -gt 0)
        {
            throw "The YAML for the following files is empty.`n$($EmptyContent)"
        }
        else
        {
            if (!(Test-Path $FullPath))
            {
                try
                {
                    New-Item $FullPath -ItemType Directory
                }
                catch
                {
                    throw "Failed to create template directory.`n$($_.Exception.Message)"
                }
            }
            $YamlFiles | ForEach-Object {
                try
                {
                    New-Item -Path $_.Path -ItemType File -Value $_.Content -Force:$Force
                }
                catch
                {
                    throw $_.Exception.Message
                }
            }
        }

    }
    
    end
    {
        
    }
}