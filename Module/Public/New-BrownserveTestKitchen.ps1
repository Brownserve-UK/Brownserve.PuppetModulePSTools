function New-BrownserveTestKitchen
{
    [CmdletBinding()]
    param
    (
        # The path to the module where the tests should be set-up
        [Parameter(Mandatory = $true)]
        [string]
        $ModulePath,

        # The type of module being created
        [Parameter(Mandatory = $true)]
        [PuppetModuleType]
        $ModuleType,

        # The operating systems that this module supports and should therefore be tested against
        [Parameter(Mandatory = $true)]
        [array]
        $SupportedOS,
        
        # An optional name for the module, if not provided the parent directories name will be used
        [Parameter(Mandatory = $false)]
        [string]
        $ModuleName,

        # The configuration file to use
        [Parameter(Mandatory = $false)]
        [string]
        $ConfigurationFile = (Join-Path $script:PuppetTemplateDirectory 'tests_defaults.jsonc')
    )
    
    begin
    {
        # Test the path is valid
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

        # Load the config
        if (!$ConfigurationOptions)
        {
            try
            {
                $ConfigurationOptions = Get-Content $ConfigurationFile -ErrorAction 'Stop' | ConvertFrom-Json -AsHashtable -ErrorAction 'Stop'
            }
            catch
            {
                throw "Failed to load configuration file '$ConfigurationFile'.`n$($_.Exception.Message)"
            }
        }

        # If the user hasn't provided a name for the module, then try to work it out
        if (!$ModuleName)
        {
            try
            {
                $ModuleName = Split-Path $ModulePath -Leaf -ErrorAction 'Stop'
            }
            catch
            {
                Write-Warning 'Module name could not be automatically determined, tests will have generic naming'
                $ModuleName = 'module'
            }
        }
    }
    
    process
    {
        $LinuxPlatforms = @()
        $WindowsPlatforms = @()
        $AcceptanceTests = @()
        $ManifestName = $ModuleName + '_tests.pp'
        $SpecPath = Join-Path $ModulePath 'spec'
        $AcceptanceTestsPath = Join-Path $SpecPath 'acceptance'

        <# 
            The provisioner options will set the main things in the provisioner section of .kitchen.yml
            There can be only one of these per kitchen manifest, but provisioner settings can be overridden at a suite/platform level. 
        #>
        $ProvisionerOptions = @{
            ManifestName = $ManifestName
        }
        # Largely the same as the above but for the "verifier" section.
        $VerifierOptions = @{}

        # These variables are used to build up the suites/platforms that we need
        $Platforms = @()
        $Suites = @()

        # Set various things depending on whether this is a module that lives under our mono repo or is a standalone module
        switch ($ModuleType)
        {
            'standalone'
            {
                $SpecHelperPath = '../'
            }
            'environment'
            {
                $SpecHelperPath = '../../../../'
            }
        }
        
        # Go through our supported OS list and create a platform for each OS we support along with each release of the OS we support
        foreach ($OS in $SupportedOS)
        {
            Write-Verbose "OS: $OS"
            # Ensure the configuration options has details for this OS.
            $OSDetails = $ConfigurationOptions.$OS
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
                    throw "Unsupported kernel '$Kernel'"
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
            foreach ($OSRelease in $OSReleases.GetEnumerator())
            {
                # Clear variables between runs
                $DriverConfigOptions = [ordered]@{}
                $DriverOptions = [ordered]@{}
                $PlatformProvisionerOptions = [ordered]@{}

                <#
                    We allow the user to specify custom provisioner, driver and driver_config options in their config.
                    This allows them to override any defaults that we set and allows for greater versatility.
                #>
                if ($OSRelease.value.ProvisionerOptions)
                {
                    $PlatformProvisionerOptions = $OSRelease.value.ProvisionerOptions
                }
                if ($OSRelease.value.DriverOptions)
                {
                    $DriverOptions = $OSRelease.value.DriverOptions
                }
                if ($OSRelease.value.DriverConfigOptions)
                {
                    $DriverConfigOptions = $OSRelease.value.DriverConfigOptions
                }

                <# 
                    Set the platform name to the name of the hashtable key, this should be something like 'latest', 'stable' etc
                    this helps when it comes to updating boxes/docker images later on.
                #>
                $PlatformName = "$($OS)_$($OSRelease.Name)".ToLower()
                Write-Verbose "PlatformName: $PlatformName"

                <#
                    For vagrant boxes we need to know what box to use, specifically we rely on the box URL as it tends to be less fussy.
                    In the future it might be nice to try and work this out automagically, especially as I made a Find-VagrantBox cmdlet.
                    But that cmdlet is flakey and that logic is beyond the scope of a first release.
                #>
                if ($OSRelease.value.VagrantBoxURL)
                {
                    $DriverOptions.Add('box_url', $OSRelease.value.VagrantBoxURL)
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
                        if ($OSRelease.value.PuppetRepo)
                        {
                            $PuppetRepo = $OSRelease.value.PuppetRepo
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
                        if ($OSRelease.value.PuppetMSI)
                        {
                            $PlatformProvisionerOptions.Add('puppet_windows_msi_url', $OSRelease.value.PuppetMSI)
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
                SuiteName    = 'linux_tests'
                SpecFileName = $DefaultLinuxSpecFileName
                Includes     = $LinuxPlatforms
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
                    Path  = $AcceptanceTestsPath
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
                SuiteName    = 'windows_tests'
                SpecFileName = $DefaultWindowsSpecFileName
                Includes     = $WindowsPlatforms
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
                    Path  = $AcceptanceTestsPath
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
        }
        catch
        {
            throw "Failed to generate kitchen YAML.`n$($_.Exception.Message)"
        }





        if ($KitchenYML)
        {
            try
            {
                New-Item $KitchenYmlPath -Value $KitchenYML -ErrorAction 'Stop'
            }
            catch
            {
                throw "Failed to create '$KitchenYmlPath'.`n$($_.Exception.Message)"
            }
        }
        if ($AcceptanceTests)
        {
            try
            {
                New-Item $AcceptanceTestsPath -ItemType Directory -ErrorAction 'Stop'
                $AcceptanceTests | ForEach-Object {
                    New-Item @_ -ErrorAction 'Stop'
                }
            }
            catch
            {
                throw "Failed to create acceptance tests.`n$($_.Exception.Message)"
            }
        }
    }
    
    end
    {
        
    }
}