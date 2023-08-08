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

        # Forces an overwrite if things already exist
        [Parameter(
            Mandatory = $false
        )]
        [switch]
        $Force,

        # The name of the key that contains the provisioner you want to use
        [Parameter(
            Mandatory = $false
        )]
        [string]
        $KitchenConfigProvisionerKey,

        # The name of the key that contains the verifier you want to use
        [Parameter(
            Mandatory = $false
        )]
        [string]
        $KitchenConfigVerifierKey,

        # The name of the key that contains the driver config you want to use
        [Parameter(
            Mandatory = $false
        )]
        [string]
        $KitchenConfigDriverKey,

        # The name of the key(s) that contains the platform configuration(s) you want to use
        [Parameter(
            Mandatory = $false
        )]
        [string[]]
        $KitchenConfigPlatformKey,

        # The name of the key(s) that contains the suite configuration(s) you want to use
        [Parameter(
            Mandatory = $false
        )]
        [string[]]
        $KitchenConfigSuitesKey,

        # Load our special OS mapping config file
        [Parameter(Mandatory = $false)]
        [string]
        $OSInfoConfigFile = (Join-Path $Script:ModuleConfigDirectory 'os_info.json'),

        # The config file for drivers
        [Parameter(
            Mandatory = $false
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $KitchenConfigFile = (Join-Path $Script:ModuleConfigDirectory 'kitchen_config.json')
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
                KitchenConfigFile = $KitchenConfigFile
                FilePerSection    = $true
            }
            if ($OSInfoConfigFile)
            {
                $NewKitchenYmlParams.Add('OSInfoConfigFile', $OSInfoConfigFile)
            }
            if ($DriverConfigKey)
            {
                $NewKitchenYmlParams.Add('DriverConfigKey', $DriverConfigKey)
            }
            if ($KitchenConfigProvisionerKey)
            {
                $NewKitchenYmlParams.Add('KitchenConfigProvisionerKey', $KitchenConfigProvisionerKey)
            }
            if ($KitchenConfigVerifierKey)
            {
                $NewKitchenYmlParams.Add('KitchenConfigVerifierKey', $KitchenConfigVerifierKey)
            }
            if ($KitchenConfigDriverKey)
            {
                $NewKitchenYmlParams.Add('KitchenConfigDriverKey', $KitchenConfigDriverKey)
            }
            if ($KitchenConfigPlatformKey)
            {
                $NewKitchenYmlParams.Add('KitchenConfigPlatformKey', $KitchenConfigPlatformKey)
            }
            if ($KitchenConfigSuitesKey)
            {
                $NewKitchenYmlParams.Add('KitchenConfigSuitesKey', $KitchenConfigSuitesKey)
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