function New-BrownserveTestKitchen
{
    [CmdletBinding()]
    param
    (
        # The name of the module the tests are being created against
        [Parameter(Mandatory = $true)]
        [string]
        $ModuleName,

        # The path to the module where the tests should be set-up
        [Parameter(Mandatory = $true)]
        [string]
        $ModulePath,

        # The type of module being created
        [Parameter(Mandatory = $true)]
        [PuppetModuleType]
        $ModuleType,

        # Any content to add to the hiera data file
        [Parameter(Mandatory = $false)]
        [string]
        $HieraContent,

        # The operating systems that this module supports and should therefore be tested against
        [Parameter(Mandatory = $true)]
        [array]
        $SupportedOS,

        # The configuration to use
        [Parameter(Mandatory = $false)]
        [BSPuppetModuleSupportedOSConfiguration]
        $SupportedOSConfiguration,

        # The configuration file to use
        [Parameter(Mandatory = $false, DontShow)]
        [string]
        $ConfigurationFile = $Script:SupportedOSConfigurationFile
    )
    
    begin
    {
        # Test the path to the module is valid
        try
        {
            $PathCheck = Get-Item $ModulePath -Force -ErrorAction 'Stop' | Where-Object { $_.PSIsContainer -eq $true }
            if (!$PathCheck)
            {
                throw "Path '$ModulePath' is not a valid directory."
            }
        }
        catch
        {
            throw $_.Exception.Message
        }

        # Test that there isn't already any tests for this module
        $KitchenYmlPath = Join-Path $ModulePath '.kitchen.yml'
        if (Test-Path $KitchenYmlPath)
        {
            throw "A kitchen configuration already exists at '$KitchenYmlPath'"
        }
        $KitchenYMLContent = "---`n# This file is generated by a tool, any notes will be lost.`n# For help see https://github.com/neillturner/kitchen-puppet/blob/master/provisioner_options.md`n"

        # Load the config
        if (!$SupportedOSConfiguration)
        {
            try
            {
                $SupportedOSConfiguration = Get-Content $ConfigurationFile -ErrorAction 'Stop' | 
                    ConvertFrom-Json -AsHashtable -ErrorAction 'Stop'
            }
            catch
            {
                throw "Failed to load configuration file '$ConfigurationFile'.`n$($_.Exception.Message)"
            }
        }
    }
    
    process
    {
        # These arrays will be used to create the default acceptance tests and their corresponding suites later on
        $LinuxPlatforms = @()
        $WindowsPlatforms = @()
        $AcceptanceTests = @()

        # This is the manifest that kitchen.yml will call when running Puppet apply
        $ManifestName = $ModuleName + '_tests.pp'

        # The path to the directory used to hold all our spec test data
        $SpecRelativePath = 'spec' # set as a variable in case we need to param it later on
        $SpecAbsolutePath = Join-Path $ModulePath $SpecRelativePath

        <# 
            We need to work out both relative and absolute paths as the relative paths will be used in kitchen.yml
            while the absolute path will be used by PowerShell to create the directories.
        #>
        $AcceptanceTestsRelativePath = "$SpecRelativePath/acceptance"
        $AcceptanceTestsAbsolutePath = Join-Path $SpecAbsolutePath 'acceptance'

        $ManifestDirectoryRelativePath = Join-Path $SpecRelativePath 'manifests'
        $ManifestDirectoryAbsolutePath = "$SpecAbsolutePath/manifests"
        $ManifestPath = Join-Path $ManifestDirectoryAbsolutePath $ManifestName
        $ManifestContent = "include $ModuleName"


        $TestHieraDirectoryRelativePath = "$SpecRelativePath/data"
        $TestHieraDirectoryAbsolutePath = Join-Path $SpecAbsolutePath 'data'
        $TestHieraPath = Join-Path $TestHieraDirectoryAbsolutePath 'common.yaml'
        $TestHieraContent = "---`n# This is your hiera file, put any parameter values and such in here`n"
        if ($HieraContent)
        {
            $TestHieraContent += $HieraContent
        }

        <# 
            The provisioner options will set the main things in the provisioner section of .kitchen.yml
            There can be only one of these per kitchen manifest, but provisioner settings can be overridden at a suite/platform level. 
        #>
        $ProvisionerOptions = @{
            ManifestName  = $ManifestName
            ManifestPath  = $ManifestDirectoryRelativePath
            HieraDataPath = $TestHieraDirectoryRelativePath
        }
        # Largely the same as the above but for the "verifier" section.
        $VerifierOptions = @{}

        # These variables are used to build up the suites/platforms that we need
        $Platforms = @()
        $Suites = @()

        # Set various things depending on whether this is a module that lives under our mono repo or is a standalone module
        switch ($ModuleType)
        {
            'public'
            {
                $SpecHelperPath = '../'
            }
            'private'
            {
                $SpecHelperPath = '../../../../'
            }
        }
        
        # Go through our supported OS list and create a platform for each OS we support along with each release of the OS we support
        foreach ($OS in $SupportedOS)
        {
            Write-Verbose "OS: $OS"
            # Ensure the configuration options has details for this OS.
            $OSDetails = $SupportedOSConfiguration | 
                Where-Object {$_.OSFamily.Name -eq $OS} |
                    Select-Object -ExpandProperty OSFamily |
                        Select-Object -ExpandProperty Details
            if (!$OSDetails)
            {
                throw "No configuration found for '$OS'."
            }

            # Work out which kernel we are working with, Linux and Windows have different things
            $Kernel = $OSDetails.Kernel
            if (!$Kernel)
            {
                throw "Kernel for OS '$OS' has not been defined."
            }
            switch ($Kernel)
            {
                'linux'
                {
                    <# 
                        For linux we typically want to use the ssh_tgz transport method as it's much faster.
                        This does require the gem having been installed.
                    #>
                    $TransportMethod = 'ssh_tgz'

                    <#
                        We need to know what suites to create later on
                    #>
                    $LinuxPlatforms += "/$($OS.ToString().ToLower())/"
                }
                'windows'
                {
                    $TransportMethod = $null
                    <#
                        We need to know what suites to create later on
                    #>
                    $WindowsPlatforms += "/$($OS.ToString().ToLower())/"
                }
                Default
                {
                    throw "Unsupported kernel '$Kernel' for OS '$OS'"
                }
            }

            # Ensure we have some OS Releases to work with
            $OSReleases = $OSDetails.Releases
            if (!$OSReleases)
            {
                throw "OS '$OS' has no defined releases."
            }

            <#
                For each OS that a module is designed for we usually want to test against multiple versions of the OS
                (e.g. Ubuntu 20.04, 18.04, 22.04)
                Therefore we look for a "Releases" key in the config options and grab any releases that are defined.
            #>
            foreach ($OSRelease in $OSReleases)
            {
                # Clear variables between runs
                $DriverConfigOptions = [ordered]@{}
                $DriverOptions = [ordered]@{}
                $PlatformProvisionerOptions = [ordered]@{}

                <#
                    We allow the user to specify custom provisioner, driver and driver_config options in their config.
                    This allows them to override any defaults that we set and allows for greater versatility.
                #>
                if ($OSRelease.Settings.KitchenOverrides.Provisioner)
                {
                    $PlatformProvisionerOptions = $OSRelease.Settings.KitchenOverrides.Provisioner
                }
                if ($OSRelease.Settings.KitchenOverrides.Driver)
                {
                    $DriverOptions = $OSRelease.Settings.KitchenOverrides.Driver
                }
                if ($OSRelease.Settings.KitchenOverrides.DriverConfig)
                {
                    $DriverConfigOptions = $OSRelease.Settings.KitchenOverrides.DriverConfig
                }

                <# 
                    Set the platform name, this should be something like 'latest', 'stable' etc
                    this helps when it comes to updating boxes/docker images later on.
                #>
                $PlatformName = "$($OS)_$($OSRelease.Name)".ToLower()
                Write-Verbose "PlatformName: $PlatformName"

                <#
                    For vagrant boxes we need to know what box to use, specifically we rely on the box URL as it tends to be less fussy.
                    In the future it might be nice to try and work this out automagically, especially as I made a Find-VagrantBox cmdlet.
                    But that cmdlet is flakey and that logic is beyond the scope of a first release.
                #>
                if ($OSRelease.Settings.VagrantBoxURL)
                {
                    $DriverOptions.Add('box_url', $OSRelease.Settings.VagrantBoxURL)
                }
                else
                {
                    throw "No 'VagrantBoxURL' defined for $PlatformName."
                }
                
                switch ($Kernel)
                {
                    'linux'
                    {
                        <#
                            On linux we need to know the repo to install Puppet from to ensure we get the correct version.
                            Similarly it might be nice to have this worked out automagically in the future but for now manually
                            specifying is fine.
                        #>
                        if ($OSRelease.Settings.PuppetAgentURL)
                        {
                            $PuppetRepo = $OSRelease.Settings.PuppetAgentURL
                            try
                            {
                                $PuppetCollectionsType = Get-PuppetCollectionsType $PuppetRepo -ErrorAction 'Stop'
                                $PlatformProvisionerOptions.Add($PuppetCollectionsType, $PuppetRepo)
                            }
                            catch
                            {
                                throw "$($_.Exception.Message)"
                            }
                        }
                        else
                        {
                            throw "No 'PuppetRepo' defined for $PlatformName."
                        }
                    }
                    'windows'
                    {
                        <#
                            For windows we need to know the URL for the MSI we want to install, this is down to how
                            Puppetlabs store their downloads and kitchen-puppet defaults to https://downloads.puppetlabs.com/windows/puppet-agent-x64-latest.msi
                            which has not been updated since 2018.
                            We could potentially work this out automagically in the future, but again for now we leave it manual.
                        #>
                        if ($OSRelease.Settings.Settings.PuppetAgentURL)
                        {
                            $PlatformProvisionerOptions.Add('puppet_windows_msi_url', $OSRelease.Settings.PuppetAgentURL)
                        }
                        else
                        {
                            throw "No 'PuppetMSI' defined for $PlatformName"
                        }
                    }
                }

                # Build up our base hashtable
                $Platform = [ordered]@{
                    PlatformName = $PlatformName
                }

                # Add any optional extras to it
                if ($DriverOptions -ne @{})
                {
                    $Platform.Add('DriverOptions', $DriverOptions)
                }
                if ($DriverConfigOptions -ne @{})
                {
                    $Platform.Add('DriverConfigOptions', $DriverConfigOptions)
                }
                if ($PlatformProvisionerOptions -ne @{})
                {
                    $Platform.Add('ProvisionerOptions', $PlatformProvisionerOptions)
                }
                if ($TransportMethod)
                {
                    $Platform.Add('TransportMethod', $TransportMethod)
                }

                # Add it to the platforms array
                $Platforms += $Platform
            }
        }

        # If we have any Linux platforms then we need to include the Linux test suite
        if ($LinuxPlatforms)
        {
            $DefaultLinuxSpecFileName = 'default_linux_spec.rb'
            $Suites += [ordered]@{
                SuiteName            = 'linux_tests'
                SpecFileName         = $DefaultLinuxSpecFileName
                SpecFileRelativePath = $AcceptanceTestsRelativePath
                Includes             = $LinuxPlatforms
            }

            try
            {
                $LinuxHelperPath = $SpecHelperPath + 'spec_linux_helper.rb' # don't use Join-Path!
                $LinuxTests = New-AcceptanceTest -RelativeRequirements $LinuxHelperPath -ErrorAction 'Stop'
                if (!$LinuxTests)
                {
                    throw 'Got an empty object'
                }
                $AcceptanceTests += @{
                    Name  = $DefaultLinuxSpecFileName
                    Path  = $AcceptanceTestsAbsolutePath
                    Value = $LinuxTests
                }
            }
            catch
            {
                throw "Failed to generate Linux acceptance test.`n$($_.Exception.Message)"
            }
        }
        # Same for Windows
        if ($WindowsPlatforms)
        {
            $DefaultWindowsSpecFileName = 'default_windows_spec.rb'
            $Suites += [ordered]@{
                SuiteName            = 'windows_tests'
                SpecFileName         = $DefaultWindowsSpecFileName
                SpecFileRelativePath = $AcceptanceTestsRelativePath
                Includes             = $WindowsPlatforms
            }

            try
            {
                $WindowsHelperPath = $SpecHelperPath + 'spec_windows_helper.rb' # don't use Join-Path!
                $WindowsTests = New-AcceptanceTest -RelativeRequirements $WindowsHelperPath -ErrorAction 'Stop'
                if (!$WindowsTests)
                {
                    throw 'Got an empty object'
                }
                $AcceptanceTests += @{
                    Name  = $DefaultWindowsSpecFileName
                    Value = $WindowsTests
                    Path  = $AcceptanceTestsAbsolutePath
                }
            }
            catch
            {
                throw "Failed to generate Windows acceptance test.`n$($_.Exception.Message)"
            }
        }

        try
        {
            $KitchenYML = New-KitchenYml `
                -ProvisionerOptions $ProvisionerOptions `
                -SuiteOptions $Suites `
                -VerifierOptions $VerifierOptions `
                -PlatformOptions $Platforms `
                -ErrorAction 'Stop'
            if (!$KitchenYML)
            {
                Write-Error 'cmdlet returned a null object'
            }
            $KitchenYMLContent += $KitchenYML
        }
        catch
        {
            throw "Failed to generate kitchen YAML.`n$($_.Exception.Message)"
        }





        if ($AcceptanceTests.Count -eq 0)
        {
            throw 'No acceptance tests have been defined.'
        }
        try
        {
            New-Item $KitchenYmlPath -Value $KitchenYMLContent -ErrorAction 'Stop' | Out-Null
        }
        catch
        {
            throw "Failed to create '$KitchenYmlPath'.`n$($_.Exception.Message)"
        }
        try
        {
            New-Item $ManifestDirectoryAbsolutePath -ItemType Directory -ErrorAction 'Stop' | Out-Null
            New-Item $ManifestPath -ItemType File -Value $ManifestContent -ErrorAction 'Stop' | Out-Null
        }
        catch
        {
            throw "Failed to created manifest.`n$($_.Exception.Message)"
        }
        try
        {
            New-Item $TestHieraDirectoryAbsolutePath -ItemType Directory -ErrorAction 'Stop' | Out-Null
            New-Item $TestHieraPath -ItemType File -Value $TestHieraContent -ErrorAction 'Stop' | Out-Null
        }
        catch
        {
            throw "Failed to create hiera.`n$($_.Exception.Message)"
        }
        try
        {
            New-Item $AcceptanceTestsAbsolutePath -ItemType Directory -ErrorAction 'Stop' | Out-Null
            $AcceptanceTests | ForEach-Object {
                New-Item @_ -ErrorAction 'Stop' | Out-Null
            }
        }
        catch
        {
            throw "Failed to create acceptance tests.`n$($_.Exception.Message)"
        }
        
    }
    
    end
    {
        if ($Return -gt 0)
        {
            return $Return
        }
    }
}