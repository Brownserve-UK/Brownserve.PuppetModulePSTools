function New-KitchenYmlTemplate
{
    [CmdletBinding(
        DefaultParameterSetName = "ConfigFiles"
    )]
    param
    (
        # The path to where to store the templates, a child directory will be created
        [Parameter(
            Mandatory = $true,
            ParameterSetName = "ConfigFiles"
        )]
        [Parameter(
            Mandatory = $true,
            ParameterSetName = "Config"
        )]
        [string]
        [ValidateNotNullOrEmpty()]
        $Path,
        
        # The directory to use for storing the templates
        [Parameter(Mandatory = $false)]
        [string]
        [ValidateNotNullOrEmpty()]
        $DirectoryName = '.kitchen-templates',

        # Provisioner config
        [Parameter(
            Mandatory = $false,
            ParameterSetName = "Config"
        )]
        [hashtable]
        $ProvisionerConfig,

        # The platform config
        [Parameter(
            Mandatory = $false,
            ParameterSetName = "Config"
        )]
        [hashtable]
        $PlatformConfig,

        # The suites config
        [Parameter(
            Mandatory = $false,
            ParameterSetName = "Config"
        )]
        [hashtable]
        $SuitesConfig,

        # The verifier config
        [Parameter(
            Mandatory = $false,
            ParameterSetName = "Config"
        )]
        [hashtable]
        $VerifierConfig,

        # The driver config
        [Parameter(
            Mandatory = $false,
            ParameterSetName = "Config"
        )]
        [hashtable]
        $DriverConfig,

        # Forces an overwrite if things already exist
        [Parameter(Mandatory = $false)]
        [switch]
        $Force,

        # The provisioner config file
        [Parameter(
            Mandatory = $false,
            DontShow,
            ParameterSetName = "ConfigFiles"
        )]
        [string]
        $ProvisionerConfigFile = (Join-Path $Script:ModuleConfigDirectory 'provisioner_config.json'),

        # The platform config file
        [Parameter(
            Mandatory = $false,
            DontShow,
            ParameterSetName = "ConfigFiles"
        )]
        [string]
        $PlatformConfigFile = (Join-Path $Script:ModuleConfigDirectory 'platforms_config.json'),

        # The config file for verifiers
        [Parameter(
            Mandatory = $false,
            DontShow,
            ParameterSetName = "ConfigFiles"
        )]
        [string]
        $VerifierConfigFile = (Join-Path $Script:ModuleConfigDirectory 'verifier_config.json'),

        # The config file for suites
        [Parameter(
            Mandatory = $false,
            DontShow,
            ParameterSetName = "ConfigFiles"
        )]
        [string]
        $SuitesConfigFile = (Join-Path $Script:ModuleConfigDirectory 'suites_config.json'),

        # The config file for drivers
        [Parameter(
            Mandatory = $false,
            DontShow,
            ParameterSetName = "ConfigFiles"
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
            $DefaultProvisioner = $ProvisionerConfig.Default
            if (!$DefaultProvisioner)
            {
                throw "Unable to find default provisioner."
            }

            # Build the parameters that are passed to the New-KitchenProvisioner cmdlet
            $ProvisionerParams = $ProvisionerConfig.$DefaultProvisioner

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

            # We often want to support multiple platforms so we iterate over the default, even if it turns out to be a string this should be safe to do.
            $PlatformConfig.Default | ForEach-Object {
                $Platforms += $PlatformConfig.$_
            }
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
            $DefaultDriver = $DriverConfig.Default
            $DriverParams =  $DriverConfig.$DefaultDriver
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
            $DefaultVerifier = $VerifierConfig.Default
            $VerifierYMLHash = @{verifier = $null }
            $VerifierParams = $VerifierConfig.$DefaultVerifier
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
            # We may have more than one default suite so iterate over
            $SuitesConfig.Default | ForEach-Object {
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