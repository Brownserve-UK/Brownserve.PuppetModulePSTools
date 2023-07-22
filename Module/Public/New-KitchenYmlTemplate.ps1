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

        # The config file for verifiers
        [Parameter(Mandatory = $false, DontShow)]
        [string]
        $VerifierConfigFile = (Join-Path $Script:ModuleConfigDirectory 'verifier_config.json'),

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
                New-Item $FullPath -ItemType 
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

        $ManifestName = 'tests.pp'
        $SpecRelativePath = 'spec'
        $AcceptanceTestsRelativePath = "$SpecRelativePath/acceptance"
        $ManifestDirectoryRelativePath = "$SpecAbsolutePath/manifests"
        $TestHieraDirectoryRelativePath = "$SpecRelativePath/hieradata"


        try
        {
            $DriverParams = @{
                Driver = $DriverConfig.$Driver.Driver
            }
            if ($DriverConfig.$Driver.AdditionalParameters)
            {
                $DriverParams.Add('AdditionalParameters', $DriverConfig.$Driver.AdditionalParameters)
            }
            $DriverYMLContent = New-KitchenDriver @DriverParams
        }
        catch
        {
            throw "Failed to create driver YAML.`n$($_.Exception.Message)"
        }

        try
        {
            $VerifierParams = @{
                Verifier = $VerifierConfigFile.Shell.Verifier
            }
            $VerifierYMLContent = New-KitchenVerifier @VerifierParams
        }
        catch
        {
            throw "Failed to create verifier YAML.`n$($_.Exception.Message)"
        }
        $ProvisionerYMLContent = 'test'
        $PlatformsYMLContent = 'test'
        $SuitesYMLContent = 'test'

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