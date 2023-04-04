<#
.SYNOPSIS
    Creates a new Puppet module
.DESCRIPTION
    A longer description of the function, its purpose, common use cases, etc.
.NOTES
    Information or caveats about the function e.g. 'This function is not supported in Linux'
.LINK
    Specify a URI to a help page, this will show when Get-Help -Online is used.
.EXAMPLE
    Test-MyTestFunction -Verbose
    Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
#>
function New-BrownservePuppetModule
{
    [CmdletBinding()]
    param
    (
        # The name of the module to be created
        [Parameter(Mandatory = $true)]
        [string]
        $Name,

        # The path to where the module should be stored
        [Parameter(Mandatory = $true)]
        [string]
        $Path,

        # The description for the Puppet module
        [Parameter(Mandatory = $true)]
        [string]
        $Description,

        # Whether or not to include an additional private params class for storing/setting configuration parameters
        [Parameter(Mandatory = $false)]
        [bool]
        $ParamsClass = $true,

        # Whether or not to include local module layer hiera for storing/setting configuration parameters
        [Parameter(Mandatory = $false)]
        [bool]
        $ModuleHiera = $false,

        # Whether or not to include spec/integration tests for this module
        [Parameter(Mandatory = $false)]
        [bool]
        $SpecTests = $true,

        # The type of test provider to use for performing spec/integration tests
        [Parameter(Mandatory = $false)]
        [TestProvider[]]
        $TestProvider = 'kitchen_vagrant',

        # The operating systems that these tests should test against
        [Parameter(Mandatory = $false)]
        [TestOperatingSystems[]]
        $TestOperatingSystems = @('ubuntu_server', 'windows_server_core', 'windows_server_standard'),

        # The OS release to test against
        [Parameter(Mandatory = $false)]
        [OSRelease[]]
        $TestOperatingSystemReleases = 'stable',

        # The major version(s) of Puppet this module targets and should therefore test against
        [Parameter(Mandatory = $false)]
        [int[]]
        $PuppetMajorVersion = $script:DefaultPuppetMajorVersion,

        # The version of Puppet to test against
        [Parameter(Mandatory = $false)]
        [PuppetAgentVersion]
        $PuppetAgentVersion = 'latest',

        # The platforms (OSes) that kitchen should test against
        [Parameter(Mandatory = $false)]
        [KitchenPlatform[]]
        $KitchenPlatforms,

        # Any test suites that should be created alongside the default windows_tests/linux_tests
        [Parameter(Mandatory = $false)]
        [KitchenSuite[]]
        $KitchenSuites,

        # Forces file creation even if they already exist at that location
        [Parameter()]
        [switch]
        $Force,

        # Skips confirmation
        [Parameter()]
        [switch]
        $Confirm
    )
    
    begin
    {
        # Check if the module exists or not already
        try
        {
            $ModuleCheck = Get-PuppetModule -ModulePath $Path | Where-Object { $_.Name -eq $Name }
            if ($ModuleCheck)
            {
                Write-Debug "Existing module found!`n$($ModuleCheck | Out-String)"
                throw "Module '$Name' already exists at '$Path'."
            }
        }
        catch
        {
            throw "Module check has failed.`n$($_.Exception.Message)"
        }
        <# 
            By default we don't want to create files on disk until we are _sure_ that we can build everything successfully so.
            we store everything we want to create in an array so we can ensure we don't pollute our repo before we are ready
            to write files to disk 
        #>
        $ToCreate = @()
        $SubDirs = @()
    }
    
    process
    {
        $ModulePath = Join-Path $Path $Name
        # We're always going to want to create some manifests
        $SubDirs += (Join-Path $ModulePath 'manifests')
        try
        {
            Write-Verbose 'Building module manifest(s)'
            if ($ParamsClass -eq $true)
            {
                $ToCreate += Build-PuppetModuleManifestFromTemplate `
                    -ModuleName $Name `
                    -ManifestSummary $Description `
                    -ManifestPath (Join-Path 'manifests' 'init.pp') `
                    -Template 'init_params.pp'
                $ToCreate += Build-PuppetModuleManifestFromTemplate `
                    -ModuleName $Name `
                    -ManifestSummary $Description `
                    -Template 'params.pp'
            }
            else
            {
                $ToCreate += Build-PuppetModuleManifestFromTemplate `
                    -ModuleName $Name `
                    -ManifestSummary $Description `
                    -ManifestPath (Join-Path 'manifests' 'init.pp') `
                    -Template 'init__no_params.pp'
            }
        }
        catch
        {
            throw "Failed to build module manifests.`n$($_.Exception.Message)"
        }
        if ($ModuleHiera -eq $true)
        {
            $SubDirs += (Join-Path $ModulePath 'data')
            try
            {
                Write-Verbose 'Building module layer hiera'
                # We run the cmdlet twice - once to create the hiera.yaml and once to create the data/common.yaml.
                $ToCreate += Build-ModuleHieraFromTemplate `
                    -HieraFilePath ('hiera.yaml') `
                    -Template 'hiera.yaml'
                $ToCreate += Build-ModuleHieraFromTemplate `
                    -HieraFilePath (Join-Path 'data' 'common.yaml') `
                    -Template 'common.yaml'
            }
            catch
            {
                throw "Failed to build module layer hiera.`n$($_.Exception.Message)"
            }
        }
        if ($SpecTests -eq $true)
        {
            $SpecDirectory = Join-Path $ModulePath 'spec'
            $SubDirs += @(
                $SpecDirectory,
                (Join-Path $SpecDirectory 'acceptance')
            )
            $TestProvider | ForEach-Object {
                switch ($_)
                {
                    'kitchen_vagrant'
                    {
                        $SubDirs += @(
                            (Join-Path $SpecDirectory 'hieradata'),
                            (Join-Path $SpecDirectory 'manifests')
                        )
                        # If the user hasn't passed in a specific list of test platforms to be created then we'll create our own from
                        # the parameters
                        if ($null -eq $KitchenPlatforms)
                        {
                            Write-Verbose 'Using parameters to build test platforms'
                            foreach ($OS in $TestOperatingSystems)
                            {
                                foreach ($Release in $TestOperatingSystemReleases)
                                {
                                    $KitchenPlatforms += [KitchenPlatform]@{
                                        OperatingSystem    = $OS
                                        OSRelease          = $Release
                                        PuppetAgentVersion = $PuppetAgentVersion
                                    }
                                }
                            }
                        }
                        try
                        {
                            $ToCreate += Build-KitchenTestsFromTemplates `
                                -ModuleName $Name `
                                -TestPlatforms $KitchenPlatforms `
                                -TestSuites $KitchenSuites `
                                -ErrorAction 'Stop'
                        }
                        catch
                        {
                            throw $_.Exception.Message
                        }
                    }
                    Default { throw "Unsupported integration test provider '$_'" }
                }
            }
        }
        if ($Confirm -ne $true)
        {
            $Prompt = "The following files will be created as part of this module:`n(FilePath relative to $(Join-Path $Path $Name))"
            $Prompt = $Prompt + "`n$($ToCreate | Out-String)"
            $Prompt = $Prompt + "`nDo you wish to continue?"
            $Response = Get-Response $Prompt 'bool'
            if ($Response -ne $true)
            {
                return $null
            }
        }
        # All being good we'll first need to create the module directory if it doesn't already exist (it may be an empty dir)
        if (!(Test-Path $ModulePath))
        {
            try
            {
                New-Item $ModulePath -ItemType Directory -Force:$Force -ErrorAction 'Stop'
            }
            catch
            {
                throw "Failed to create '$ModulePath'.`n$($_.Exception.Message)"
            }
        }
        # Create the sub dirs
        try
        {
            $SubDirs | ForEach-Object {
                New-Item $_ -ItemType Directory -ErrorAction 'stop' -Force:$Force
            }
        }
        catch
        {
            throw "Failed to create module subdirectories.`n$($_.Exception.Message)"
        }
        try
        {
            # By default New-Item will complain if files exist and -Force isn't passed so we don't need to check here
            $ToCreate | ForEach-Object {
                $ThisPath = Join-Path $ModulePath $_.FilePath -ErrorAction 'Stop'
                New-Item `
                    -Path $ThisPath `
                    -ItemType File `
                    -Value $_.Content `
                    -ErrorAction 'Stop' `
                    -Force:$Force
            }
        }
        catch
        {
            throw "Failed to create template file at '$ThisPath'.`n$($_.Exception.Message)"
        }
    }
    
    end
    {
        
    }
}