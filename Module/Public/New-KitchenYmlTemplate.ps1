function New-KitchenYmlTemplate
{
    [CmdletBinding()]
    param
    (
        # The path to where to store the templates, a child directory will be created
        [Parameter(Mandatory = $false)]
        [string]
        [ValidateNotNullOrEmpty()]
        $Path,
        
        # The directory to use for storing the templates
        [Parameter(Mandatory = $false)]
        [string]
        [ValidateNotNullOrEmpty()]
        $DirectoryName = '.kitchen-templates',

        # The driver to use
        [Parameter(Mandatory = $false)]
        [KitchenDriver]
        $Driver = 'vagrant',

        # The platform config file
        [Parameter(Mandatory = $false, DontShow)]
        [string]
        $PlatformConfigFile = (Join-Path $Script:ModuleConfigDirectory 'platforms_config.json'),

        # The config file for verifiers
        [Parameter(Mandatory = $false, DontShow)]
        [string]
        $VerifierConfigFile = (Join-Path $Script:ModuleConfigDirectory 'verifier_config.json'),

        # The config file for suites
        [Parameter(Mandatory = $false, DontShow)]
        [string]
        $SuitesConfigFile = (Join-Path $Script:ModuleConfigDirectory 'suites_config.json'),

        # The config file for drivers
        [Parameter(Mandatory = $false, DontShow)]
        [string]
        $DriverConfigFile = (Join-Path $Script:ModuleConfigDirectory 'driver_config.json')
    )
    
    begin
    {
        $FullPath = Join-Path $Path $DirectoryName
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
        Assert-Directory $FullPath
    }
    
    process
    {
        <#
            We make the concious decision to create ALL the parts required for a kitchen YAML.
        #>
        $DriverYMLPath = Join-Path $FullPath 'driver.yml'
        $PlatformsYMLPath = Join-Path $FullPath 'platforms.yml'
        $ProvisionerYMLPath = Join-Path $FullPath 'provisioner.yml'
        $VerifierYMLPath = Join-Path $FullPath 'verifier.yml'
        $SuitesYMLPath = Join-Path $FullPath 'suites.yml'
        $FoundFiles = @()

        @($DriverYMLPath, $PlatformsYMLPath, $ProvisionerYMLPath, $VerifierYMLPath, $SuitesYMLPath) | ForEach-Object {
            if (Test-Path $_)
            {
                $FoundFiles += $_
            }
        }
        if ($FoundFiles.Count -gt 0)
        {
            throw "Kitchen template files already exist. Use 'Update-KitchenYMLTemplate' to update them.`n$FoundFiles"
        }

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

        $ManifestName = 'tests.pp'
        $SpecRelativePath = 'spec'
        $AcceptanceTestsRelativePath = "$SpecRelativePath/acceptance"
        $ManifestDirectoryRelativePath = "$SpecAbsolutePath/manifests"
        $TestHieraDirectoryRelativePath = "$SpecRelativePath/hieradata"


        try
        {
            $PlatformsYMLContent = "# This file contains your platforms.`n"
            $Platforms = @()
            $PlatformsYMLHash = @{platforms = @()}

            $PlatformConfig.Default | ForEach-Object {
                $Platforms += $PlatformConfig.$_
            }
            $Platforms | ForEach-Object {
                $PlatformsYMLHash.platforms += New-KitchenPlatform @_ -ErrorAction 'Stop'
            }
            $PlatformsYMLContent += $PlatformsYMLHash | Invoke-ConvertToYaml -ErrorAction 'Stop'
            Write-Debug $PlatformsYMLContent
        }
        catch
        {
            throw "Failed to generate kitchen platforms.`n$($_.Exception.Message)"
        }

        try
        {
            $DriverYMLContent = "# This file contains driver configuration`n"
            $DriverParams = @{
                Driver = $Driver # TODO
            }
            $DriverYMLHash = @{driver = $null}
            if ($DriverConfig.$Driver.AdditionalParameters)
            {
                $DriverParams.Add('AdditionalParameters', $DriverConfig.$Driver.AdditionalParameters)
            }
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
            $VerifierYMLHash = @{verifier = $null}
            $VerifierParams = @{
                Verifier = $VerifierConfig.Shell.Verifier
            }
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
            $SuitesYMLHash = @{suites = @()}
            $Suites | ForEach-Object {
                $SuitesYMLHash.suites += New-KitchenSuite @_
            }
            $SuitesYMLContent += $SuitesYMLHash | Invoke-ConvertToYaml -ErrorAction 'Stop'
        }
        catch
        {
            throw "Failed to generate kitchen suite(s).`n$($_.Exception.Message)"
        }

        $ProvisionerYMLContent = 'test'

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
            $YamlFiles | ForEach-Object {
                try
                {
                    New-Item -Path $_.Path -ItemType File -Value $_.Content
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