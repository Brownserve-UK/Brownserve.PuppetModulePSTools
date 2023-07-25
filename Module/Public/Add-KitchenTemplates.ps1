function Add-KitchenTemplates
{
    [CmdletBinding()]
    param
    (
        # The path to where to store the templates, a child directory will be created
        [Parameter(
            Mandatory = $true
        )]
        [string]
        [ValidateNotNullOrEmpty()]
        $Path,
        
        # The directory to use for storing the templates
        [Parameter(
            Mandatory = $false
        )]
        [ValidateNotNullOrEmpty()]
        $DirectoryName = '.kitchen-templates',

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

        # Forces an overwrite if things already exist
        [Parameter(
            Mandatory = $false
        )]
        [switch]
        $Force,

        # The provisioner config file
        [Parameter(
            Mandatory = $false
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $ProvisionerConfigFile = (Join-Path $Script:ModuleConfigDirectory 'provisioner_config.json'),

        # The platform config file
        [Parameter(
            Mandatory = $false
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $PlatformConfigFile = (Join-Path $Script:ModuleConfigDirectory 'platforms_config.json'),

        # The config file for verifiers
        [Parameter(
            Mandatory = $false
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $VerifierConfigFile = (Join-Path $Script:ModuleConfigDirectory 'verifier_config.json'),

        # The config file for suites
        [Parameter(
            Mandatory = $false
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $SuitesConfigFile = (Join-Path $Script:ModuleConfigDirectory 'suites_config.json'),

        # The config file for drivers
        [Parameter(
            Mandatory = $false
        )]
        [ValidateNotNullOrEmpty()]
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

        try
        {
            $NewKitchenYmlParams = @{
                DriverConfigFile      = $DriverConfigFile
                ProvisionerConfigFile = $ProvisionerConfigFile
                VerifierConfigFile    = $VerifierConfigFile
                SuitesConfigFile      = $SuitesConfigFile
                PlatformConfigFile    = $PlatformConfigFile
                FilePerSection        = $true
            }
            if ($DriverConfigKey)
            {
                $NewKitchenYmlParams.Add('DriverConfigKey', $DriverConfigKey)
            }
            if ($ProvisionerConfigKey)
            {
                $NewKitchenYmlParams.Add('ProvisionerConfigKey', $ProvisionerConfigKey)
            }
            if ($VerifierConfigKey)
            {
                $NewKitchenYmlParams.Add('VerifierConfigKey', $VerifierConfigKey)
            }
            if ($SuitesConfigKey)
            {
                $NewKitchenYmlParams.Add('SuitesConfigKey', $SuitesConfigKey)
            }
            if ($PlatformConfigKey)
            {
                $NewKitchenYmlParams.Add('PlatformConfigKey', $PlatformConfigKey)
            }

            $YamlFiles = New-KitchenYml @NewKitchenYmlParams -ErrorAction 'Stop'
        }
        catch
        {
            throw "$($_.Exception.Message)"
        }

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
                New-Item -Path (Join-Path $FullPath $_.FileName) -ItemType File -Value $_.Content -Force:$Force
            }
            catch
            {
                throw "$($_.Exception.Message)"
            }
        }
    }
    
    end
    {
        
    }
}